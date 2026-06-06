#!/usr/bin/env python3
"""Final manual fixes for the last German comment sections."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent

# Load EXTERNAL_CONNECTION_EN from sibling module
spec = importlib.util.spec_from_file_location("rebuild", OUT / "rebuild-and-finish.py")
rebuild = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rebuild)

PATCHES: dict[str, list[tuple[str, str]]] = {
    "components/java/cbworkbench/src/main/java/i5/cb/workbench/StatusBar.java": [
        ("Transaktionszeit in Millisekunden", "transaction time in milliseconds"),
    ],
    "components/java/cbapi/src/main/java/i5/cb/api/LocalCBclient.java": [
        ("         **/\n         **/", "         **/"),
    ],
    "components/server-engine/src/ConfigurationUtilities.swi.pl": [
        (
            "* 9-Dez-1996/LWEB: module changes. Beim Laden der Applikationsfiles the ... is\n"
            "* id des Systemmoduls and the id des Module Objekts im Fakt  Ssytem/1 and Module/1\n"
            "* zwecks spaeterem effizienten Zugriff (kein retrieve noetig) abgespeichert.\n"
            "* Der aktuelle Modul Suchraum  (getModule/1) is auf das System-Modul gesetzt.\n"
            "*\n"
            "*  Einige im Zuge der Objektspeicherumstellung jetzt unbenutzte Funktionen wie\n"
            "*  system_create_log/1 , system_create_h/1 , system_create /1 history_prop/1 were rausgeschmissen.",
            "* 9-Dez-1996/LWEB: module changes. When loading application files the\n"
            "* id of the system module and the id of the module object are stored in facts System/1 and Module/1\n"
            "* for later efficient access (no retrieve needed).\n"
            "* The current module search space (getModule/1) is set to the system module.\n"
            "*\n"
            "* Some functions unused after the object store migration, such as\n"
            "* system_create_log/1, system_create_h/1, system_create/1, history_prop/1, were removed.",
        ),
    ],
    "components/server-engine/src/ExternalConnection.swi.pl": [
        (
            "/* Waehrend the Definition eines ExternalQuery/GeniericExternalQueryobjects shall this Definition um */",
            "/* During definition of an ExternalQuery/GenericExternalQuery object this definition is extended by */",
        ),
    ],
    "components/server-engine/src/GeneralUtilities.swi.pl": [
        ("/* (nur noetig, wo also grosse Atome vor- */", "/* (only needed where large atoms occur- */"),
    ],
    "components/server-engine/src/MetaSimplifier.swi.pl": [
        (
            "* the Format anders gewaehlt ist. Waehrend in constraints nur\n"
            "*  universally quantified literals that are replaced are used for rules\n"
            "*  sowohl all- als also existenzquantifizierte literals replaced.",
            "* a different format is chosen. While in constraints only\n"
            "*  universally quantified literals that are replaced are used, for rules\n"
            "*  both universally and existentially quantified literals are replaced.",
        ),
        ('\tand "Proposition" aus der Suchmenge', '\tand "Proposition" from the search set'),
    ],
    "components/server-engine/src/QueryCompiler.swi.pl": [
        (
            "/* is. Die arguments in t are Atome, pc_atom_to_term is noetig um daraus */",
            "/* is. The arguments in t are atoms; pc_atom_to_term is needed to turn them into */",
        ),
        (
            "/* wohl wir mitten in einem Ask sind. Das is noetig */",
            "/* presumably we are in the middle of an ask. This is necessary */",
        ),
    ],
    "components/server-engine/src/QueryEvaluator.swi.pl": [
        (
            "/*Bei Laden von externen OBjekten (tell_temp_ExObj) wrid ueberprueft, ob IC thereby noetig ist.\n"
            "Wenn es for a der geladene objects der case is, the ... is Flag ifcheck als TRUE gesetzt. IC is used for\n"
            "all in this Transaktion geladene Daten performed. */",
            "/* When loading external objects (tell_temp_ExObj) it is checked whether IC is needed.\n"
            "If that is the case for one of the loaded objects, the ifcheck flag is set to TRUE. IC is performed for\n"
            "all data loaded in this transaction. */",
        ),
    ],
    "components/server-engine/src/RuleBase.swi.pl": [
        (
            "/* Waehrend a Transaktion is used for each neu generierte */",
            "/* During a transaction it is used for each newly generated */",
        ),
    ],
}


def patch_external_connection() -> None:
    path = REPO / "components/server-engine/src/ExternalConnection.swi.pl"
    text = path.read_text(encoding="latin-1")
    marker_start = "/*\n\n\nDas Modul ExternalConnection"
    marker_end = "\n*/\n\n:- module"
    start = text.find(marker_start)
    if start < 0:
        marker_start = "/*\n\nThe ExternalConnection module"
        start = text.find(marker_start)
    end = text.find(marker_end, start)
    if start < 0 or end < 0:
        print("ExternalConnection block not found", start, end)
        return
    new_block = (
        "/*\n\n"
        "The ExternalConnection module provides the methods that implement access to external sources.\n"
        "Using the example DB mainlibrary, the implementation of external access is illustrated.\n\n"
        + rebuild.EXTERNAL_CONNECTION_EN
        + "\n*/"
    )
    path.write_text(text[:start] + new_block + text[end + len("\n*/") :], encoding="latin-1")
    print("patched ExternalConnection tutorial block")


def main() -> None:
    patch_external_connection()
    for rel, pairs in PATCHES.items():
        path = REPO / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="latin-1")
        for old, new in pairs:
            if old not in text:
                print(f"MISS {rel}: {old[:50]!r}...")
                continue
            text = text.replace(old, new)
        path.write_text(text, encoding="latin-1")
        print(f"patched {rel}")

    spec = importlib.util.spec_from_file_location("extract_manifest", OUT / "extract-manifest.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sections = mod.extract_sections()
    summary = {
        "remaining_sections": len(sections),
        "remaining_lines": sum(len(s["lines"]) for s in sections),
        "remaining_files": len({s["file"] for s in sections}),
    }
    (OUT / "completion-summary.json").write_text(json.dumps(summary, indent=2))
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
