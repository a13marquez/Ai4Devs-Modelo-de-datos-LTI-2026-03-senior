-- CreateEnum: PositionStatus
CREATE TYPE "PositionStatus" AS ENUM ('open', 'closed', 'paused', 'draft');

-- CreateEnum: ApplicationStatus
CREATE TYPE "ApplicationStatus" AS ENUM ('submitted', 'reviewed', 'interview', 'rejected', 'accepted');

-- CreateEnum: InterviewResult
CREATE TYPE "InterviewResult" AS ENUM ('pending', 'passed', 'failed', 'no_show');

-- CreateTable: Company
CREATE TABLE "company" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL
);

-- CreateTable: InterviewType
CREATE TABLE "interview_type" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT
);

-- CreateTable: InterviewFlow
CREATE TABLE "interview_flow" (
    "id" SERIAL PRIMARY KEY,
    "description" TEXT
);

-- CreateTable: Employee
CREATE TABLE "employee" (
    "id" SERIAL PRIMARY KEY,
    "company_id" INT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL UNIQUE,
    "role" VARCHAR(50) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT "employee_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable: InterviewStep
CREATE TABLE "interview_step" (
    "id" SERIAL PRIMARY KEY,
    "interview_flow_id" INT NOT NULL,
    "interview_type_id" INT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "order_index" INT NOT NULL,
    CONSTRAINT "interview_step_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flow"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "interview_step_interview_type_id_fkey" FOREIGN KEY ("interview_type_id") REFERENCES "interview_type"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "interview_step_interview_flow_id_order_index_key" UNIQUE ("interview_flow_id", "order_index")
);

-- CreateTable: Position
CREATE TABLE "position" (
    "id" SERIAL PRIMARY KEY,
    "company_id" INT NOT NULL,
    "interview_flow_id" INT NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "PositionStatus" NOT NULL DEFAULT 'open',
    "is_visible" BOOLEAN NOT NULL DEFAULT true,
    "location" VARCHAR(255),
    "job_description" TEXT,
    "requirements" TEXT,
    "responsibilities" TEXT,
    "salary_min" DECIMAL(12, 2),
    "salary_max" DECIMAL(12, 2),
    "employment_type" VARCHAR(50),
    "benefits" TEXT,
    "company_description" TEXT,
    "application_deadline" TIMESTAMP,
    "contact_info" VARCHAR(255),
    CONSTRAINT "position_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "position_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flow"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "position_salary_max_check" CHECK ("salary_max" IS NULL OR "salary_min" IS NULL OR "salary_max" >= "salary_min")
);

-- CreateTable: Application
CREATE TABLE "application" (
    "id" SERIAL PRIMARY KEY,
    "position_id" INT NOT NULL,
    "candidate_id" INT NOT NULL,
    "application_date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "ApplicationStatus" NOT NULL DEFAULT 'submitted',
    "notes" TEXT,
    CONSTRAINT "application_position_id_fkey" FOREIGN KEY ("position_id") REFERENCES "position"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "application_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidate"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "application_position_id_candidate_id_key" UNIQUE ("position_id", "candidate_id")
);

-- CreateTable: Interview
CREATE TABLE "interview" (
    "id" SERIAL PRIMARY KEY,
    "application_id" INT NOT NULL,
    "interview_step_id" INT NOT NULL,
    "employee_id" INT NOT NULL,
    "interview_date" TIMESTAMP NOT NULL,
    "result" "InterviewResult",
    "score" INT,
    "notes" TEXT,
    CONSTRAINT "interview_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "application"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "interview_interview_step_id_fkey" FOREIGN KEY ("interview_step_id") REFERENCES "interview_step"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "interview_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "interview_score_check" CHECK ("score" IS NULL OR ("score" >= 1 AND "score" <= 10))
);

-- CreateIndex: Employee company_id
CREATE INDEX "employee_company_id_idx" ON "employee"("company_id");

-- CreateIndex: InterviewStep interview_flow_id
CREATE INDEX "interview_step_interview_flow_id_idx" ON "interview_step"("interview_flow_id");

-- CreateIndex: Position company_id
CREATE INDEX "position_company_id_idx" ON "position"("company_id");

-- CreateIndex: Position interview_flow_id
CREATE INDEX "position_interview_flow_id_idx" ON "position"("interview_flow_id");

-- CreateIndex: Position status
CREATE INDEX "position_status_idx" ON "position"("status");

-- CreateIndex: Application position_id
CREATE INDEX "application_position_id_idx" ON "application"("position_id");

-- CreateIndex: Application candidate_id
CREATE INDEX "application_candidate_id_idx" ON "application"("candidate_id");

-- CreateIndex: Interview application_id
CREATE INDEX "interview_application_id_idx" ON "interview"("application_id");

-- CreateIndex: Interview interview_step_id
CREATE INDEX "interview_interview_step_id_idx" ON "interview"("interview_step_id");

-- CreateIndex: Interview employee_id
CREATE INDEX "interview_employee_id_idx" ON "interview"("employee_id");