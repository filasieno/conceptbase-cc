#!/usr/bin/env python3
"""Second-pass fixes for USU SML translation."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
USU = ROOT / "components" / "examples" / "src" / "USU"
COMPONENTS = ROOT / "components"

PASS2: list[tuple[str, str]] = [
    # model01 Action attributes
    ("        input : Data;", "        data_input : Data;"),
    ("        output : Data;", "        data_output : Data;"),
    # supplies sub-relation block keyword
    ("Actor!supplies!mit", "Actor!supplies!via"),
    ("  mit\n", "  via\n"),
    # missed query classes
    ("NimmtNichts", "TakesNothing"),
    ("GibtNichts", "GivesNothing"),
    # bezahlt over-replacement
    ("kd_paid", "kd_pays"),
    # remaining German identifiers
    ("kalkStunden", "calcHours"),
    ("T_OpListe", "T_OpenItemsList"),
    ("se_monatsbericht_", "se_monthly_report_"),
    ("pl_projabr_", "pl_project_billing_"),
    ("ma_projektabr_", "ma_project_billing_"),
    ("pc_stellt_", "pc_invoice_"),
    ("pc_kopiert", "pc_copied"),
    ("se_givesrechng_", "se_forwards_invoice_"),
    ("se_givessonst_", "se_forwards_misc_"),
    ("pe_anbh_", "pe_fwd_"),
    # akt file relation slot prefixes
    ("    ein_", "    in_"),
    ("    aus_", "    out_"),
    ("    nimm_", "    take_"),
    ("    gib_", "    give_"),
    # Spesenbeispiel German comment strings
    (
        'kommentar1: "Es wird von einer Action auf ein Datum this\n'
        '      zugegriffen, aber nicht auf das uebergeordnete hauptDatum,\n'
        '      welches this indirectly oder directly als Teil\n'
        '      aggregated"',
        'kommentar1: "An action accesses this data item\n'
        '      but not the parent hauptDatum,\n'
        '      which aggregates this directly or indirectly as a part"',
    ),
    (
        'kommentar1: "Mitteilung der Kostensaetze aus der HRDepartment"',
        'kommentar1: "Notification of cost rates from the HR department"',
    ),
    (
        'kommentar1: "BusinessArea, auf dem die Kosten und Umsaetze booked werden"',
        'kommentar1: "Business area on which costs and revenue are booked"',
    ),
    # cbteam comment if missed
    (
        "{ ---- Objekte, denen ein grafischer Typ zugeordnet ist ---- }",
        "{ ---- Objects assigned a graphical type ---- }",
    ),
]

# Broader data_input/data_output fix in akt instance files
DATA_PATTERNS = [
    ("    in_", "    data_in_"),  # no - in_ is carrier input in akt files
]


def fix_data_flow_in_akt(text: str) -> str:
    """Fix lines like '    in_1 : D_...' that are data_input slots in actions."""
    lines = []
    for line in text.splitlines(keepends=True):
        stripped = line.lstrip()
        if stripped.startswith("in_") and ": D_" in stripped:
            indent = line[: len(line) - len(stripped)]
            name = stripped.split(":")[0].strip()
            if name.startswith("in_") and not name.startswith("data_in_"):
                line = indent + "data_" + stripped
        if stripped.startswith("out_") and ": D_" in stripped:
            indent = line[: len(line) - len(stripped)]
            name = stripped.split(":")[0].strip()
            if name.startswith("out_") and not name.startswith("data_out_"):
                line = indent + "data_" + stripped
        lines.append(line)
    return "".join(lines)


def main() -> None:
    touched = []
    for path in sorted(COMPONENTS.rglob("*.sml")):
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        original = text
        for old, new in PASS2:
            text = text.replace(old, new)
        if USU in path.parents or path.parent == USU:
            text = fix_data_flow_in_akt(text)
        if text != original:
            path.write_bytes(text.encode("utf-8", errors="surrogateescape"))
            touched.append(str(path.relative_to(ROOT)))
    print(f"Pass 2 touched {len(touched)} files:")
    for f in touched:
        print(f"  {f}")


if __name__ == "__main__":
    main()
