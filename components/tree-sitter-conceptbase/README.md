# tree-sitter-conceptbase

Tree-sitter grammar for ConceptBase model sources (Telos frames, CBL assertions,
ECArule embeddings). Built for **C/C++ LSP** integration with **UTF-8 and UTF-16**
input (LE and BE).

## Artifacts

| Output | Install path | Use |
|--------|--------------|-----|
| Shared library | `lib/libtree-sitter-conceptbase.so` | Runtime / dynamic linking |
| Static library | `lib/libtree-sitter-conceptbase.a` | LSP / embed without `.so` dep on grammar |
| WebAssembly | `lib/tree-sitter-conceptbase.wasm` | Optional (`-DBUILD_WASM=ON`) |
| C header | `include/tree-sitter-conceptbase.h` | `tree_sitter_conceptbase()` language symbol |
| C API | `include/conceptbase_parser.h` | UTF-8 / UTF-16LE / UTF-16BE parse helpers |
| C++ API | `include/conceptbase_parser.hpp` | RAII `Parser` / `Tree`, `std::u16string_view` |
| pkg-config | `lib/pkgconfig/tree-sitter-conceptbase.pc` | `-ltree-sitter-conceptbase -ltree-sitter` |

Tree-sitter generates **one** parser (`parser.c`). Encoding is selected at parse
time via `TSInputEncoding` / `conceptbase_parse()` — not separate generated grammars.

## Layout

```
CMakeLists.txt
cmake/tree-sitter-conceptbase.pc.in
source/
  grammar.js
  tree-sitter.json
  tree-sitter-conceptbase.h
  conceptbase_parser.{h,c,hpp}
  queries/
  test/corpus/
tests/
  test_parse.c
docs/
  SPECIFICATION.md
```

## Specification

See **[docs/SPECIFICATION.md](docs/SPECIFICATION.md)**.

Primary EBNF: `components/doc/user-manual/chapters/SyntaxDef.typ`.

## Build

### Nix (recommended)

One shared library derivation plus per-language checks (`nix/tree-sitter-conceptbase.nix`):

| Check | Surface language |
|-------|------------------|
| `tree-sitter-conceptbase-lib` | Shared `.so` / `.a` + headers |
| `tree-sitter-conceptbase-telos` | Telos frames |
| `tree-sitter-conceptbase-assertions` | CBL assertions / rules |
| `tree-sitter-conceptbase-ecarules` | ECArules |
| `tree-sitter-conceptbase-examples` | Examples `.sml` corpus |
| `tree-sitter-conceptbase-encoding` | UTF-8 / UTF-16 corpus + C API |
| `tree-sitter-conceptbase` | Aggregate (all of the above) |

```bash
nix build .#checks.x86_64-linux.tree-sitter-conceptbase -L
nix build .#checks.x86_64-linux.tree-sitter-conceptbase-telos -L
```

### CMake (local)

From `nix develop` (provides `cmake`, `ninja`, `tree-sitter`, `node`):

```bash
cd components/tree-sitter-conceptbase
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build
ctest --test-dir build --output-on-failure
```

Optional WASM module (needs network-capable tree-sitter wasm backend):

```bash
cmake -B build -G Ninja -DBUILD_WASM=ON
cmake --build build --target tree-sitter-conceptbase-wasm
```

## C usage (UTF-8)

```c
#include <tree_sitter/api.h>
#include <conceptbase_parser.h>

TSParser *parser = conceptbase_parser_new();
TSTree *tree = conceptbase_parse_utf8(parser, source, (uint32_t)len, NULL);
ts_tree_delete(tree);
ts_parser_delete(parser);
```

## C++ LSP usage (UTF-16LE buffer)

```cpp
#include <conceptbase_parser.hpp>

conceptbase::Parser parser;
auto utf16 = conceptbase::utf8_to_utf16le(document_utf8);
conceptbase::Tree tree = parser.parse_utf16le(utf16);
TSNode root = tree.root_node();
```

## Encodings

| Encoding | C constant | Tree-sitter | CLI `tree-sitter parse --encoding` |
|----------|------------|-------------|-------------------------------------|
| UTF-8 | `CONCEPTBASE_ENCODING_UTF8` | `TSInputEncodingUTF8` | `utf8` |
| UTF-16 LE | `CONCEPTBASE_ENCODING_UTF16LE` | `TSInputEncodingUTF16LE` | `utf16-le` |
| UTF-16 BE | `CONCEPTBASE_ENCODING_UTF16BE` | `TSInputEncodingUTF16BE` | use C API (CLI unreliable in 0.26.x) |

## Tests

CMake / CTest runs:

1. **`corpus`** — `tree-sitter test` on `source/test/corpus/` (~285+ cases)
2. **`test_parse`** — links static `.a`, verifies UTF-8 / UTF-16LE / UTF-16BE via C API

Corpus files under `source/test/corpus/` are committed. Regenerate documentation
corpus manually when manuals or examples change (extract Telos/CBL from
`components/doc/` and `components/examples/`, then update expected trees with
`tree-sitter test -u` in `source/`).

| Corpus file | Content |
|-------------|---------|
| `documentation-frames.txt` | Telos frames from manuals |
| `documentation-assertions.txt` | CBL `$…$`, ECArules, embeddings |
| `documentation-snippets.txt` | `{$set …}` and other CB blocks |
| `examples-corpus.txt` | Parseable example `.sml` files |
| `documentation-parse-failures.txt` | Excluded items + reason |
