#ifndef CONCEPTBASE_PARSER_H_
#define CONCEPTBASE_PARSER_H_

#include <stdint.h>
#include <tree_sitter/api.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Opaque language handle — same object as tree_sitter_conceptbase(). */
const TSLanguage *conceptbase_language(void);

/**
 * Input encodings supported by the Tree-sitter runtime for this grammar.
 * Tree-sitter generates a single parser; encoding is selected at parse time.
 */
typedef enum ConceptbaseEncoding {
  CONCEPTBASE_ENCODING_UTF8 = 0,
  CONCEPTBASE_ENCODING_UTF16LE = 1,
  CONCEPTBASE_ENCODING_UTF16BE = 2,
} ConceptbaseEncoding;

/** Map ConceptbaseEncoding to Tree-sitter's TSInputEncoding. */
TSInputEncoding conceptbase_ts_encoding(ConceptbaseEncoding encoding);

/** Allocate a parser pre-configured with conceptbase_language(). */
TSParser *conceptbase_parser_new(void);

/**
 * Parse a contiguous source buffer.
 *
 * @param source      UTF-8 bytes or UTF-16 code units (per @p encoding).
 * @param byte_length Size of @p source in bytes (not characters).
 * @param old_tree    Previous tree for incremental parsing, or NULL.
 * @return Syntax tree, or NULL on failure.
 */
TSTree *conceptbase_parse(
    TSParser *parser,
    const void *source,
    uint32_t byte_length,
    ConceptbaseEncoding encoding,
    const TSTree *old_tree);

/** UTF-8 convenience wrappers (byte length = strlen when NUL-terminated). */
TSTree *conceptbase_parse_utf8(
    TSParser *parser,
    const char *utf8,
    uint32_t byte_length,
    const TSTree *old_tree);

TSTree *conceptbase_parse_utf16le(
    TSParser *parser,
    const void *utf16,
    uint32_t byte_length,
    const TSTree *old_tree);

TSTree *conceptbase_parse_utf16be(
    TSParser *parser,
    const void *utf16,
    uint32_t byte_length,
    const TSTree *old_tree);

#ifdef __cplusplus
}
#endif

#endif /* CONCEPTBASE_PARSER_H_ */
