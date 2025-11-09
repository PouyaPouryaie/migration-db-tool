-- liquibase formatted sql

-- changeset liquibase:2
INSERT INTO example_table (name) VALUES ('Pouya'), ('Lamego'), ('Atena');

-- rollback DELETE FROM example_table where name in ('Pouya', 'Lamego', 'Atena')