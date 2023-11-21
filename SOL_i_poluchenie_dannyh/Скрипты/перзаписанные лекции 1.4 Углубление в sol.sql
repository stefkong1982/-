
CREATE DATABASE Lectur_4_k

CREATE SCHEMA Lectur_4

CREATE TABLE автор (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    кличка VARCHAR(100),
    "дата рождения" DATE NOT NULL,
    "дата создания" DATE
);

INSERT INTO автор (id, name, "дата рождения")
VALUES (1, 'Достоевский', '1860.03.31');

SELECT *
FROM автор

ALTER TABLE автор ADD COLUMN city VARCHAR(100);

UPDATE автор
SET city = 'Россия'
WHERE id = 1;

CREATE TABLE книги (
    id SERIAL PRIMARY KEY,
    название VARCHAR(100) NOT NULL,
    год INTEGER NOT NULL,
    автор_id INTEGER REFERENCES автор(id)
);


SELECT *
FROM произведения

INSERT INTO книги (автор_ID, "название", год) 
VALUES (1, 'Игрок', '1880');


DELETE FROM автор
WHERE id = 1

CREATE EXTENSION "uuid-ossp"



