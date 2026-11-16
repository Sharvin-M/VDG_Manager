-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Schema Definition
-- Project Title: VDG Manager: Video Game Development Studio Management System
-- Team Members: Sharvin Manjrekar, Aulissa Beasley
-- File: create-schema.sql
-- ============================================================================

PRAGMA foreign_keys = ON;

-- Drop existing views, triggers, and tables in reverse dependency order
DROP VIEW IF EXISTS View_StudioProductionDashboard;
DROP TRIGGER IF EXISTS trg_AutoCompleteFeatureOnTaskUpdate;
DROP TRIGGER IF EXISTS trg_PromoteGameStatusOnRelease;

DROP TABLE IF EXISTS GamePlatforms;
DROP TABLE IF EXISTS GamesEmployees;
DROP TABLE IF EXISTS Releases;
DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Features;
DROP TABLE IF EXISTS Platforms;
DROP TABLE IF EXISTS Games;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Teams;

-- ----------------------------------------------------------------------------
-- Table 01: Teams
-- Description: Studio departments and specialized functional teams.
-- ----------------------------------------------------------------------------
CREATE TABLE Teams (
    team_id INTEGER PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL CHECK (
        department IN (
            'Engineering',
            'Art & Animation',
            'Game Design',
            'Quality Assurance',
            'Audio & Music',
            'Production'
        )
    )
);

-- ----------------------------------------------------------------------------
-- Table 02: Employees
-- Description: Studio staff members assigned to department teams (1:N).
-- ----------------------------------------------------------------------------
CREATE TABLE Employees (
    employee_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    team_id INTEGER,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- Table 03: Games
-- Description: Core video game titles managed across the studio lifecycle.
-- ----------------------------------------------------------------------------
CREATE TABLE Games (
    game_id INTEGER PRIMARY KEY,
    title VARCHAR(100) NOT NULL UNIQUE,
    genre VARCHAR(50) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL CHECK (
        status IN (
            'Pre-Production',
            'In Development',
            'Alpha',
            'Beta',
            'Released',
            'Cancelled'
        )
    )
);

-- ----------------------------------------------------------------------------
-- Table 04: Platforms
-- Description: Target hardware and digital distribution platforms.
-- ----------------------------------------------------------------------------
CREATE TABLE Platforms (
    platform_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    manufacturer VARCHAR(50) NOT NULL
);

-- ----------------------------------------------------------------------------
-- Table 05: Features
-- Description: Major gameplay and technical features belonging to a game (1:N).
-- ----------------------------------------------------------------------------
CREATE TABLE Features (
    feature_id INTEGER PRIMARY KEY,
    game_id INTEGER NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL CHECK (
        status IN (
            'Planned',
            'In Progress',
            'Testing',
            'Completed'
        )
    ),
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 5),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Table 06: Tasks
-- Description: Granular actionable development work items under a feature (1:N).
-- ----------------------------------------------------------------------------
CREATE TABLE Tasks (
    task_id INTEGER PRIMARY KEY,
    feature_id INTEGER NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL CHECK (
        status IN (
            'To Do',
            'In Progress',
            'In Review',
            'Blocked',
            'Completed'
        )
    ),
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 5),
    due_date DATE NOT NULL,
    FOREIGN KEY (feature_id) REFERENCES Features(feature_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Table 07: Releases
-- Description: Versioned build history and milestone releases for each game (1:N).
-- ----------------------------------------------------------------------------
CREATE TABLE Releases (
    release_id INTEGER PRIMARY KEY,
    game_id INTEGER NOT NULL,
    version VARCHAR(20) NOT NULL,
    release_date DATE NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL CHECK (
        status IN (
            'Scheduled',
            'RC Testing',
            'Released',
            'Deprecated',
            'Cancelled'
        )
    ),
    UNIQUE (game_id, version),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Table 08: GamesEmployees
-- Description: M:N junction table mapping employees to games with project roles.
-- ----------------------------------------------------------------------------
CREATE TABLE GamesEmployees (
    game_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (game_id, employee_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Table 09: GamePlatforms
-- Description: M:N junction table mapping games to target platforms & launch dates.
-- ----------------------------------------------------------------------------
CREATE TABLE GamePlatforms (
    game_id INTEGER NOT NULL,
    platform_id INTEGER NOT NULL,
    release_date DATE NOT NULL,
    PRIMARY KEY (game_id, platform_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES Platforms(platform_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================================
-- SECONDARY PERFORMANCE INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_employees_team ON Employees(team_id);
CREATE INDEX IF NOT EXISTS idx_features_game_status ON Features(game_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_feature_status ON Tasks(feature_id, status);
CREATE INDEX IF NOT EXISTS idx_releases_game ON Releases(game_id);
CREATE INDEX IF NOT EXISTS idx_gameplatforms_game_date ON GamePlatforms(game_id, release_date);
