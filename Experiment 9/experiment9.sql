CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    working_hours INT,
    perhour_salary NUMERIC,
    total_payable_amount NUMERIC
);


-- Create Trigger function
CREATE OR REPLACE FUNCTION CACULATE_PAYABLE_AMOUNT() RETURNS TRIGGER
AS
$$
  BEGIN
		NEW.total_payable_amount:=NEW.perhour_salary*New.working_hours;

		IF NEW.total_payable_amount>25000 THEN
		RAISE EXCEPTION 'INVALID ENTRY BEACUSE PAYABLE AMOUNT CAN NOT BE GREATER THAN 25000';
		END IF;

		RETURN NEW;
   END;

$$ LANGUAGE PLPGSQL;



-- Create Trigger
CREATE OR REPLACE TRIGGER AUTOMATED_PAYABLE_AMOUNT_CALCULATION
BEFORE INSERT
ON  employee
FOR EACH ROW
EXECUTE FUNCTION CACULATE_PAYABLE_AMOUNT()


-- Insert Valid Input
INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME,working_hours,perhour_salary) VALUES (1, 'AKASH',10,1000)

-- Insert Invalid Input
insert into employee(emp_id, emp_name, working_hours, perhour_salary) values (2,'Ankush',8,100000)

-- Fetch Data
SELECT * FROM EMPLOYEE
