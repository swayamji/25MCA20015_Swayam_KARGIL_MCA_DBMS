CREATE TABLE employees4 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees4 VALUES
(1, 'Amit', NULL, 'Management', 120000),
(2, 'Ravi', 1, 'Engineering', 80000),
(3, 'Neha', 1, 'Engineering', 82000),
(4, 'Karan', 2, 'Engineering', 60000),
(5, 'Simran', 2, 'Engineering', 62000),
(6, 'Pooja', 3, 'Engineering', 61000),
(7, 'Rahul', 3, 'Engineering', 64000),
(8, 'Arjun', 1, 'HR', 70000);

CREATE OR REPLACE PROCEDURE update_salary(
    IN p_emp_id INT,
    INOUT p_salary NUMERIC(20,3),
    OUT status VARCHAR(30)
)
AS
$$
DECLARE
    curr_sal NUMERIC(20,3);
BEGIN

    SELECT salary INTO curr_sal
    FROM employees4
    WHERE emp_id = p_emp_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'EMPLOYEE NOT FOUND';
    END IF;

    curr_sal := curr_sal + p_salary;

    UPDATE employees4
    SET salary = curr_sal
    WHERE emp_id = p_emp_id;

    p_salary := curr_sal;
    status := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
        status := 'FAILED';
END;
$$ LANGUAGE plpgsql;

SELECT * FROM employees4
