-- liquibase formatted sql

-- changeset pouya:2 labels:insert,customer
INSERT INTO customer (name) VALUES ('Pouya'), ('Lamego'), ('Atena');

-- rollback DELETE FROM customer where name in ('Pouya', 'Lamego', 'Atena')