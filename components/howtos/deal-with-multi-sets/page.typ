= Deal with multi-sets

Example showing how ConceptBase handles multi-set attributes (several values under one label).

== Run

From the repository root:

```bash
nix build .#checks.x86_64-linux.deal-with-multi-sets
```

Or manually (with `cbserver` and `cbshell` on `PATH`):

```bash
cd components/howtos/deal-with-multi-sets
./run
```

== Input

- `MULTISET.cbs.txt` — employees with multiple `dept` values and derived `deptsize` multi-set
- `SALARYSUM.cbs.txt` — summing salaries across multi-set attributes
- `SALARYCONSTR.cbs.txt` — constraints over multi-set aggregations

== Output

- Successful `tell` / `ask` transactions (CBShell prints `yes` or query results)
- No server errors; derived multi-set values match the assertions in each script
