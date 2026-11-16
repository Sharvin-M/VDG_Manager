-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Script
-- Project Title: VDG Manager: Video Game Development Studio Management System
-- Team Members: Sharvin Manjrekar, Aulissa Beasley
-- File: Checkpoint2-script.sql
-- ============================================================================

-- ============================================================================
-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- ============================================================================
-- 1. Schema Normalization & ERD Alignment: Finalized the 9-table relational 
--    schema (Teams, Employees, Games, Platforms, Features, Tasks, Releases, 
--    GamesEmployees, and GamePlatforms) to directly match the 7 entities and 
--    6 relationships (four 1:N and two M:N) in the Checkpoint 1 ER diagram.
-- 2. Domain & Integrity Constraints: Added CHECK constraints on workflow status 
--    columns and 1-to-5 priority bounds across Games, Features, Tasks, and 
--    Releases, as well as a composite UNIQUE(game_id, version) on Releases.
-- 3. Performance Indexes Added: Added secondary B-Tree indexes on 
--    Employees(team_id), Features(game_id, status), Tasks(feature_id, status), 
--    Releases(game_id), and GamePlatforms(game_id, release_date) to optimize 
--    join and filtering performance.
-- 4. Trigger & View Integration: Added automated triggers to mark parent 
--    Features as 'Completed' when all child Tasks finish and to promote Game 
--    status upon version 1.0 release, plus a studio production dashboard view.
-- ============================================================================

-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: Sharvin Manjrekar: 100%, Aulissa Beasley: 0%
-- Statement 02: Aulissa Beasley: 100%, Sharvin Manjrekar: 0%
-- Statement 03: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- Statement 04: Aulissa Beasley: 70%, Sharvin Manjrekar: 30%
-- Statement 05: Sharvin Manjrekar: 60%, Aulissa Beasley: 40%
-- Statement 06: Aulissa Beasley: 100%, Sharvin Manjrekar: 0%
-- Statement 07: Sharvin Manjrekar: 100%, Aulissa Beasley: 0%
-- Statement 08: Aulissa Beasley: 50%, Sharvin Manjrekar: 50%
-- Statement 09: Sharvin Manjrekar: 80%, Aulissa Beasley: 20%
-- Statement 10: Aulissa Beasley: 60%, Sharvin Manjrekar: 40%
--
-- SECTION 2: INTERMEDIATE STATEMENTS
-- Statement 11: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- Statement 12: Aulissa Beasley: 70%, Sharvin Manjrekar: 30%
-- Statement 13: Sharvin Manjrekar: 60%, Aulissa Beasley: 40%
-- Statement 14: Aulissa Beasley: 50%, Sharvin Manjrekar: 50%
-- Statement 15: Sharvin Manjrekar: 70%, Aulissa Beasley: 30%
-- Statement 16: Aulissa Beasley: 60%, Sharvin Manjrekar: 40%
-- Statement 17: Sharvin Manjrekar: 80%, Aulissa Beasley: 20%
-- Statement 18: Aulissa Beasley: 50%, Sharvin Manjrekar: 50%
-- Statement 19: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- Statement 20: Aulissa Beasley: 100%, Sharvin Manjrekar: 0%
-- Statement 21: Sharvin Manjrekar: 60%, Aulissa Beasley: 40%
--
-- SECTION 3: COMPLEX STATEMENTS
-- Statement 22: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- Statement 23: Aulissa Beasley: 70%, Sharvin Manjrekar: 30%
-- Statement 24: Sharvin Manjrekar: 70%, Aulissa Beasley: 30%
-- Statement 25: Aulissa Beasley: 50%, Sharvin Manjrekar: 50%
-- Statement 26: Sharvin Manjrekar: 60%, Aulissa Beasley: 40%
-- Statement 27: Aulissa Beasley: 80%, Sharvin Manjrekar: 20%
-- Statement 28: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- Statement 29: Aulissa Beasley: 50%, Sharvin Manjrekar: 50%
-- Statement 30: Sharvin Manjrekar: 70%, Aulissa Beasley: 30%
-- Statement 31: Aulissa Beasley: 60%, Sharvin Manjrekar: 40%
-- Statement 32: Sharvin Manjrekar: 50%, Aulissa Beasley: 50%
-- ============================================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column


-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS (Statements 1 to 10)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 01: Active Games in Development, Alpha, or Beta
-- Explanation: Retrieve the title, genre, start date, and current status of 
--              all games actively in development, alpha, or beta stages.
-- ----------------------------------------------------------------------------
SELECT title, genre, start_date, status
FROM Games
WHERE status IN ('In Development', 'Alpha', 'Beta')
ORDER BY start_date ASC;

-- ----------------------------------------------------------------------------
-- Statement 02: High-Priority Feature Backlog Filter
-- Explanation: Find the feature ID, feature name, status, and priority rating 
--              of all game features with a priority level of 4 or higher.
-- ----------------------------------------------------------------------------
SELECT feature_id, feature_name, status, priority
FROM Features
WHERE priority >= 4
ORDER BY priority DESC, feature_name ASC;

-- ----------------------------------------------------------------------------
-- Statement 03: Distinct Game Genres and Production Statuses
-- Explanation: List all unique game genre and production status combinations 
--              present in the studio catalog to verify portfolio diversity.
-- ----------------------------------------------------------------------------
SELECT DISTINCT genre, status
FROM Games
ORDER BY genre ASC;

-- ----------------------------------------------------------------------------
-- Statement 04: Senior and Lead Developer Directory Search
-- Explanation: Find all studio employees whose job title contains 'Lead' or 
--              'Senior', or who were hired prior to January 1, 2023.
-- ----------------------------------------------------------------------------
SELECT employee_id, name, email, role, hire_date
FROM Employees
WHERE role LIKE '%Lead%' OR role LIKE '%Senior%' OR hire_date < '2023-01-01'
ORDER BY hire_date ASC;

-- ----------------------------------------------------------------------------
-- Statement 05: Aggregate Task Priority and Deadline Metrics
-- Explanation: Compute the total count of production tasks, the earliest and 
--              latest task deadlines, and the average task priority level.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_tasks,
    MIN(due_date) AS earliest_deadline,
    MAX(due_date) AS latest_deadline,
    ROUND(AVG(priority), 2) AS average_task_priority
FROM Tasks;

-- ----------------------------------------------------------------------------
-- Statement 06: Insert New Hardware Platform
-- Explanation: Insert a new next-generation handheld hardware platform into 
--              the Platforms catalog for upcoming portable game releases.
-- ----------------------------------------------------------------------------
INSERT INTO Platforms (platform_id, name, manufacturer)
VALUES (8, 'Switch 2', 'Nintendo');

-- ----------------------------------------------------------------------------
-- Statement 07: Insert New Studio Employee Profile
-- Explanation: Record a newly hired Gameplay Programmer into the Employees 
--              registry assigned to the Core Engine Syndicate team.
-- ----------------------------------------------------------------------------
INSERT INTO Employees (employee_id, name, email, role, hire_date, team_id)
VALUES (116, 'Jin Sakai', 'jsakai@vdgstudio.com', 'Gameplay Programmer', '2026-11-01', 1);

-- ----------------------------------------------------------------------------
-- Statement 08: Update Employee Role Assignment
-- Explanation: Promote employee 104 to Principal Technical Artist and update 
--              their current studio role title.
-- ----------------------------------------------------------------------------
UPDATE Employees
SET role = 'Principal Technical Artist'
WHERE employee_id = 104;

-- ----------------------------------------------------------------------------
-- Statement 09: Bulk Escalate Priority for Near-Term Tasks
-- Explanation: Increase the priority level by 1 for all incomplete tasks due 
--              before June 1, 2026 that currently have a priority below 5.
-- ----------------------------------------------------------------------------
UPDATE Tasks
SET priority = priority + 1
WHERE status != 'Completed'
  AND due_date < '2026-06-01'
  AND priority < 5;

-- ----------------------------------------------------------------------------
-- Statement 10: Delete Cancelled Prototype Releases
-- Explanation: Remove cancelled early prototype build entries (version 0.0.x) 
--              from the Releases table to maintain a clean build history.
-- ----------------------------------------------------------------------------
DELETE FROM Releases
WHERE status = 'Cancelled' AND version LIKE '0.0.%';


-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS (Statements 11 to 21)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 11: Employees with Department Team Details (2-Table Inner Join)
-- Explanation: Retrieve all studio employees alongside their assigned team 
--              name and department classification.
-- ----------------------------------------------------------------------------
SELECT 
    E.employee_id,
    E.name AS employee_name,
    E.role AS studio_role,
    T.team_name,
    T.department
FROM Employees E
JOIN Teams T ON E.team_id = T.team_id
ORDER BY T.department ASC, E.name ASC;

-- ----------------------------------------------------------------------------
-- Statement 12: Game Feature and Task Breakdown Pipeline (Multi-Table Join)
-- Explanation: List all development tasks across games, displaying the game 
--              title, parent feature name, task name, status, and due date.
-- ----------------------------------------------------------------------------
SELECT 
    G.title AS game_title,
    F.feature_name,
    TK.task_name,
    TK.status AS task_status,
    TK.priority AS task_priority,
    TK.due_date
FROM Tasks TK
JOIN Features F ON TK.feature_id = F.feature_id
JOIN Games G ON F.game_id = G.game_id
ORDER BY G.title ASC, TK.priority DESC, TK.due_date ASC;

-- ----------------------------------------------------------------------------
-- Statement 13: Feature and Task Scope Aggregation per Game
-- Explanation: Summarize each game project with its total number of features, 
--              total decomposed tasks, and calculated average task priority.
-- ----------------------------------------------------------------------------
SELECT 
    G.game_id,
    G.title AS game_title,
    G.status AS game_status,
    COUNT(DISTINCT F.feature_id) AS total_features,
    COUNT(TK.task_id) AS total_tasks,
    ROUND(AVG(TK.priority), 2) AS avg_task_priority
FROM Games G
JOIN Features F ON G.game_id = F.game_id
JOIN Tasks TK ON F.feature_id = TK.feature_id
GROUP BY G.game_id, G.title, G.status
ORDER BY total_tasks DESC;

-- ----------------------------------------------------------------------------
-- Statement 14: Department Teams with Heavy Staffing (GROUP BY & HAVING)
-- Explanation: Identify functional teams that have at least 3 assigned staff 
--              members and find the earliest employee hire date in each team.
-- ----------------------------------------------------------------------------
SELECT 
    T.team_id,
    T.team_name,
    T.department,
    COUNT(E.employee_id) AS staff_count,
    MIN(E.hire_date) AS senior_most_hire_date
FROM Teams T
JOIN Employees E ON T.team_id = E.team_id
GROUP BY T.team_id, T.team_name, T.department
HAVING COUNT(E.employee_id) >= 3
ORDER BY staff_count DESC;

-- ----------------------------------------------------------------------------
-- Statement 15: Multi-Platform Games Distribution (GROUP BY & HAVING)
-- Explanation: Count how many target platforms each game is scheduled to 
--              launch on, filtering for games targeting 3 or more platforms.
-- ----------------------------------------------------------------------------
SELECT 
    G.game_id,
    G.title,
    G.genre,
    COUNT(GP.platform_id) AS target_platforms_count,
    MIN(GP.release_date) AS initial_launch_date,
    MAX(GP.release_date) AS final_port_date
FROM Games G
JOIN GamePlatforms GP ON G.game_id = GP.game_id
GROUP BY G.game_id, G.title, G.genre
HAVING COUNT(GP.platform_id) >= 3
ORDER BY target_platforms_count DESC;

-- ----------------------------------------------------------------------------
-- Statement 16: Unassigned Employees Without Game Projects (LEFT OUTER JOIN)
-- Explanation: Identify employees in the studio directory who are not currently 
--              assigned to any game project by using a left outer join.
-- ----------------------------------------------------------------------------
SELECT 
    E.employee_id,
    E.name,
    E.role,
    E.email,
    GE.game_id
FROM Employees E
LEFT JOIN GamesEmployees GE ON E.employee_id = GE.employee_id
WHERE GE.game_id IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 17: Tasks Prioritized Above Their Feature Average (Scalar Subquery)
-- Explanation: Find all tasks whose priority rating is strictly higher than 
--              the average priority of all tasks within their parent feature.
-- ----------------------------------------------------------------------------
SELECT 
    TK1.task_id,
    TK1.task_name,
    TK1.feature_id,
    TK1.priority,
    TK1.status
FROM Tasks TK1
WHERE TK1.priority > (
    SELECT AVG(TK2.priority)
    FROM Tasks TK2
    WHERE TK2.feature_id = TK1.feature_id
)
ORDER BY TK1.feature_id ASC, TK1.priority DESC;

-- ----------------------------------------------------------------------------
-- Statement 18: Cross-Functional Staffing Breakdown per Game
-- Explanation: Calculate the total number of assigned personnel and distinct 
--              studio departments contributing to each active game title.
-- ----------------------------------------------------------------------------
SELECT 
    G.game_id,
    G.title,
    G.status,
    COUNT(GE.employee_id) AS assigned_employees,
    COUNT(DISTINCT T.department) AS departments_involved
FROM Games G
JOIN GamesEmployees GE ON G.game_id = GE.game_id
JOIN Employees E ON GE.employee_id = E.employee_id
JOIN Teams T ON E.team_id = T.team_id
GROUP BY G.game_id, G.title, G.status
ORDER BY assigned_employees DESC;

-- ----------------------------------------------------------------------------
-- Statement 19: Hardware Platform Lineup Coverage by Manufacturer
-- Explanation: Determine how many studio games target each hardware platform, 
--              including platforms that currently have zero scheduled games.
-- ----------------------------------------------------------------------------
SELECT 
    P.platform_id,
    P.name AS platform_name,
    P.manufacturer,
    COUNT(GP.game_id) AS scheduled_games_count,
    COALESCE(MIN(GP.release_date), 'No Launch Scheduled') AS earliest_release
FROM Platforms P
LEFT JOIN GamePlatforms GP ON P.platform_id = GP.platform_id
GROUP BY P.platform_id, P.name, P.manufacturer
ORDER BY scheduled_games_count DESC, P.name ASC;

-- ----------------------------------------------------------------------------
-- Statement 20: Advance Planned Features with Active Tasks (Subquery Update)
-- Explanation: Automatically transition features from 'Planned' to 'In Progress' 
--              when at least one of their child tasks is active or completed.
-- ----------------------------------------------------------------------------
UPDATE Features
SET status = 'In Progress'
WHERE status = 'Planned'
  AND feature_id IN (
      SELECT DISTINCT feature_id
      FROM Tasks
      WHERE status IN ('In Progress', 'Completed')
  );

-- ----------------------------------------------------------------------------
-- Statement 21: Games Not Scheduled for Mobile Platforms (Subquery IN)
-- Explanation: Find all games in the studio catalog that have not been 
--              scheduled for release on either iOS or Android platforms.
-- ----------------------------------------------------------------------------
SELECT game_id, title, genre, status
FROM Games
WHERE game_id NOT IN (
    SELECT GP.game_id
    FROM GamePlatforms GP
    JOIN Platforms P ON GP.platform_id = P.platform_id
    WHERE P.name IN ('iOS', 'Android')
)
ORDER BY game_id ASC;


-- ============================================================================
-- SECTION 3: COMPLEX STATEMENTS (Statements 22 to 32)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 22: Correlated Subquery with EXISTS (Blocked Task Bottleneck Alert)
-- Explanation: Find games that currently experience production bottlenecks 
--              where at least one high-priority child task is marked 'Blocked'.
-- ----------------------------------------------------------------------------
SELECT G.game_id, G.title, G.status
FROM Games G
WHERE EXISTS (
    SELECT 1
    FROM Features F
    JOIN Tasks TK ON F.feature_id = TK.feature_id
    WHERE F.game_id = G.game_id
      AND TK.status = 'Blocked'
      AND TK.priority >= 4
);

-- ----------------------------------------------------------------------------
-- Statement 23: Set Difference (EXCEPT) for Platform Exclusivity Comparison
-- Explanation: Find the IDs and titles of games scheduled for 'PC (Steam)' 
--              (Platform 1) but NOT scheduled for 'PlayStation 5' (Platform 2).
-- ----------------------------------------------------------------------------
SELECT G.game_id, G.title
FROM Games G
JOIN GamePlatforms GP ON G.game_id = GP.game_id
WHERE GP.platform_id = 1
EXCEPT
SELECT G.game_id, G.title
FROM Games G
JOIN GamePlatforms GP ON G.game_id = GP.game_id
WHERE GP.platform_id = 2;

-- ----------------------------------------------------------------------------
-- Statement 24: Set Intersection (INTERSECT) for Dual-Project Specialists
-- Explanation: Find employees who are simultaneously assigned to both Game 1 
--              ('Aether Chronicles') AND Game 2 ('Neon Drift 2099').
-- ----------------------------------------------------------------------------
SELECT E.employee_id, E.name, E.role
FROM Employees E
JOIN GamesEmployees GE ON E.employee_id = GE.employee_id
WHERE GE.game_id = 1
INTERSECT
SELECT E.employee_id, E.name, E.role
FROM Employees E
JOIN GamesEmployees GE ON E.employee_id = GE.employee_id
WHERE GE.game_id = 2;

-- ----------------------------------------------------------------------------
-- Statement 25: Set Union (UNION ALL) for Unified Studio Milestone Calendar
-- Explanation: Build a consolidated chronological release schedule combining 
--              internal version builds and external hardware platform launches.
-- ----------------------------------------------------------------------------
SELECT 
    G.title AS game_title,
    'VERSION BUILD: ' || R.version AS milestone_event,
    R.release_date AS event_date,
    R.status AS milestone_status
FROM Releases R
JOIN Games G ON R.game_id = G.game_id
UNION ALL
SELECT 
    G.title AS game_title,
    'PLATFORM LAUNCH: ' || P.name AS milestone_event,
    GP.release_date AS event_date,
    G.status AS milestone_status
FROM GamePlatforms GP
JOIN Games G ON GP.game_id = G.game_id
JOIN Platforms P ON GP.platform_id = P.platform_id
ORDER BY event_date ASC, game_title ASC;

-- ----------------------------------------------------------------------------
-- Statement 26: Common Table Expression (CTE) for Game Task Completion Rate
-- Explanation: Calculate total and completed task counts per game using a CTE, 
--              then compute the overall percentage of tasks completed.
-- ----------------------------------------------------------------------------
WITH GameTaskMetrics AS (
    SELECT 
        G.game_id,
        G.title,
        G.status,
        COUNT(TK.task_id) AS total_tasks,
        SUM(CASE WHEN TK.status = 'Completed' THEN 1 ELSE 0 END) AS completed_tasks
    FROM Games G
    LEFT JOIN Features F ON G.game_id = F.game_id
    LEFT JOIN Tasks TK ON F.feature_id = TK.feature_id
    GROUP BY G.game_id, G.title, G.status
)
SELECT 
    game_id,
    title,
    status,
    completed_tasks,
    total_tasks,
    CASE 
        WHEN total_tasks > 0 THEN ROUND((completed_tasks * 100.0) / total_tasks, 2)
        ELSE 0.0
    END AS completion_percentage
FROM GameTaskMetrics
ORDER BY completion_percentage DESC;

-- ----------------------------------------------------------------------------
-- Statement 27: Window Function (DENSE_RANK) for Feature Complexity Ranking
-- Explanation: Rank features within each game by their total task count and 
--              priority level using the DENSE_RANK() window function.
-- ----------------------------------------------------------------------------
SELECT 
    G.title AS game_title,
    F.feature_name,
    F.priority AS feature_priority,
    COUNT(TK.task_id) AS task_count,
    DENSE_RANK() OVER (
        PARTITION BY G.game_id 
        ORDER BY COUNT(TK.task_id) DESC, F.priority DESC
    ) AS complexity_rank_in_game
FROM Features F
JOIN Games G ON F.game_id = G.game_id
LEFT JOIN Tasks TK ON F.feature_id = TK.feature_id
GROUP BY G.game_id, G.title, F.feature_id, F.feature_name, F.priority;

-- ----------------------------------------------------------------------------
-- Statement 28: DDL View Creation for Studio Production Dashboard
-- Explanation: Create an administrative view joining games, staff assignments, 
--              features, tasks, and platforms to expose real-time project KPIs.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS View_StudioProductionDashboard;

CREATE VIEW View_StudioProductionDashboard AS
SELECT 
    G.game_id,
    G.title AS game_title,
    G.genre,
    G.status AS production_status,
    COUNT(DISTINCT GE.employee_id) AS assigned_staff_count,
    COUNT(DISTINCT F.feature_id) AS total_features,
    COUNT(DISTINCT TK.task_id) AS total_tasks,
    COUNT(DISTINCT GP.platform_id) AS target_platforms,
    MIN(GP.release_date) AS first_platform_launch
FROM Games G
LEFT JOIN GamesEmployees GE ON G.game_id = GE.game_id
LEFT JOIN Features F ON G.game_id = F.game_id
LEFT JOIN Tasks TK ON F.feature_id = TK.feature_id
LEFT JOIN GamePlatforms GP ON G.game_id = GP.game_id
GROUP BY G.game_id, G.title, G.genre, G.status;

-- ----------------------------------------------------------------------------
-- Statement 29: Query Against Studio Production Dashboard View
-- Explanation: Query the newly created View_StudioProductionDashboard to 
--              retrieve production metrics for games with 3 or more staff.
-- ----------------------------------------------------------------------------
SELECT 
    game_title,
    genre,
    production_status,
    assigned_staff_count,
    total_features,
    total_tasks,
    target_platforms,
    first_platform_launch
FROM View_StudioProductionDashboard
WHERE assigned_staff_count >= 3
ORDER BY total_tasks DESC;

-- ----------------------------------------------------------------------------
-- Statement 30: Automated Parent Feature Completion Trigger
-- Explanation: Create a trigger that automatically updates a feature's status 
--              to 'Completed' when its last remaining child task is completed.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_AutoCompleteFeatureOnTaskUpdate;

CREATE TRIGGER trg_AutoCompleteFeatureOnTaskUpdate
AFTER UPDATE OF status ON Tasks
FOR EACH ROW
WHEN NEW.status = 'Completed'
BEGIN
    UPDATE Features
    SET status = 'Completed'
    WHERE feature_id = NEW.feature_id
      AND NOT EXISTS (
          SELECT 1
          FROM Tasks
          WHERE feature_id = NEW.feature_id
            AND status != 'Completed'
      );
END;

-- ----------------------------------------------------------------------------
-- Statement 31: Automated Game Release Status Sync Trigger
-- Explanation: Create a trigger that automatically advances a game's status to 
--              'Released' when a version 1.x build is logged as 'Released'.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_PromoteGameStatusOnRelease;

CREATE TRIGGER trg_PromoteGameStatusOnRelease
AFTER INSERT ON Releases
FOR EACH ROW
WHEN NEW.status = 'Released' AND NEW.version LIKE '1.%'
BEGIN
    UPDATE Games
    SET status = 'Released'
    WHERE game_id = NEW.game_id
      AND status != 'Released';
END;

-- ----------------------------------------------------------------------------
-- Statement 32: Cross-Tab Analytics with CASE Expressions
-- Explanation: Perform a pivot summary of development tasks tallying counts 
--              across workflow states ('To Do' through 'Completed') per game.
-- ----------------------------------------------------------------------------
SELECT 
    G.game_id,
    G.title AS game_title,
    COUNT(CASE WHEN TK.status = 'To Do' THEN 1 END) AS todo_tasks,
    COUNT(CASE WHEN TK.status = 'In Progress' THEN 1 END) AS in_progress_tasks,
    COUNT(CASE WHEN TK.status = 'In Review' THEN 1 END) AS in_review_tasks,
    COUNT(CASE WHEN TK.status = 'Blocked' THEN 1 END) AS blocked_tasks,
    COUNT(CASE WHEN TK.status = 'Completed' THEN 1 END) AS completed_tasks,
    COUNT(TK.task_id) AS total_tasks
FROM Games G
LEFT JOIN Features F ON G.game_id = F.game_id
LEFT JOIN Tasks TK ON F.feature_id = TK.feature_id
GROUP BY G.game_id, G.title
ORDER BY total_tasks DESC;
