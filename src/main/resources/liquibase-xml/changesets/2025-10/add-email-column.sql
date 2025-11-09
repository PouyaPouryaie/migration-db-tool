-- liquibase formatted sql

-- changeset liquibase:1
-- precondition-sql-check expectedResult:0 SELECT count(*) FROM information_schema.columns WHERE table_name = 'example_table' AND column_name = 'email'
ALTER TABLE example_table ADD COLUMN email VARCHAR(255)

-- rollback ALTER TABLE example_table DROP COLUMN email

--tag v1.0