# tree-sitter-conceptbase

Tree-sitter grammar for ConceptBase model sources (Telos frames, CBL assertions,
ECArule embeddings). Built for **C/C++ LSP** integration with **UTF-8 and UTF-16**
input (LE and BE).

## Artifacts

| Output | Path | Use |
|--------|------|-----|
| Shared library | `target/lib/libtree-sitter-conceptbase.so` | Runtime / dynamic linking |
| Static library | `target/lib/libtree-sitter-conceptbase.a` | LSP / embed without `.so` dep on grammar |
| WebAssembly | `target/lib/tree-sitter-conceptbase.wasm` | WASM tree-sitter backend |
| C header | `target/include/tree-sitter-conceptbase.h` | `tree_sitter_conceptbase()` language symbol |
| C API | `target/include/conceptbase_parser.h` | UTF-8 / UTF-16LE / UTF-16BE parse helpers |
| C++ API | `target/include/conceptbase_parser.hpp` | RAII `Parser` / `Tree`, `std::u16string_view` |
| pkg-config | `target/lib/pkgconfig/tree-sitter-conceptbase.pc` | `-ltree-sitter-conceptbase -ltree-sitter` |

Tree-sitter generates **one** parser (`parser.c`). Encoding is selected at parse
time via `TSInputEncoding` / `conceptbase_parse()` — not separate generated grammars.

## Layout

```
source/
  grammar.js
  tree-sitter.json
  tree-sitter-conceptbase.h   # language symbol
  conceptbase_parser.h        # C parse API (UTF-8 / UTF-16)
  conceptbase_parser.c
  conceptbase_parser.hpp      # C++ LSP helpers
  queries/
  test/corpus/                # tree-sitter corpus (hand-written + generated)

scripts/
  build.sh                    # .so + .a + wasm + headers
  generate-doc-corpus.py      # extract frames/CB from components/doc + examples
  test-all.sh                 # corpus + encoding + frames + C test
  test-encoding.sh
  test-frames.sh
  run-c-test.sh

tests/
  test_parse.c                # C encoding unit test
  samples/                    # UTF-8/16 sample files (generated)

target/                       # gitignored build output
docs/
  SPECIFICATION.md
```

## Specification

See **[docs/SPECIFICATION.md](docs/SPECIFICATION.md)**.

Primary EBNF: `components/doc/user-manual/chapters/SyntaxDef.typ`.

## Build

### Nix (recommended)

```bash
nix build .#checks.x86_64-linux.tree-sitter-conceptbase
```

Install paths under `$out`:

- `$out/lib/libtree-sitter-conceptbase.{so,a,wasm}`
- `$out/include/{tree-sitter-conceptbase.h,conceptbase_parser.h,conceptbase_parser.hpp}`
- `$out/lib/pkgconfig/tree-sitter-conceptbase.pc`

### Bash script

```bash
cd components/tree-sitter-conceptbase
./scripts/build.sh
```

Requires `tree-sitter`, `node`, `cc`, `ar`.

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

```bash
./scripts/build.sh
./scripts/test-all.sh
```

Regenerate documentation corpus from `components/doc/**/*.typ` and all
`components/examples/src/**/*.sml`:

```bash
python3 scripts/generate-doc-corpus.py
cd source && tree-sitter generate && tree-sitter test -u
```

`REGENERATE_DOC_CORPUS=1 ./scripts/test-all.sh` runs the generator first.
Expected CST trees are preserved when test bodies are unchanged.

Generated corpus files:

| File | Content |
|------|---------|
| `documentation-frames.txt` | All Telos frames (`… in … end`) from manuals |
| `documentation-assertions.txt` | CBL `$…$`, ECArules, inline/escaped embeddings |
| `documentation-snippets.txt` | `{$set …}` directives and other CB fenced blocks |
| `examples-corpus.txt` | Every example `.sml` file |
| `documentation-parse-failures.txt` | Smoke-parse failures (grammar debt manifest) |

Or corpus only:

```bash
cd source && tree-sitter generate && tree-sitter test
```

Test layers:

1. **Corpus** — hand-written + generated doc/examples (~285+ cases)
2. **Encoding smoke** — UTF-8/UTF-16LE via CLI; UTF-16BE via `tests/test_parse.c`
3. **Frame smoke** — optional `/tmp/frames.txt` harness
4. **C unit test** — links static `.a`, verifies all three encodings
