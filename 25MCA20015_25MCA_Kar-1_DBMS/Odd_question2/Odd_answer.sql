--25MCA20015
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    Salary INT
);
INSERT INTO Employee (EmpID, EmpName, Salary) VALUES
(1, 'Swayam', 60000),
(2, 'Roshan', 45000),
(3, 'Sanchit', 52000),
(4, 'Aman', 40000),
(5, 'Rahul', 75000),
(6, 'Priya', 68000),
(7, 'Karan', 30000),
(8, 'Neha', 54000),
(9, 'Rohit', 49000),
(10, 'Ananya', 82000);

CREATE VIEW HighSalaryEmployees AS
SELECT EmpID, EmpName, Salary
FROM Employee
WHERE Salary > 50000;

SELECT * FROM HighSalaryEmployees;
