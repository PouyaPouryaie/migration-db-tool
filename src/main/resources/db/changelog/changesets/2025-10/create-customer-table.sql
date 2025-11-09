-- liquibase formatted sql

-- changeset pouya:0
CREATE TABLE customer (
   id serial PRIMARY KEY,
   name varchar(255) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- rollback DROP TABLE customer