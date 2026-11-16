#!/usr/bin/env python3
"""
CSE 111 Fall 2026: Project Checkpoint 2 Sample Data Generator & Excel Loader
Project Title: VDG Manager: Video Game Development Studio Management System
Team Members: Sharvin Manjrekar, Aulissa Beasley

Generates Excel (.xlsx) workbooks and CSV files for all 9 relational tables
in the VDG Manager schema and populates Checkpoint2-dbase.sqlite3.
"""

import csv
import os
import sqlite3
import zipfile
from xml.sax.saxutils import escape
import xml.etree.ElementTree as ET

DATA_DIR = "data"
DB_FILE = "Checkpoint2-dbase.sqlite3"
SCHEMA_FILE = "create-schema.sql"

TABLES = {
    "Teams": {
        "headers": ["team_id", "team_name", "department"],
        "rows": [
            [1, "Core Engine Syndicate", "Engineering"],
            [2, "Valkyrie Visuals", "Art & Animation"],
            [3, "Narrative & Systems Lab", "Game Design"],
            [4, "Ironclad QA", "Quality Assurance"],
            [5, "Echo Chamber Audio", "Audio & Music"],
            [6, "Horizon Production Office", "Production"],
        ],
    },
    "Employees": {
        "headers": ["employee_id", "name", "email", "role", "hire_date", "team_id"],
        "rows": [
            [101, "Elena Vance", "evance@vdgstudio.com", "Lead Engine Architect", "2021-03-15", 1],
            [102, "Marcus Sterling", "msterling@vdgstudio.com", "Senior Graphics Programmer", "2022-06-10", 1],
            [103, "Priya Patel", "ppatel@vdgstudio.com", "AI Systems Programmer", "2023-08-22", 1],
            [104, "Kenji Takahashi", "ktakahashi@vdgstudio.com", "Senior Technical Artist", "2021-11-04", 2],
            [105, "Sofia Rodriguez", "srodriguez@vdgstudio.com", "Lead Environment Artist", "2022-02-18", 2],
            [106, "Liam O'Connor", "loconnor@vdgstudio.com", "Creative Director", "2020-09-01", 3],
            [107, "Amara Okafor", "aokafor@vdgstudio.com", "Senior Combat Designer", "2023-01-20", 3],
            [108, "Hannah Abbott", "habbott@vdgstudio.com", "QA Lead", "2022-09-12", 4],
            [109, "Mateo Silva", "msilva@vdgstudio.com", "Lead Audio Director", "2021-07-19", 5],
            [110, "Rachel Chen", "rchen@vdgstudio.com", "Executive Producer", "2020-05-11", 6],
            [111, "Devon Brooks", "dbrooks@vdgstudio.com", "Network Engineer", "2024-01-15", 1],
            [112, "Chloe Bennett", "cbennett@vdgstudio.com", "3D Character Animator", "2024-04-12", 2],
            [113, "Noah Kim", "nkim@vdgstudio.com", "Level Designer", "2024-07-08", 3],
            [114, "Tyler Mercer", "tmercer@vdgstudio.com", "Automation QA Analyst", "2025-02-03", 4],
            [115, "Zara Al-Mansoor", "zalmansoor@vdgstudio.com", "Sound Designer", "2025-05-19", 5],
        ],
    },
    "Games": {
        "headers": ["game_id", "title", "genre", "description", "start_date", "status"],
        "rows": [
            [
                1,
                "Aether Chronicles",
                "Action RPG",
                "Open-world fantasy RPG with elemental spellweaving and aerial combat",
                "2023-02-01",
                "In Development",
            ],
            [
                2,
                "Neon Drift 2099",
                "Cyberpunk Racing",
                "High-speed anti-gravity street racing set in a rain-soaked megacity",
                "2023-09-15",
                "Beta",
            ],
            [
                3,
                "Starfall Vanguard",
                "Tactical Sci-Fi Strategy",
                "Turn-based orbital fleet and squad tactics across procedurally generated sectors",
                "2022-05-10",
                "Released",
            ],
            [
                4,
                "Hollow Bastion Tactics",
                "Roguelike Deckbuilder",
                "Dark fantasy tactical deckbuilder with shifting dungeon layouts",
                "2024-03-20",
                "Alpha",
            ],
            [
                5,
                "Chrono Odyssey: Echoes",
                "Metroidvania Platformer",
                "Time-manipulation 2D pixel-art action platformer",
                "2025-01-10",
                "Pre-Production",
            ],
            [
                6,
                "Project Titanfall Zero",
                "Arena Shooter",
                "Experimental multiplayer mech arena prototype",
                "2022-11-01",
                "Cancelled",
            ],
        ],
    },
    "Platforms": {
        "headers": ["platform_id", "name", "manufacturer"],
        "rows": [
            [1, "PC (Steam)", "Valve"],
            [2, "PlayStation 5", "Sony"],
            [3, "Xbox Series X", "Microsoft"],
            [4, "Nintendo Switch", "Nintendo"],
            [5, "Steam Deck", "Valve"],
            [6, "iOS", "Apple"],
            [7, "Android", "Google"],
        ],
    },
    "Features": {
        "headers": ["feature_id", "game_id", "feature_name", "description", "status", "priority"],
        "rows": [
            [201, 1, "Elemental Spellweaving Combat", "Real-time spell combination and elemental resonance engine", "In Progress", 5],
            [202, 1, "Dynamic Weather & Day-Night Cycle", "Volumetric clouds, storm physics, and NPC schedule shifts", "In Progress", 4],
            [203, 1, "Aerial Mount Navigation", "Seamless sky-island flight and wind-current physics", "Planned", 3],
            [204, 1, "Guild Co-op Raid Matchmaking", "Cross-region lobby and 4-player instance synchronization", "Testing", 5],
            [205, 2, "Anti-Gravity Hover Physics", "Magnetic track repulsion and drift boost mechanics", "Completed", 5],
            [206, 2, "Ray-Traced Neon Reflections", "Real-time wet pavement reflections and dynamic shaders", "In Progress", 4],
            [207, 2, "Synthwave Adaptive Soundtrack", "Speed-reactive multi-stem electronic music mixer", "Testing", 3],
            [208, 3, "Procedural Sector Generator", "Seed-based star system and anomaly generation", "Completed", 5],
            [209, 3, "Orbital Bombardment Tactical UI", "3D holographic command overlay and firing solution HUD", "Completed", 4],
            [210, 3, "Modding Workshop Integration", "Custom campaign scripting and Steam Workshop uploader", "In Progress", 2],
            [211, 4, "Synergy Card Combo Resolver", "Deterministic stack resolution for chained relic and card effects", "In Progress", 5],
            [212, 4, "Procedural Catacomb Tile Map", "Room graph generator with fog-of-war lighting", "Planned", 4],
            [213, 5, "Time-Rewind Ghost Recording", "Frame-accurate state buffer for temporal clone puzzles", "Planned", 5],
            [214, 5, "Pixel Shader Lighting Pipeline", "2D normal-mapped dynamic sprite illumination", "Planned", 3],
        ],
    },
    "Tasks": {
        "headers": ["task_id", "feature_id", "task_name", "description", "status", "priority", "due_date"],
        "rows": [
            [301, 201, "Fire-Ice Vapor Reaction Math", "Implement damage multiplier and steam AoE hitbox", "Completed", 5, "2026-03-10"],
            [302, 201, "Spell Combo Input Buffer", "Create 120ms input queue for rapid elemental weaving", "In Progress", 4, "2026-05-15"],
            [303, 201, "Arcane Particle Shader Polish", "Optimize GPU instancing for elemental projectiles", "To Do", 2, "2026-06-20"],
            [304, 202, "Volumetric Cloud Raymarching", "Implement horizon cloud scattering pass", "Completed", 5, "2026-02-28"],
            [305, 202, "Lightning Strike Terrain Scorch", "Dynamic decal spawning during thunderstorm events", "In Review", 3, "2026-05-20"],
            [306, 203, "Updraft Wind Tunnel Volumes", "Trigger volumes applying vertical impulse to mounts", "In Progress", 4, "2026-06-10"],
            [307, 203, "Wing Stamina UI Gauge", "Radial HUD indicator for glide exhaustion", "To Do", 2, "2026-07-05"],
            [308, 204, "Dedicated Server Handshake API", "Token authentication and NAT punchthrough", "Blocked", 5, "2026-04-30"],
            [309, 204, "Raid Loot Roll Synchronizer", "Server-authoritative RNG distribution table", "In Progress", 3, "2026-05-25"],
            [310, 205, "Mag-Lev Suspension Raycasts", "Four-corner spring damper hover stabilization", "Completed", 5, "2025-11-15"],
            [311, 205, "Apex Drift Boost Telemetry", "Slip-angle threshold detection for turbo charge", "Completed", 4, "2025-12-10"],
            [312, 206, "BVH Acceleration Structure", "Optimize bounding volume hierarchy for city neon signs", "Completed", 5, "2026-01-25"],
            [313, 206, "Roughness Puddle Map Blending", "Vertex-painted wet asphalt specular masks", "In Review", 4, "2026-04-18"],
            [314, 206, "DLSS Frame Generation Hook", "Integrate temporal upscaling pipeline for 4K targets", "Blocked", 4, "2026-05-01"],
            [315, 207, "BPM Pitch-Shift DSP Filter", "Modulate bassline tempo above 300 km/h", "Completed", 3, "2026-02-14"],
            [316, 207, "Tunnel Reverb Occlusion Zones", "Acoustic convolution snapshots for subterranean tracks", "In Progress", 2, "2026-04-22"],
            [317, 208, "Voronoi Star-Lane Graph", "Generate connected jump-gate topology", "Completed", 5, "2024-08-10"],
            [318, 208, "Nebula Hazard Spawner", "Place ion storm and asteroid belt modifiers", "Completed", 3, "2024-09-05"],
            [319, 209, "Holographic Grid Projection", "Render 3D tactical elevation contour lines", "Completed", 4, "2024-10-12"],
            [320, 209, "Trajectory Arc Preview Line", "Bezier curve visualizer for orbital kinetic strikes", "Completed", 4, "2024-11-01"],
            [321, 210, "Lua Sandbox Security Validator", "Restrict file-system I/O calls in user mod scripts", "Completed", 4, "2026-03-01"],
            [322, 210, "Workshop Thumbnail Uploader", "Async HTTP multipart uploader for mod previews", "In Review", 2, "2026-05-10"],
            [323, 211, "Relic Trigger Priority Queue", "Deterministic ordering for passive relic effects", "In Progress", 5, "2026-06-15"],
            [324, 211, "Card Burn Particle Dissolve", "Custom ash-disintegration shader for exhausted cards", "To Do", 2, "2026-07-20"],
            [325, 212, "Boss Room Corridor Lock", "Ensure minimum 4-room distance to floor guardian", "Blocked", 4, "2026-06-30"],
            [326, 213, "Ring Buffer Transform Logger", "Record 60fps player position and animation state", "To Do", 5, "2026-09-01"],
        ],
    },
    "Releases": {
        "headers": ["release_id", "game_id", "version", "release_date", "description", "status"],
        "rows": [
            [401, 1, "0.1.0-alpha", "2025-06-15", "Internal vertical slice with elemental combat prototype", "Released"],
            [402, 1, "0.5.0-beta", "2026-08-01", "Closed beta build featuring sky-island exploration", "Scheduled"],
            [403, 2, "0.8.0-beta", "2026-01-20", "Public multiplayer stress-test demo with 4 tracks", "Released"],
            [404, 2, "0.9.5-rc1", "2026-05-15", "Release candidate with ray-traced neon reflections", "RC Testing"],
            [405, 3, "1.0.0", "2025-03-12", "Official launch build with full 3-act orbital campaign", "Released"],
            [406, 3, "1.2.0", "2025-10-05", "Fleet Commander expansion patch and balance overhaul", "Released"],
            [407, 4, "0.2.0-alpha", "2026-04-10", "Early access alpha build for deckbuilding balance", "Released"],
            [408, 6, "0.0.1-proto", "2023-02-01", "Cancelled greybox mech movement prototype build", "Cancelled"],
            [409, 6, "0.0.2-proto", "2023-04-15", "Cancelled network sync prototype build", "Cancelled"],
        ],
    },
    "GamesEmployees": {
        "headers": ["game_id", "employee_id", "role"],
        "rows": [
            [1, 101, "Lead Engine Architect"],
            [1, 102, "Principal Shader Programmer"],
            [1, 104, "Lead Technical Artist"],
            [1, 106, "Creative Director"],
            [1, 107, "Lead Combat Designer"],
            [1, 108, "QA Lead"],
            [2, 101, "Physics Optimization Consultant"],
            [2, 102, "Ray-Tracing Lead"],
            [2, 105, "Lead Environment Artist"],
            [2, 108, "Performance QA Lead"],
            [2, 109, "Adaptive Audio Director"],
            [2, 111, "Multiplayer Netcode Lead"],
            [3, 103, "Tactical AI Lead"],
            [3, 106, "Systems Design Advisor"],
            [3, 109, "Orchestral Score Director"],
            [3, 110, "Executive Producer"],
            [3, 113, "Campaign Level Designer"],
            [4, 103, "Card Logic Programmer"],
            [4, 107, "Deck Balance Designer"],
            [4, 112, "Creature Animator"],
            [5, 110, "Project Producer"],
            [5, 113, "Puzzle Level Designer"],
        ],
    },
    "GamePlatforms": {
        "headers": ["game_id", "platform_id", "release_date"],
        "rows": [
            [1, 1, "2026-11-15"],
            [1, 2, "2026-11-15"],
            [1, 3, "2026-11-15"],
            [2, 1, "2026-07-20"],
            [2, 2, "2026-07-20"],
            [2, 5, "2026-09-01"],
            [3, 1, "2025-03-12"],
            [3, 3, "2025-06-01"],
            [3, 5, "2025-03-12"],
            [3, 6, "2025-11-20"],
            [4, 1, "2026-10-31"],
            [4, 4, "2026-10-31"],
            [4, 6, "2027-01-15"],
            [5, 1, "2027-04-01"],
            [5, 4, "2027-04-01"],
        ],
    },
}


def col_letter(idx: int) -> str:
    """Convert 0-based column index to Excel column letter (A, B, ..., Z, AA...)."""
    res = ""
    n = idx + 1
    while n > 0:
        n, rem = divmod(n - 1, 26)
        res = chr(65 + rem) + res
    return res


def build_sheet_xml(headers: list, rows: list) -> str:
    """Build OpenXML worksheet XML string with inline strings and numeric cells."""
    all_rows = [headers] + rows
    lines = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
        "  <sheetData>",
    ]
    for r_idx, row in enumerate(all_rows, start=1):
        lines.append(f'    <row r="{r_idx}">')
        for c_idx, val in enumerate(row):
            cell_ref = f"{col_letter(c_idx)}{r_idx}"
            if isinstance(val, (int, float)) and not isinstance(val, bool) and r_idx > 1:
                lines.append(f'      <c r="{cell_ref}"><v>{val}</v></c>')
            else:
                text = escape(str(val))
                lines.append(
                    f'      <c r="{cell_ref}" t="inlineStr"><is><t>{text}</t></is></c>'
                )
        lines.append("    </row>")
    lines.append("  </sheetData>")
    lines.append("</worksheet>")
    return "\n".join(lines)


def write_xlsx_workbook(filepath: str, sheets: dict) -> None:
    """Write a standard OpenXML .xlsx workbook containing one or more sheets."""
    sheet_names = list(sheets.keys())

    content_types = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
        '  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
        '  <Default Extension="xml" ContentType="application/xml"/>',
        '  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
    ]
    for i in range(1, len(sheet_names) + 1):
        content_types.append(
            f'  <Override PartName="/xl/worksheets/sheet{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        )
    content_types.append("</Types>")

    root_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>"""

    workbook_xml = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
        "  <sheets>",
    ]
    workbook_rels = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    ]
    for i, name in enumerate(sheet_names, start=1):
        safe_name = escape(name)
        workbook_xml.append(
            f'    <sheet name="{safe_name}" sheetId="{i}" r:id="rId{i}"/>'
        )
        workbook_rels.append(
            f'  <Relationship Id="rId{i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i}.xml"/>'
        )
    workbook_xml.append("  </sheets>")
    workbook_xml.append("</workbook>")
    workbook_rels.append("</Relationships>")

    with zipfile.ZipFile(filepath, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", "\n".join(content_types))
        zf.writestr("_rels/.rels", root_rels)
        zf.writestr("xl/workbook.xml", "\n".join(workbook_xml))
        zf.writestr("xl/_rels/workbook.xml.rels", "\n".join(workbook_rels))
        for i, name in enumerate(sheet_names, start=1):
            sheet_data = sheets[name]
            xml_str = build_sheet_xml(sheet_data["headers"], sheet_data["rows"])
            zf.writestr(f"xl/worksheets/sheet{i}.xml", xml_str)


def read_xlsx_sheet(filepath: str, sheet_index: int = 1) -> tuple[list, list]:
    """Read headers and rows from an OpenXML .xlsx file to verify & load into SQLite."""
    ns = {"main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
    with zipfile.ZipFile(filepath, "r") as zf:
        xml_bytes = zf.read(f"xl/worksheets/sheet{sheet_index}.xml")
    root = ET.fromstring(xml_bytes)
    parsed_rows = []
    for row_el in root.findall(".//main:sheetData/main:row", ns):
        row_vals = []
        for c_el in row_el.findall("main:c", ns):
            cell_type = c_el.attrib.get("t", "")
            if cell_type == "inlineStr":
                t_el = c_el.find(".//main:t", ns)
                row_vals.append(t_el.text if t_el is not None else "")
            else:
                v_el = c_el.find("main:v", ns)
                val_text = v_el.text if v_el is not None else ""
                try:
                    row_vals.append(int(val_text))
                except ValueError:
                    try:
                        row_vals.append(float(val_text))
                    except ValueError:
                        row_vals.append(val_text)
        parsed_rows.append(row_vals)
    return parsed_rows[0], parsed_rows[1:]


def main():
    os.makedirs(DATA_DIR, exist_ok=True)

    # 1. Create individual Excel (.xlsx) files and CSV files for each table
    for table_name, data in TABLES.items():
        xlsx_path = os.path.join(DATA_DIR, f"{table_name}.xlsx")
        write_xlsx_workbook(xlsx_path, {table_name: data})

        # Read back from the generated Excel file to write the matching CSV file
        headers, rows = read_xlsx_sheet(xlsx_path, 1)
        csv_path = os.path.join(DATA_DIR, f"{table_name}.csv")
        with open(csv_path, "w", newline="", encoding="utf-8") as cf:
            writer = csv.writer(cf)
            writer.writerow(headers)
            writer.writerows(rows)

        print(f"Generated {xlsx_path} and {csv_path} ({len(rows)} rows)")

    # 2. Create combined multi-sheet Excel (.xlsx) workbook
    combined_xlsx = os.path.join(DATA_DIR, "VDG_Manager_Sample_Data.xlsx")
    write_xlsx_workbook(combined_xlsx, TABLES)
    print(f"Generated combined Excel workbook: {combined_xlsx}")

    # 3. Create and seed Checkpoint2-dbase.sqlite3 from create-schema.sql and Excel files
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

    conn = sqlite3.connect(DB_FILE)
    conn.execute("PRAGMA foreign_keys = ON;")
    with open(SCHEMA_FILE, "r", encoding="utf-8") as sf:
        conn.executescript(sf.read())

    conn.execute("PRAGMA foreign_keys = ON;")
    for table_name in TABLES:
        xlsx_path = os.path.join(DATA_DIR, f"{table_name}.xlsx")
        headers, rows = read_xlsx_sheet(xlsx_path, 1)
        placeholders = ", ".join(["?"] * len(headers))
        col_list = ", ".join(headers)
        sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"
        conn.executemany(sql, rows)

    conn.commit()
    conn.close()
    print(f"Successfully initialized and seeded {DB_FILE} from Excel data files.")


if __name__ == "__main__":
    main()
