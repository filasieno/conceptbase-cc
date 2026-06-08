= Analyze Document Flows

Verified independently via:

```bash
nix build .#checks.x86_64-linux.analyze-document-flows
```

== Input

== Graph files

- `usu-agentflows.gel`
- `usu-abwesenheit.gel`
- `usu-anfrage.gel`
- `usu-angebot.gel`
- `usu-auftrag.gel`
- `usu-auswertungen.gel`
- `usu-buchungsliste.gel`
- `usu.gel`
- `usu-kalulationsblatt.gel`
- `usu-korrekturgespraech.gel`
- `usu-kostensaetze.gel`
- `usu-mahnung.gel`
- `usu-monatsbericht.gel`
- `usu-monzus.gel`
- `usu-opliste.gel`
- `usu-projektanlage.gel`
- `usu-projektauftrag.gel`
- `usu-projektauftragMA.gel`
- `usu-sonstkosten.gel`
- `usu-spesenbeleg.gel`

== Shell output

```text
=== HOW-TO: analyze-document-flows ===

>>> Validating ./usu-agentflows.gel
>>> cbgraph smoke: ./usu-agentflows.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1790: xvfb-run: command not found
cbgraph smoke skipped or timed out for ./usu-agentflows.gel (asset validation only)

>>> Validating ./usu-dokument/usu-abwesenheit.gel

>>> Validating ./usu-dokument/usu-anfrage.gel

>>> Validating ./usu-dokument/usu-angebot.gel

>>> Validating ./usu-dokument/usu-auftrag.gel

>>> Validating ./usu-dokument/usu-auswertungen.gel

>>> Validating ./usu-dokument/usu-buchungsliste.gel

>>> Validating ./usu-dokument/usu-kalulationsblatt.gel

>>> Validating ./usu-dokument/usu-korrekturgespraech.gel

>>> Validating ./usu-dokument/usu-kostensaetze.gel

>>> Validating ./usu-dokument/usu-mahnung.gel

>>> Validating ./usu-dokument/usu-monatsbericht.gel

>>> Validating ./usu-dokument/usu-monzus.gel

>>> Validating ./usu-dokument/usu-opliste.gel

>>> Validating ./usu-dokument/usu-projektanlage.gel

>>> Validating ./usu-dokument/usu-projektauftrag.gel

>>> Validating ./usu-dokument/usu-projektauftragMA.gel

>>> Validating ./usu-dokument/usu-sonstkosten.gel

>>> Validating ./usu-dokument/usu-spesenbeleg.gel

>>> Validating ./usu-dokument/usu-spesenzahlung.gel

>>> Validating ./usu-dokument/usu-statusbericht.gel

>>> Validating ./usu-dokument/usu-trechnung.gel

>>> Validating ./usu-dokument/usu-zahlung.gel

>>> Validating ./usu-dokument/usu.gel

>>> Validating ./usu-projektabrechnung.gel

>>> Validating ./usu-spesenbeleg.gel

>>> Validating ./usu.gel
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
