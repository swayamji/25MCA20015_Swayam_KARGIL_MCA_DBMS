CREATE TABLE schema_violations (
    schema_id INT PRIMARY KEY,
    schema_name VARCHAR(30),
    violation_count INT
);

INSERT INTO schema_violations VALUES
    (1, 'Aarav',   0),
    (2, 'Mehul',   2),
    (3, 'Karan',   5),
    (4, 'Ishita',  9),
    (5, 'Nisha',  15);

-- Step 1: Categorize violations
SELECT
    schema_name,
    violation_count,
    CASE
        WHEN violation_count = 0            THEN 'No Violation'
        WHEN violation_count BETWEEN 1 AND 3 THEN 'Minor Violation'
        WHEN violation_count BETWEEN 4 AND 7 THEN 'Moderate Violation'
        ELSE                                     'Critical Violation'
    END AS violation_status
FROM schema_violations;


-- Step 2: Add approval status
ALTER TABLE schema_violations
ADD COLUMN approval_status VARCHAR(20);

UPDATE schema_violations
SET approval_status =
    CASE
        WHEN violation_count = 0  THEN 'Approved'
        WHEN violation_count <= 5 THEN 'Needs Review'
        ELSE                           'Rejected'
    END;

SELECT * FROM schema_violations;


-- Step 3: Conditional logic using DO block
DO $$
DECLARE
    v_count INT := 6;
BEGIN
    IF v_count = 0 THEN
        RAISE NOTICE 'No violations detected';
    ELSIF v_count <= 5 THEN
        RAISE NOTICE 'Minor violations – review required';
    ELSE
        RAISE NOTICE 'Critical violations – access denied';
    END IF;
END $$;


-- Step 4: Student grading example
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(30),
    marks INT
);

INSERT INTO students VALUES
    (1, 'Aarav', 88),
    (2, 'Mehul', 74),
    (3, 'Karan', 61),
    (4, 'Ishita',46),
    (5, 'Nisha', 32);

SELECT
    student_name,
    marks,
    CASE
        WHEN marks >= 80 THEN 'A'
        WHEN marks >= 70 THEN 'B'
        WHEN marks >= 60 THEN 'C'
        WHEN marks >= 40 THEN 'D'
        ELSE 'F'
    END AS grade
FROM students;


-- Step 5: Custom ordering using CASE
SELECT
    schema_name,
    violation_count
FROM schema_violations
ORDER BY
    CASE
        WHEN violation_count = 0  THEN 1
        WHEN violation_count <= 3 THEN 2
        WHEN violation_count <= 7 THEN 3
        ELSE 4
    END;
