# German comment translation — map-reduce (Composer 2.5)

Manual map-reduce workflow to translate German/mixed comments in `components/` to English.
**No Google Translate or other MT APIs.**

## Pipeline

```
extract-manifest.py  →  manifest.txt + batch-00..19.json
        ↓
20 × Composer 2.5-fast agents (parallel)  →  batch-XX-result.json
        ↓
apply-results.py  →  updates components/ source
        ↓
re-run extract-manifest.py  →  next pass until clean
```

## Files

| File | Role |
|------|------|
| `extract-manifest.py` | **Map** — scan comments, write `manifest.txt` + 20 batches |
| `manifest.txt` | Human-readable section index (`SECTION_ID \| file:lines`) |
| `summary.json` | Stats (sections, lines, files) |
| `batch-NN.json` | Agent input |
| `batch-NN-result.json` | Agent output (`translated` per line) |
| `apply-results.py` | **Reduce** — apply all `batch-*-result.json` to source |
| `pass-1/`, `pass-2/`, … | Archived result JSON per pass |

## Commands

```bash
# 1. Extract sections and split into 20 batches
python3 archive/2026-06-06-wip/german-comment-translation/extract-manifest.py

# 2. Translate (20 Composer 2.5-fast agents in parallel — manual step)

# 3. Apply translations
python3 archive/2026-06-06-wip/german-comment-translation/apply-results.py

# 4. Repeat from step 1 until summary shows 0 real German sections
```

## Agent rules

- Preserve leading whitespace and comment delimiters (`//`, `/*`, `*`, `%`)
- Keep domain terms: miniscope, propvals, concerned class, UNTELL
- Glossary: meta formula→metaformula, Praedikat→predicate, Integritaetsbedingung→integrity constraint, Loeschen→Delete
- Each result line must match `original` exactly for `apply-results.py` to patch it

## Progress (2026-06-06)

| Pass | Sections | Lines applied | Files |
|------|----------|---------------|-------|
| 1 | 643 | 777 | 92 |
| 2 | 236 | 267 | 66 |
| 3 | 181 | 189 | 57 |
| 4 | 332 | 367 | 56 |

| 5 | 72 | 73 | 27 |

Re-run `extract-manifest.py` after each pass until `total_sections` is 0.
