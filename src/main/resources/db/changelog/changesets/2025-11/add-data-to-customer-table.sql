-- liquibase formatted sql

-- changeset pouya:2 dbms:postgresql labels:insert,customer
INSERT INTO customer (name) VALUES ('Pouya'), ('Lamego'), ('Atena');

-- rollback DELETE FROM customer where name in ('Pouya', 'Lamego', 'Atena')