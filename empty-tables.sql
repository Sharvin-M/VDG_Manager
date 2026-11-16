-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Empty Tables Script
-- Project Title: VDG Manager: Video Game Development Studio Management System
-- Team Members: Sharvin Manjrekar, Aulissa Beasley
-- File: empty-tables.sql
-- ============================================================================

PRAGMA foreign_keys = ON;

-- Delete rows in reverse dependency order to respect foreign key constraints
DELETE FROM GamePlatforms;
DELETE FROM GamesEmployees;
DELETE FROM Releases;
DELETE FROM Tasks;
DELETE FROM Features;
DELETE FROM Platforms;
DELETE FROM Games;
DELETE FROM Employees;
DELETE FROM Teams;
