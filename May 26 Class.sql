-- May 26 2023 Class

CREATE SCHEMA test_schema;
CREATE TABLE test_schema.professors(
    name VARCHAR(255),
    age INTEGER
);
INSERT INTO test_schema.professors(name, age)
VALUES ('Alex', 36);

INSERT INTO test_schema.professors(name, age)
VALUES ('Dalina', 35);

INSERT INTO test_schema.professors(name, age)
VALUES ('David', 26);

DELETE FROM test_schema.professors
WHERE name = 'David'
AND age = 26;

DELETE FROM test_schema.professors
WHERE name = 'David';

DROP TABLE test_schema.professors;

DROP SCHEMA  test_schema;

CREATE SCHEMA IF NOT EXISTS schulich;
CREATE TABLE schulich.instructors(
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    age INTEGER
);
-- DROP TABLE schulich.instructors;
INSERT INTO schulich.instructors(first_name, last_name, age)
VALUES ('Alex', 'Preciado', 39);

INSERT INTO schulich.instructors(first_name, last_name, age)
VALUES ('Dalina', 'Ivanova', 35);

INSERT INTO schulich.instructors(first_name, age)
VALUES ('David', 67);

UPDATE schulich.instructors
SET age = 33
WHERE first_name = 'Dalina' and last_name = 'Ivanova';

UPDATE schulich.instructors
SET last_name = 'Elsner'
WHERE first_name = 'David' and age = 67;

-- ADD column
ALTER TABLE schulich.instructors
ADD COLUMN instructor_id INTEGER;

UPDATE schulich.instructors
SET instructor_id = 1
WHERE first_name = 'Alex';

UPDATE schulich.instructors
SET instructor_id = 2
WHERE first_name = 'Dalina';

UPDATE schulich.instructors
SET instructor_id = 3
WHERE first_name = 'David';

SELECT * FROM schulich.instructors;
SELECT first_name, last_name  FROM schulich.instructors;
SELECT last_name , first_name FROM schulich.instructors;
SELECT COUNT(*) FROM schulich.instructors;
SELECT COUNT(DISTINCT first_name) FROM schulich.instructors;
SELECT AVG(age) FROM schulich.instructors;


