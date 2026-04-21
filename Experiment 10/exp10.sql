CREATE TABLE Payroll (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2) CHECK(SALARY>0)
);



-- DROP TABLE PAYROLL

INSERT INTO Payroll VALUES
(1, 'Amit', 30000),
(2, 'Neha', 40000),
(3, 'Ravi', 50000);


SELECT * FROM PAYROLL

ROLLBACK;

BEGIN;

UPDATE Payroll
SET salary = salary + 5000
WHERE emp_id = 1;

SAVEPOINT sp1;

UPDATE Payroll
SET salary = salary + 7000
WHERE emp_id = 2;

ROLLBACK TO sp1;

COMMIT;
