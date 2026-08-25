-- ============================================================================
-- Warehouse Star Schema: Institutional Enrollment (V1)
-- ============================================================================
--
-- Dimensional model purpose:
--   This schema is the first warehouse-layer star schema for the platform.
--   It restates validated, source-shaped staging.sis_* records (see
--   sql/staging/001_create_sis_staging.sql) as a dimensional model suited
--   to analytical querying: descriptive context is normalized into
--   dimension tables, and measurable/observable business events are
--   recorded in a fact table that references those dimensions.
--
-- Fact-table grain:
--   One row in warehouse.fact_enrollment represents one student's
--   institutional/program enrollment in one academic term (i.e., the same
--   grain as staging.sis_enrollments). It does NOT represent course/section
--   enrollment — that is a separate, finer-grained fact to be modeled later.
--   Stated precisely, the grain is: one student x one program x one
--   academic term.
--
-- enrollment_count semantics (IMPORTANT — do not misuse as headcount):
--   `enrollment_count` is an additive measure that is always 1 at this
--   grain — it counts fact/program-enrollment records, one per
--   student/program/term combination. It must NOT be automatically
--   interpreted as, or summed to produce, unique institutional student
--   headcount: because a student can hold multiple program enrollments in
--   the same term (e.g., a double major), SUM(enrollment_count) over a term
--   can exceed the number of distinct students enrolled that term.
--   Institutional student headcount is a governed business definition and
--   should be computed as COUNT(DISTINCT student_key) at the term level
--   (i.e., over fact_enrollment filtered/grouped by term_key), unless and
--   until a dedicated student-term fact (grain: one student x one term) is
--   introduced specifically for headcount reporting.
--
-- Surrogate keys vs. source/business keys:
--   Each dimension uses a warehouse-generated surrogate key
--   (`*_key`, BIGINT GENERATED ALWAYS AS IDENTITY) as its primary key and
--   as the join key used by the fact table. The originating SIS identifier
--   is preserved separately as a business key (`*_id`, UNIQUE, NOT NULL) so
--   that dimension rows remain traceable back to their source system.
--   Surrogate keys keep the warehouse independent of source-system key
--   formats/reuse and are what SCD history (not yet implemented) will key
--   off of.
--
-- Program history by term:
--   Program membership is time-variant, not a fixed attribute of a student,
--   so it is NOT stored on warehouse.dim_student (no `current_program`
--   column). Instead, each term's program enrollment is captured as its own
--   row in warehouse.fact_enrollment via `program_key`, preserving a full
--   history of program membership per student across terms.
--
-- department_key nullability:
--   warehouse.dim_department is not yet populated from an authoritative
--   source (the ERP/HCM source system is not yet implemented). Until that
--   reconciliation exists, `fact_enrollment.department_key` is nullable so
--   the V1 grain and fact loads are not blocked on a dimension this
--   platform cannot yet populate correctly.
--
-- Out of scope for this script:
--   SCD Type 2 history, LMS/CRM/ERP-HCM/IPEDS warehouse tables, and
--   analytics-layer views are intentionally not created here.
--
-- ============================================================================

CREATE TABLE IF NOT EXISTS warehouse.dim_student (
    student_key           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id             VARCHAR NOT NULL UNIQUE,
    first_name             VARCHAR NOT NULL,
    last_name              VARCHAR NOT NULL,
    date_of_birth          DATE NOT NULL,
    institutional_email    VARCHAR NOT NULL,
    personal_email         VARCHAR
);

CREATE TABLE IF NOT EXISTS warehouse.dim_program (
    program_key      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_id       VARCHAR NOT NULL UNIQUE,
    program_code     VARCHAR NOT NULL,
    program_name     VARCHAR NOT NULL,
    department_code  VARCHAR NOT NULL,
    degree_level     VARCHAR NOT NULL,
    active_flag      BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS warehouse.dim_term (
    term_key       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    term_id        VARCHAR NOT NULL UNIQUE,
    term_name      VARCHAR NOT NULL,
    academic_year  VARCHAR NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL
);

-- warehouse.dim_department is part of the target warehouse architecture, but
-- our ERP/HCM source system has not been implemented yet. This table is
-- created now only as a structural placeholder: it will later be populated
-- from the authoritative ERP/HCM source, and warehouse.dim_program's
-- department_code will eventually be reconciled to this canonical
-- department dimension. No department data is fabricated here.
CREATE TABLE IF NOT EXISTS warehouse.dim_department (
    department_key   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_code  VARCHAR NOT NULL UNIQUE,
    department_name  VARCHAR NOT NULL
);

-- Grain: one row = one student x one program x one academic term.
-- See "enrollment_count semantics" above before using enrollment_count (or
-- COUNT(*)/SUM(enrollment_count) over this table) as student headcount.
CREATE TABLE IF NOT EXISTS warehouse.fact_enrollment (
    enrollment_key       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_key          BIGINT NOT NULL REFERENCES warehouse.dim_student (student_key),
    program_key          BIGINT NOT NULL REFERENCES warehouse.dim_program (program_key),
    term_key             BIGINT NOT NULL REFERENCES warehouse.dim_term (term_key),
    department_key       BIGINT REFERENCES warehouse.dim_department (department_key),
    enrollment_status    VARCHAR NOT NULL,
    -- Additive count of fact/program-enrollment records; always 1 at this
    -- grain. NOT a proxy for unique institutional student headcount — see
    -- "enrollment_count semantics" in the header comment.
    enrollment_count     INTEGER NOT NULL DEFAULT 1,
    -- Intentionally permits the same student_key to appear more than once
    -- for the same term_key under different program_key values (e.g., a
    -- double major) — this constraint enforces the stated V1 grain, not
    -- one-row-per-student-per-term.
    CONSTRAINT uq_fact_enrollment_grain UNIQUE (student_key, program_key, term_key)
);
