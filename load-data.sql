-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Bulk Data Loader Script
-- Project Title: VDG Manager: Video Game Development Studio Management System
-- Team Members: Sharvin Manjrekar, Aulissa Beasley
-- File: load-data.sql
-- ============================================================================

PRAGMA foreign_keys = ON;

.mode csv

-- Import parent entities first, followed by child and M:N junction tables
.import --skip 1 data/Teams.csv Teams
.import --skip 1 data/Employees.csv Employees
.import --skip 1 data/Games.csv Games
.import --skip 1 data/Platforms.csv Platforms
.import --skip 1 data/Features.csv Features
.import --skip 1 data/Tasks.csv Tasks
.import --skip 1 data/Releases.csv Releases
.import --skip 1 data/GamesEmployees.csv GamesEmployees
.import --skip 1 data/GamePlatforms.csv GamePlatforms
