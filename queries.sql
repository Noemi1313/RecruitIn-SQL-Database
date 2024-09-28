-- Typical SQL queries for RecruitIn database

-- Find a candidate's information with their first and last name
SELECT *
FROM "candidates"
WHERE "first_name" = 'Anabeth'
AND "last_name" = 'Chase';

-- Find job openings information with a given posting title
SELECT *
FROM "job_openings"
WHERE "posting_title" = 'Data Scientist';

-- Find interviews with a range of schedule dates
SELECT *
FROM "interviews"
WHERE "from" >= '2024-09-27 15:00:00'
AND "to" <= '2024-09-27 15:30:00';

-- Find which job openings are associated to a candidate by their name
SELECT *
FROM "job_openings" 
WHERE "id" IN (
    SELECT "job_opening_id"
    FROM "associated_candidates"
    WHERE "candidate_id" = (
        SELECT "id"
        FROM "candidates"
        WHERE "first_name" = 'Anabeth'
        AND "last_name" = 'Chase'
    )
);

-- Find which interviews are associated to a candidate by their name
SELECT *
FROM "interviews" 
WHERE "candidate_id" IN (
    SELECT "id"
    FROM "candidates"
    WHERE "id" = (
        SELECT "id"
        FROM "candidates"
        WHERE "first_name" = 'Anabeth'
        AND "last_name" = 'Chase'
    )
);

-- Find which candidates are associated to a job opening by its posting title
SELECT *
FROM "candidates" 
WHERE "id" IN (
    SELECT "candidate_id"
    FROM "associated_candidates"
    WHERE "job_opening_id" = (
        SELECT "id"
        FROM "job_openings"
        WHERE "posting_title" = 'Data Scientist'
    )
);

-- Add a new recruiter
INSERT INTO "recruiters" ("first_name", "last_name", "username", "password", "permissions")
VALUES ('Percy', 'Jackson', 'percy@gmail.com', 'password', 'standard');

-- Add a new candidate
INSERT INTO "candidates" ("first_name", "last_name", "phone", "email")
VALUES ('Anabeth', 'Chase', '664-123-4567', 'anabeth@gmail.com');

-- Add a new department
INSERT INTO "departments" ("name", "director")
VALUES ('Grover', 'Talent Acquisition');

-- Add a new job opening
INSERT INTO "job_openings" ("department_id", "recruiter_id", "posting_title", "modality")
VALUES (1, 1, 'Data Scientist', 'WFH');

-- Add a new interview
INSERT INTO "interviews" ("candidate_id", "job_opening_id", "recruiter_id", "from", "to", "modality")
VALUES (1, 1, 1, '2024-09-27 15:00:00', '2024-09-27 15:30:00', 'video call');

-- Add a new associated candidates
INSERT INTO "associated_candidates" ("candidate_id", "job_opening_id")
VALUES (1, 1);

-- Add a fake log-in
INSERT INTO "current_user" ("user_id")
VALUES (1);


