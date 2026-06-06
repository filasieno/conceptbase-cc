= Analyze document flows

HOW-TO for the USU document-flow model: graphical layouts (`.gel`) of business
document types and their agent/action flows in ConceptBase.

== Run

```bash
nix build .#checks.x86_64-linux.analyze-document-flows
cd components/howtos/analyze-document-flows && ./run
```

== Input

Graphical layout files (serialized cbgraph editor state):

- `usu-agentflows.gel` — overview palette for the document-flow model
- `usu.gel` — main USU document-flow graph (extended variant)
- `usu-projektabrechnung.gel` — project billing document flow
- `usu-spesenbeleg.gel` — expense receipt document flow (extended variant)

Expanded from the former `USU-Dokument.zip` archive under `usu-dokument/`:

- `usu-abwesenheit.gel`, `usu-anfrage.gel`, `usu-angebot.gel`, `usu-auftrag.gel`
- `usu-auswertungen.gel`, `usu-buchungsliste.gel`, `usu-kalulationsblatt.gel`
- `usu-korrekturgespraech.gel`, `usu-kostensaetze.gel`, `usu-mahnung.gel`
- `usu-monatsbericht.gel`, `usu-monzus.gel`, `usu-opliste.gel`
- `usu-projektanlage.gel`, `usu-projektauftrag.gel`, `usu-projektauftragMA.gel`
- `usu-sonstkosten.gel`, `usu-spesenbeleg.gel`, `usu-spesenzahlung.gel`
- `usu-statusbericht.gel`, `usu-trechnung.gel`, `usu-zahlung.gel`, `usu.gel`

Load in cbgraph via *File → Open* (or the equivalent graph-load command in CBShell).

== Output

- Graphs open in cbgraph showing actors (`Akteur`), actions (`Aktion`), and
  document carriers (`Traeger`) for each USU business document type.
- The overview graph titles the model *Analyze document flow model* and lists
  document types (absence, inquiry, offer, order, billing, expense reports, etc.).
