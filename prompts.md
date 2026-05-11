## Prompt 1 (Opencode plan)
Act as a database schema agent.

Authoritative input: Mermaid ER diagram in `erDiagram` syntax.

Output: a single PostgreSQL SQL migration script and Prisma model changes.

Goal:
Convert the Mermaid ER diagram into database artifacts for backend/prisma.

Output structure:
1. Prisma models for backend/prisma/schema.prisma
2. Single migration SQL script for backend/prisma/migrations/<timestamp>_<name>/migration.sql

Constraints (detailed in refinement):
- PostgreSQL only
- One single migration
- Refer to the refining prompt for full normalization, constraints, indexes, and Prisma mapping rules.

## Prompt 2 (Opencode plan refinement)
Act as a database schema refinement agent operating in plan mode.

Authoritative inputs:
- Mermaid ER diagram from previous request
- existing Prisma schema in backend/prisma/schema.prisma

Goal:
Refine the change plan so the final implementation produces:
1. Prisma model changes in backend/prisma/schema.prisma
2. a single PostgreSQL migration SQL script in backend/prisma/migrations/<timestamp>_<name>/migration.sql

Scope guardrails:
- Refine only database schema decisions
- Do not design API endpoints, services, controllers, repositories, DTOs, or UI
- Do not propose seed data unless strictly required for a lookup table
- Do not split into multiple migrations
- Do not expand into performance tuning beyond justified indexes
- Do not introduce unrelated refactors

Normalization:
- Normalize to at least 3NF
- Preserve all entities, relationships, cardinalities unless strictly required for normalization or PostgreSQL

Constraints:
- PRIMARY KEY for every table
- FOREIGN KEY with ON DELETE / ON UPDATE
- NOT NULL for mandatory attributes
- UNIQUE for candidate/natural keys
- CHECK when domain rules are implied

Indexes:
- foreign key columns
- unique columns
- composite only when clearly justified
- remove redundant indexes

Prisma mapping:
- scalar vs relation fields
- required vs nullable
- enum candidates
- compound unique constraints and compound IDs
- relation annotations or mapped names
- snake_case naming

Output format:
1. Normalization decisions
2. Table and column design
3. Constraints and referential actions
4. Index plan
5. Prisma mapping notes
6. Assumptions and ambiguities
7. Migration sequencing

Do not produce SQL or schema artifacts. Produce only the refined plan.

## Prompt 3 (build mode)

Using the refined plan and Mermaid ER diagram, generate the exact database artifacts for Prisma + PostgreSQL.

Required deliverables:
- Prisma model changes for backend/prisma/schema.prisma
- a single PostgreSQL migration SQL script for backend/prisma/migrations/<timestamp>_<name>/migration.sql

Hard constraints:
- Output only database artifacts
- No API/repository/service/controller/tests/seed/docs beyond brief notes
- No multiple migrations
- No unrelated refactors
- No Mermaid diagrams
- No essays

Implementation rules:
- PostgreSQL only
- Single SQL migration script
- Compatible with Prisma Migrate review/edit
- Compatible with backend/prisma/schema.prisma
- Explicit constraints: PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK
- Indexes: foreign keys, unique fields, justified composites
- No redundant indexes
- Junction tables for many-to-many
- Safe PostgreSQL types and referential actions
- No entities/columns/relationships not supported by ERD or refined plan

Output:
1. Prisma models for backend/prisma/schema.prisma
2. Single migration SQL script for backend/prisma/migrations/<timestamp>_<name>/migration.sql

## Prompt 4 (review)

Review and refine the generated output without expanding scope.

Improvements only for:
- backend/prisma/schema.prisma changes
- the single PostgreSQL migration SQL script

Do not add new workstreams.

Criteria:
- Prisma models: names, fields, relations, enums, constraints, mapped names consistent
- SQL: valid, ordered correctly for table creation and FKs
- Constraints implicit and correct
- Referential actions appropriate
- Indexes on foreign keys and unique fields
- Composite indexes only if justified
- Redundant indexes removed
- Many-to-many correctly implemented
- Nullability matches ERD meaning
- Result remains a single migration SQL script

Output:
1. final backend/prisma/schema.prisma
2. final backend/prisma/migrations/<timestamp>_<name>/migration.sql

Do not expand scope. Do not add explanations beyond short notes for assumptions.

## Prompt 5 (Coderabbit)

Verify each finding against current code. Fix only still-valid issues, skip the
rest with a brief reason, keep changes minimal, and validate.

In
`@backend/prisma/migrations/20260512000000_initial_recruitment_schema/migration.sql`
at line 85, The current foreign key constraint application_position_id_fkey on
the application.position_id column uses ON DELETE CASCADE which will remove
applications (and downstream interviews) when a position is deleted; change the
migration to preserve historical data by either (A) replacing ON DELETE CASCADE
with ON DELETE RESTRICT on the CONSTRAINT "application_position_id_fkey" so
positions cannot be deleted while applications exist, or (B) implement
soft-deletes for the position entity (add/ensure a status/archived/deleted flag
on the position table and remove hard-deletes) and remove cascading behavior
from the FK so application records remain intact when a position is marked
deleted; update any application code that deletes positions to use the new
soft-delete flow if you choose option B.