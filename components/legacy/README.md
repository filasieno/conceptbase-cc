# Legacy Java libraries (Maven)

Parent aggregator for third-party libraries rebuilt from recovered sources.

## Modules

| Module | Coordinates | Description |
|--------|-------------|-------------|
| [jgl](../jgl/) | `com.conceptbase.legacy:jgl:3.1.0` | ObjectSpace Java Generic Library |
| [grappa](../grappa/) | `com.conceptbase.legacy:grappa:1.2` | AT&T Graphviz Grappa |

## Build

From this directory or any module:

```bash
mvn install
```

The ConceptBase Java reactor (`components/java/pom.xml`) also lists `../jgl` and `../grappa` as
the first modules, so a full client build installs legacy artifacts automatically:

```bash
cd components/java && mvn install
```
