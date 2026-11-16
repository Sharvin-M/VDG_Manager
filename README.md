# VDG Manager: Video Game Development Studio Management System
**CSE 111 - Database Systems Final Project (Checkpoint 2)**  
**Team Members:** Sharvin Manjrekar, Aulissa Beasley

## Overview
**VDG Manager** is a relational database management system built in SQLite3 to centralize game studio operations across concurrent video game projects. It tracks department teams, employees, cross-functional game staffing, gameplay features, development tasks, version release builds, and hardware platform launches.

## Repository Contents
- `Checkpoint2-dbase.sqlite3` — Pre-seeded SQLite3 database containing all 9 normalized relations and sample studio data.
- `Checkpoint2-script.sql` — Sequential SQL script containing 32 diverse SQL statements (10 Simple, 11 Intermediate, 11 Complex) including joins, aggregations, subqueries, set operations, CTEs, window functions, views, triggers, and `CASE` analytics.
- `create-schema.sql` — DDL script defining the 9 relational tables (`Teams`, `Employees`, `Games`, `Platforms`, `Features`, `Tasks`, `Releases`, `GamesEmployees`, `GamePlatforms`), referential integrity rules, domain `CHECK` constraints, and secondary B-Tree indexes.
- `load-data.sql` — SQLite CLI bulk-import script that loads the CSV/Excel sample data from `data/` into the database tables.
- `empty-tables.sql` — DML script that clears all rows from the 9 tables in safe foreign-key dependency order.
- `generate_sample_data.py` — Utility script that generates the sample data in Excel (`.xlsx`) and `.csv` formats under `data/` and initializes `Checkpoint2-dbase.sqlite3`.
- `data/` — Directory containing the sample data as individual Excel workbooks (`*.xlsx`), a combined multi-sheet Excel workbook (`VDG_Manager_Sample_Data.xlsx`), and CSV files (`*.csv`) for each of the 9 tables.

## Execution & Verification
To verify the database and execute all 32 SQL statements sequentially (matching the Checkpoint 2 grading workflow):

```bash
sqlite3 Checkpoint2-dbase.sqlite3
.read Checkpoint2-script.sql
```

To rebuild `Checkpoint2-dbase.sqlite3` from scratch using the SQLite CLI scripts:

```bash
rm -f Checkpoint2-dbase.sqlite3
sqlite3 Checkpoint2-dbase.sqlite3 ".read create-schema.sql" ".read load-data.sql"
```

Or using the Excel data generator script:

```bash
python3 generate_sample_data.py
```
