CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50),
    department_id INT
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50)
);

CREATE TABLE Enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

INSERT INTO Departments VALUES (101, 'CSE');
INSERT INTO Departments VALUES (102, 'IT');
INSERT INTO Departments VALUES (103, 'ECE');

INSERT INTO Students VALUES (1, 'Ankush', 101);
INSERT INTO Students VALUES (2, 'Riya', 102);
INSERT INTO Students VALUES (3, 'Karanpreet singh', 101);
INSERT INTO Students VALUES (4, 'Neha kumari', 103);

INSERT INTO Courses VALUES (10, 'DBMS');
INSERT INTO Courses VALUES (20, 'OS');
INSERT INTO Courses VALUES (30, 'AI');

INSERT INTO Enrollments VALUES (1, 10);
INSERT INTO Enrollments VALUES (1, 20);
INSERT INTO Enrollments VALUES (2, 10);
INSERT INTO Enrollments VALUES (3, 30);

-- /*Inner join*/
SELECT s.name, c.course_name
FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_id = c.course_id;

-- /*Left join*/
SELECT s.name
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- /*Right join*/
SELECT c.course_name, s.name
FROM Students s
RIGHT JOIN Enrollments e ON s.student_id = e.student_id
RIGHT JOIN Courses c ON e.course_id = c.course_id;

-- /*Multiple join*/
SELECT s.name, d.dept_name
FROM Students s
JOIN Departments d ON s.department_id = d.department_id;

-- /*cross join*/
SELECT s.name, c.course_name
FROM Students s
CROSS JOIN Courses c;
