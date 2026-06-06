#ifndef CONCEPTBASE_PARSER_HPP_
#define CONCEPTBASE_PARSER_HPP_

#include <cstdint>
#include <memory>
#include <string>
#include <string_view>
#include <vector>

#include <tree_sitter/api.h>
#include "conceptbase_parser.h"

namespace conceptbase {

enum class Encoding { Utf8, Utf16Le, Utf16Be };

inline ConceptbaseEncoding to_c_encoding(Encoding enc) {
  switch (enc) {
    case Encoding::Utf8:
      return CONCEPTBASE_ENCODING_UTF8;
    case Encoding::Utf16Le:
      return CONCEPTBASE_ENCODING_UTF16LE;
    case Encoding::Utf16Be:
      return CONCEPTBASE_ENCODING_UTF16BE;
  }
  return CONCEPTBASE_ENCODING_UTF8;
}

inline Encoding from_c_encoding(ConceptbaseEncoding enc) {
  switch (enc) {
    case CONCEPTBASE_ENCODING_UTF8:
      return Encoding::Utf8;
    case CONCEPTBASE_ENCODING_UTF16LE:
      return Encoding::Utf16Le;
    case CONCEPTBASE_ENCODING_UTF16BE:
      return Encoding::Utf16Be;
  }
  return Encoding::Utf8;
}

/** RAII wrapper around TSTree. */
class Tree {
 public:
  Tree() : tree_(nullptr) {}
  explicit Tree(TSTree *tree) : tree_(tree) {}
  ~Tree() { reset(); }

  Tree(const Tree &) = delete;
  Tree &operator=(const Tree &) = delete;

  Tree(Tree &&other) noexcept : tree_(other.tree_) { other.tree_ = nullptr; }
  Tree &operator=(Tree &&other) noexcept {
    if (this != &other) {
      reset();
      tree_ = other.tree_;
      other.tree_ = nullptr;
    }
    return *this;
  }

  TSTree *get() const { return tree_; }
  TSTree *release() {
    TSTree *t = tree_;
    tree_ = nullptr;
    return t;
  }

  void reset(TSTree *tree = nullptr) {
    if (tree_ != nullptr) {
      ts_tree_delete(tree_);
    }
    tree_ = tree;
  }

  explicit operator bool() const { return tree_ != nullptr; }

  TSNode root_node() const { return ts_tree_root_node(tree_); }

 private:
  TSTree *tree_;
};

/** RAII wrapper around TSParser configured for ConceptBase. */
class Parser {
 public:
  Parser() : parser_(conceptbase_parser_new()) {}
  ~Parser() { reset(); }

  Parser(const Parser &) = delete;
  Parser &operator=(const Parser &) = delete;

  Parser(Parser &&other) noexcept : parser_(other.parser_) {
    other.parser_ = nullptr;
  }
  Parser &operator=(Parser &&other) noexcept {
    if (this != &other) {
      reset();
      parser_ = other.parser_;
      other.parser_ = nullptr;
    }
    return *this;
  }

  TSParser *get() const { return parser_; }
  explicit operator bool() const { return parser_ != nullptr; }

  Tree parse(std::string_view utf8, const TSTree *old_tree = nullptr) const {
    return Tree(conceptbase_parse_utf8(
        parser_,
        utf8.data(),
        static_cast<uint32_t>(utf8.size()),
        old_tree));
  }

  Tree parse_utf16le(
      std::u16string_view utf16, const TSTree *old_tree = nullptr) const {
    return Tree(conceptbase_parse_utf16le(
        parser_,
        utf16.data(),
        static_cast<uint32_t>(utf16.size() * sizeof(char16_t)),
        old_tree));
  }

  Tree parse_utf16be(
      const void *utf16_bytes,
      uint32_t byte_length,
      const TSTree *old_tree = nullptr) const {
    return Tree(conceptbase_parse_utf16be(parser_, utf16_bytes, byte_length, old_tree));
  }

  Tree parse_buffer(
      const void *bytes,
      uint32_t byte_length,
      Encoding encoding,
      const TSTree *old_tree = nullptr) const {
    return Tree(conceptbase_parse(
        parser_, bytes, byte_length, to_c_encoding(encoding), old_tree));
  }

 private:
  void reset() {
    if (parser_ != nullptr) {
      ts_parser_delete(parser_);
      parser_ = nullptr;
    }
  }

  TSParser *parser_;
};

/** Encode UTF-8 text as UTF-16LE bytes (for LSP wchar_t / UTF-16 buffers on LE platforms). */
inline std::vector<char16_t> utf8_to_utf16le(std::string_view utf8) {
  std::vector<char16_t> out;
  out.reserve(utf8.size());
  size_t i = 0;
  while (i < utf8.size()) {
    unsigned char b0 = static_cast<unsigned char>(utf8[i]);
    uint32_t cp = 0;
    if (b0 < 0x80) {
      cp = b0;
      i += 1;
    } else if ((b0 & 0xE0) == 0xC0 && i + 1 < utf8.size()) {
      cp = ((b0 & 0x1F) << 6) | (static_cast<unsigned char>(utf8[i + 1]) & 0x3F);
      i += 2;
    } else if ((b0 & 0xF0) == 0xE0 && i + 2 < utf8.size()) {
      cp = ((b0 & 0x0F) << 12) |
           ((static_cast<unsigned char>(utf8[i + 1]) & 0x3F) << 6) |
           (static_cast<unsigned char>(utf8[i + 2]) & 0x3F);
      i += 3;
    } else if ((b0 & 0xF8) == 0xF0 && i + 3 < utf8.size()) {
      cp = ((b0 & 0x07) << 18) |
           ((static_cast<unsigned char>(utf8[i + 1]) & 0x3F) << 12) |
           ((static_cast<unsigned char>(utf8[i + 2]) & 0x3F) << 6) |
           (static_cast<unsigned char>(utf8[i + 3]) & 0x3F);
      i += 4;
    } else {
      cp = 0xFFFD;
      i += 1;
    }
    if (cp <= 0xFFFF) {
      out.push_back(static_cast<char16_t>(cp));
    } else {
      cp -= 0x10000;
      out.push_back(static_cast<char16_t>(0xD800 + (cp >> 10)));
      out.push_back(static_cast<char16_t>(0xDC00 + (cp & 0x3FF)));
    }
  }
  return out;
}

/** Byte-swap UTF-16 code units for big-endian parsing tests. */
inline std::vector<char16_t> utf16le_to_utf16be(const std::vector<char16_t> &le) {
  std::vector<char16_t> be;
  be.reserve(le.size());
  for (char16_t u : le) {
    be.push_back(static_cast<char16_t>((u >> 8) | (u << 8)));
  }
  return be;
}

}  // namespace conceptbase

#endif /* CONCEPTBASE_PARSER_HPP_ */
