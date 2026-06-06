#include "conceptbase_parser.h"
#include "tree-sitter-conceptbase.h"

const TSLanguage *conceptbase_language(void) {
  return tree_sitter_conceptbase();
}

TSInputEncoding conceptbase_ts_encoding(ConceptbaseEncoding encoding) {
  switch (encoding) {
    case CONCEPTBASE_ENCODING_UTF8:
      return TSInputEncodingUTF8;
    case CONCEPTBASE_ENCODING_UTF16LE:
      return TSInputEncodingUTF16LE;
    case CONCEPTBASE_ENCODING_UTF16BE:
      return TSInputEncodingUTF16BE;
    default:
      return TSInputEncodingUTF8;
  }
}

TSParser *conceptbase_parser_new(void) {
  TSParser *parser = ts_parser_new();
  if (parser != NULL) {
    ts_parser_set_language(parser, conceptbase_language());
  }
  return parser;
}

TSTree *conceptbase_parse(
    TSParser *parser,
    const void *source,
    uint32_t byte_length,
    ConceptbaseEncoding encoding,
    const TSTree *old_tree) {
  if (parser == NULL || source == NULL) {
    return NULL;
  }
  return ts_parser_parse_string_encoding(
      parser,
      old_tree,
      (const char *)source,
      byte_length,
      conceptbase_ts_encoding(encoding));
}

TSTree *conceptbase_parse_utf8(
    TSParser *parser,
    const char *utf8,
    uint32_t byte_length,
    const TSTree *old_tree) {
  return conceptbase_parse(
      parser, utf8, byte_length, CONCEPTBASE_ENCODING_UTF8, old_tree);
}

TSTree *conceptbase_parse_utf16le(
    TSParser *parser,
    const void *utf16,
    uint32_t byte_length,
    const TSTree *old_tree) {
  return conceptbase_parse(
      parser, utf16, byte_length, CONCEPTBASE_ENCODING_UTF16LE, old_tree);
}

TSTree *conceptbase_parse_utf16be(
    TSParser *parser,
    const void *utf16,
    uint32_t byte_length,
    const TSTree *old_tree) {
  return conceptbase_parse(
      parser, utf16, byte_length, CONCEPTBASE_ENCODING_UTF16BE, old_tree);
}
