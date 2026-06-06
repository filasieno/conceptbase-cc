/**
 * Encoding and parse smoke tests for libtree-sitter-conceptbase.
 * Links against the static archive and tree-sitter runtime.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <tree_sitter/api.h>
#include "conceptbase_parser.h"
#include "tree-sitter-conceptbase.h"

static int failures = 0;

static void expect(const char *name, int ok) {
  if (!ok) {
    fprintf(stderr, "FAIL: %s\n", name);
    failures++;
  } else {
    fprintf(stdout, "ok  %s\n", name);
  }
}

static int has_error(TSNode node) {
  if (strcmp(ts_node_type(node), "ERROR") == 0) {
    return 1;
  }
  uint32_t n = ts_node_child_count(node);
  for (uint32_t i = 0; i < n; i++) {
    if (has_error(ts_node_child(node, i))) {
      return 1;
    }
  }
  return 0;
}

static void utf8_to_utf16le(const char *utf8, size_t len, uint16_t **out, size_t *out_len) {
  size_t cap = len + 8;
  size_t count = 0;
  uint16_t *buf = (uint16_t *)malloc(cap * sizeof(uint16_t));
  size_t i = 0;
  while (i < len) {
    unsigned char b0 = (unsigned char)utf8[i];
    uint32_t cp = 0;
    if (b0 < 0x80) {
      cp = b0;
      i += 1;
    } else if ((b0 & 0xE0) == 0xC0 && i + 1 < len) {
      cp = ((b0 & 0x1F) << 6) | ((unsigned char)utf8[i + 1] & 0x3F);
      i += 2;
    } else if ((b0 & 0xF0) == 0xE0 && i + 2 < len) {
      cp = ((b0 & 0x0F) << 12) |
           (((unsigned char)utf8[i + 1] & 0x3F) << 6) |
           ((unsigned char)utf8[i + 2] & 0x3F);
      i += 3;
    } else if ((b0 & 0xF8) == 0xF0 && i + 3 < len) {
      cp = ((b0 & 0x07) << 18) |
           (((unsigned char)utf8[i + 1] & 0x3F) << 12) |
           (((unsigned char)utf8[i + 2] & 0x3F) << 6) |
           ((unsigned char)utf8[i + 3] & 0x3F);
      i += 4;
    } else {
      cp = 0xFFFD;
      i += 1;
    }
    if (count + 2 > cap) {
      cap *= 2;
      buf = (uint16_t *)realloc(buf, cap * sizeof(uint16_t));
    }
    if (cp <= 0xFFFF) {
      buf[count++] = (uint16_t)cp;
    } else {
      cp -= 0x10000;
      buf[count++] = (uint16_t)(0xD800 + (cp >> 10));
      buf[count++] = (uint16_t)(0xDC00 + (cp & 0x3FF));
    }
  }
  *out = buf;
  *out_len = count;
}

static void utf16le_to_utf16be(const uint16_t *le, size_t count, uint16_t **out) {
  uint16_t *be = (uint16_t *)malloc(count * sizeof(uint16_t));
  for (size_t i = 0; i < count; i++) {
    uint16_t u = le[i];
    be[i] = (uint16_t)((u >> 8) | (u << 8));
  }
  *out = be;
}

static int parse_and_check(TSParser *parser, const void *src, uint32_t len, ConceptbaseEncoding enc) {
  TSTree *tree = conceptbase_parse(parser, src, len, enc, NULL);
  if (tree == NULL) {
    return 0;
  }
  TSNode root = ts_tree_root_node(tree);
  int ok = strcmp(ts_node_type(root), "source_file") == 0 && !has_error(root);
  ts_tree_delete(tree);
  return ok;
}

int main(void) {
  static const char sample_utf8[] =
      "Employee in EntityType with\n"
      "  attribute\n"
      "    name : \"M\xc3\xbcller\"\n"
      "end\n";

  TSParser *parser = conceptbase_parser_new();
  expect("parser_new", parser != NULL);

  uint32_t utf8_len = (uint32_t)(sizeof(sample_utf8) - 1);
  TSTree *tree8 = conceptbase_parse_utf8(parser, sample_utf8, utf8_len, NULL);
  expect("parse_utf8", tree8 != NULL);
  if (tree8) {
    TSNode root = ts_tree_root_node(tree8);
    expect("utf8_root_type", strcmp(ts_node_type(root), "source_file") == 0);
    expect("utf8_no_error", !has_error(root));
    ts_tree_delete(tree8);
  }

  uint16_t *utf16le = NULL;
  size_t utf16_count = 0;
  utf8_to_utf16le(sample_utf8, utf8_len, &utf16le, &utf16_count);
  uint32_t utf16_bytes = (uint32_t)(utf16_count * sizeof(uint16_t));

  TSTree *tree_le = conceptbase_parse_utf16le(parser, utf16le, utf16_bytes, NULL);
  expect("parse_utf16le", tree_le != NULL);
  if (tree_le) {
    expect("utf16le_no_error", !has_error(ts_tree_root_node(tree_le)));
    ts_tree_delete(tree_le);
  }

  uint16_t *utf16be = NULL;
  utf16le_to_utf16be(utf16le, utf16_count, &utf16be);
  TSTree *tree_be = conceptbase_parse_utf16be(parser, utf16be, utf16_bytes, NULL);
  expect("parse_utf16be", tree_be != NULL);
  if (tree_be) {
    expect("utf16be_no_error", !has_error(ts_tree_root_node(tree_be)));
    ts_tree_delete(tree_be);
  }

  expect("ts_encoding_utf8", conceptbase_ts_encoding(CONCEPTBASE_ENCODING_UTF8) == TSInputEncodingUTF8);
  expect("ts_encoding_utf16le", conceptbase_ts_encoding(CONCEPTBASE_ENCODING_UTF16LE) == TSInputEncodingUTF16LE);
  expect("ts_encoding_utf16be", conceptbase_ts_encoding(CONCEPTBASE_ENCODING_UTF16BE) == TSInputEncodingUTF16BE);

  expect("language_ptr", conceptbase_language() == tree_sitter_conceptbase());

  free(utf16le);
  free(utf16be);
  ts_parser_delete(parser);

  return failures == 0 ? 0 : 1;
}
