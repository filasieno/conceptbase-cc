# ObjectSpace JGL 3.1.0

Maven module (`com.conceptbase.legacy:jgl:3.1.0`) — Java Generic Library (`com.objectspace.jgl`),
used by ConceptBase frame/telos code. Parent POM: `../legacy/pom.xml`.

## Build

```bash
mvn install
```

Or build the full Java reactor from `components/java/` (includes this module).

## Source provenance

- Recovered from the academic mirror at
  `https://homepages.dcc.ufmg.br/~vado/java/jgl/jgl3.1.0/src/` (ObjectSpace JGL 3.1.0).
- One compatibility edit: `ConditionalEnumeration.java` renames the identifier `enum` to
  `enumeration` so the code compiles with Java 8+ (`enum` became a keyword in Java 5).

## License

ObjectSpace JGL is third-party software. Redistribution of **source** may require
ObjectSpace/Recursion Software permission; **binary** use is permitted under the original
JGL license terms. See archive `ProductPOOL/doc/ExternalLicenses/` and ObjectSpace
documentation for details.
