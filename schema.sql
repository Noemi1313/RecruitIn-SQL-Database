-- Schema for RecruitIn database

-- Table for Recruiter users
CREATE TABLE "recruiters" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL, -- should be hashed
    "permissions" TEXT NOT NULL CHECK("permissions" IN ('admin', 'standard')),
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
); 

-- Table for Candidates
CREATE TABLE "candidates" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "linkedin_username" TEXT,
    "status" TEXT NOT NULL DEFAULT 'new' CHECK("status" IN ('new', 'screening', 'interview', 'offered', 'hired')),
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
); 

-- Table for Departments
CREATE TABLE "departments" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "director" TEXT NOT NULL,
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
); 

-- Table for Job Openings
CREATE TABLE "job_openings" (
    "id" INTEGER,
    "department_id" INTEGER NOT NULL,
    "recruiter_id" INTEGER NOT NULL,
    "posting_title" TEXT NOT NULL,
    "modality" TEXT NOT NULL CHECK("modality" IN ('on site', 'hybrid', 'WFH')),
    "job_description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'in-progress' CHECK("status" IN ('in-progress', 'filled', 'cancelled', 'on-hold')),
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("department_id") REFERENCES "departments"("id"),
    FOREIGN KEY("recruiter_id") REFERENCES "recruiters"("id")
); 

-- Table for Interviews
CREATE TABLE "interviews" (
    "id" INTEGER,
    "candidate_id" INTEGER NOT NULL,
    "job_opening_id" INTEGER NOT NULL,
    "recruiter_id" INTEGER NOT NULL,
    "from" DATETIME NOT NULL,
    "to" DATETIME NOT NULL,
    "modality" TEXT NOT NULL CHECK("modality" IN ('on site', 'video call')),
    "comments" TEXT,
    "rating" INTEGER CHECK (rating IN (1, 2, 3, 4, 5)),
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("candidate_id") REFERENCES "candidates"("id"),
    FOREIGN KEY("job_opening_id") REFERENCES "job_openings"("id"),
    FOREIGN KEY("recruiter_id") REFERENCES "users"("id")
); 

-- Table for candidates associated to one or more job openings or viceversa
CREATE TABLE "associated_candidates" (
    "candidate_id" INTEGER NOT NULL,
    "job_opening_id" INTEGER NOT NULL,
    "created_time" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("candidate_id", "job_opening_id"),
    FOREIGN KEY("candidate_id") REFERENCES "candidates"("id"),
    FOREIGN KEY("job_opening_id") REFERENCES "job_openings"("id")
); 


-- Create indexes to speed common searches
CREATE INDEX "candidate_name_search" ON "candidates" ("first_name", "last_name");
CREATE INDEX "job_opening_name_search" ON "job_openings" ("posting_title");
CREATE INDEX "interviews_date_search" ON "interviews" ("from", "to");


-- Triggers to prevent not admin users from deleting most important tables

-- Temp table to simulate a user log-in
CREATE TABLE "current_user" (
    "user_id" INT NOT NULL,
    FOREIGN KEY("user_id") REFERENCES "recruiters"("id")
);
-- Insert a test recruiter to assign to the trigger
INSERT INTO "recruiters" ("first_name", "last_name", "username", "password", "permissions")
VALUES ('John', 'Doe', 'admin', 'password', 'admin');
-- Insert the current user into the table to create the trigger
INSERT INTO "current_user" ("user_id")
VALUES (1); 

-- Create the triggers
CREATE TRIGGER prevent_delete_candidates
BEFORE DELETE ON "candidates"
BEGIN
    SELECT RAISE(ABORT, 'Permission denied: Only admins can delete rows.')
    WHERE (SELECT "permissions" FROM "recruiters" 
           WHERE "id" = (SELECT "user_id" FROM "current_user")) <> 'admin';
END;

CREATE TRIGGER prevent_delete_job_openings
BEFORE DELETE ON "job_openings"
BEGIN
    SELECT RAISE(ABORT, 'Permission denied: Only admins can delete rows.')
    WHERE (SELECT "permissions" FROM "recruiters" 
           WHERE "id" = (SELECT "user_id" FROM "current_user")) <> 'admin';
END;

CREATE TRIGGER prevent_delete_interviews
BEFORE DELETE ON "interviews"
BEGIN
    SELECT RAISE(ABORT, 'Permission denied: Only admins can delete rows.')
    WHERE (SELECT "permissions" FROM "recruiters" 
           WHERE "id" = (SELECT "user_id" FROM "current_user")) <> 'admin';
END;
