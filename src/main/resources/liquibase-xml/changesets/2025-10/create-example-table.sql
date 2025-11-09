-- liquibase formatted sql

-- changeset liquibase:0
CREATE TABLE example_table (
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- rollback DROP TABLE example_table