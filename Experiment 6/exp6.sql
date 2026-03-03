CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary NUMERIC,
    status VARCHAR(10),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

INSERT INTO department VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee VALUES
(1, 'Roshan', 30000, 'Active', 2),
(2, 'Swayam', 40000, 'Active', 2),
(3, 'Riya', 25000, 'Inactive', 1),
(4, 'Ankush', 35000, 'Active', 3),
(5, 'Sanchit', 28000, 'Active', 1);

--1
CREATE VIEW active_employees AS
SELECT emp_id, emp_name, dept_id
FROM employee
WHERE status = 'Active';

SELECT * FROM active_employees;

--2

CREATE VIEW employee_department_view AS
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;

SELECT * FROM employee_department_view;

--3

CREATE VIEW department_summary AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS total_employees,
       AVG(e.salary) AS average_salary
FROM department d
JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM department_summary;
