-- ============================================================================
-- Staging Layer: SIS (Student Information System) Source Tables
-- ============================================================================
--
-- Purpose of the staging layer:
--   The staging schema holds a structural, one-to-one landing copy of data
--   as it exists in the source system, before any cleaning, conforming, or
--   modeling into the warehouse layer occurs. Staging tables are not meant
--   to be queried by end users or BI tools; they exist to give downstream
--   ETL/ELT processes a stable, source-shaped starting point.
--
-- Why staging preserves source-system identifiers:
--   Source-system primary keys (e.g., student_id, section_id) are kept as
--   the primary keys in staging, rather than immediately generating
--   warehouse surrogate keys. This preserves full traceability back to the
--   originating SIS records, allows reconciliation/auditing against the
--   source, and supports reliable re-extraction and reprocessing without
--   losing the ability to match records to their origin.
--
-- Scope of this script:
--   These tables model SYNTHETIC SIS operational data only, as defined in
--   docs/data_dictionary/sis_source_schema.md. No real student, program,
--   term, course, section, or enrollment data is created, loaded, or
--   implied by this DDL. This script defines structure only.
--
-- Relationship to raw source files:
--   Staging receives validated but otherwise source-shaped records; the
--   immutable source files they are derived from are preserved as-is in
--   data/raw/. Staging does not replace or alter those raw files — it is a
--   loaded, queryable copy of the same records for downstream processing.
--
-- ============================================================================

CREATE TABLE IF NOT EXISTS staging.sis_students (
    student_id           VARCHAR PRIMARY KEY,
    first_name           VARCHAR NOT NULL,
    last_name            VARCHAR NOT NULL,
    date_of_birth        DATE NOT NULL,
    institutional_email  VARCHAR NOT NULL,
    personal_email       VARCHAR
);

CREATE TABLE IF NOT EXISTS staging.sis_programs (
    program_id       VARCHAR PRIMARY KEY,
    program_code     VARCHAR NOT NULL,
    program_name     VARCHAR NOT NULL,
    department_code  VARCHAR NOT NULL,
    degree_level     VARCHAR NOT NULL,
    active_flag      BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS staging.sis_terms (
    term_id        VARCHAR PRIMARY KEY,
    term_name      VARCHAR NOT NULL,
    academic_year  VARCHAR NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS staging.sis_courses (
    course_id        VARCHAR PRIMARY KEY,
    course_code      VARCHAR NOT NULL,
    course_name      VARCHAR NOT NULL,
    department_code  VARCHAR NOT NULL,
    credit_hours     NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS staging.sis_sections (
    section_id      VARCHAR PRIMARY KEY,
    course_id       VARCHAR NOT NULL REFERENCES staging.sis_courses (course_id),
    term_id         VARCHAR NOT NULL REFERENCES staging.sis_terms (term_id),
    section_number  VARCHAR NOT NULL,
    instructor_id   VARCHAR,
    meeting_days    VARCHAR,
    start_time      TIME,
    room            VARCHAR
);

CREATE TABLE IF NOT EXISTS staging.sis_enrollments (
    enrollment_id      VARCHAR PRIMARY KEY,
    student_id         VARCHAR NOT NULL REFERENCES staging.sis_students (student_id),
    program_id         VARCHAR NOT NULL REFERENCES staging.sis_programs (program_id),
    term_id            VARCHAR NOT NULL REFERENCES staging.sis_terms (term_id),
    enrollment_status  VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS staging.sis_course_enrollments (
    course_enrollment_id  VARCHAR PRIMARY KEY,
    student_id            VARCHAR NOT NULL REFERENCES staging.sis_students (student_id),
    section_id            VARCHAR NOT NULL REFERENCES staging.sis_sections (section_id),
    enrollment_status     VARCHAR NOT NULL
);

-- ============================================================================
-- Expected Relationship Structure
-- ============================================================================
--
-- sis_students            (no foreign keys)
-- sis_programs            (no foreign keys)
-- sis_terms               (no foreign keys)
-- sis_courses             (no foreign keys)
--
-- sis_sections
--   course_id  -> sis_courses.course_id
--   term_id    -> sis_terms.term_id
--
-- sis_enrollments            (student's institutional/program enrollment for a term)
--   student_id -> sis_students.student_id
--   program_id -> sis_programs.program_id
--   term_id    -> sis_terms.term_id
--
-- sis_course_enrollments     (student's enrollment in a specific course section;
--                             resolves the many-to-many between students and sections)
--   student_id -> sis_students.student_id
--   section_id -> sis_sections.section_id
--
-- ============================================================================
