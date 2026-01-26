--TABLE CREATED
CREATE TABLE Electronics_orders(
    order_id INT PRIMARY KEY ,
    customer_name VARCHAR(50),
    product VARCHAR(50),
    quantity INT,
    price INT,
    order_date DATE
);

--DATA INSERTED
INSERT INTO Electronics_orders(order_id,customer_name,product,quantity,price,order_date)VALUES
(1,'swayam','Laptop-hp',1,55000,'2025-01-10'),
(2,'Manish','Laptop-asus',1,58000,'2025-01-12'),
(3,'Ashish','Keyboard-hp',1,2500,'2025-01-12'),
(4,'Suman','Mouse-teck',3,1800,'2025-01-13'),
(5,'Salman','Mouse-teck',2,1200,'2025-01-11'),
(6,'Ridhima','Laptop-hp',2,110000,'2025-01-14');

--step 2
SELECT * FROM Electronics_orders 
WHERE price>50000;

--step3
--ascending order
SELECT customer_name,product,price FROM Electronics_orders 
ORDER BY price ASC;

--descending order
SELECT customer_name,product,price FROM Electronics_orders 
ORDER BY price DESC;

--multiple columns
SELECT customer_name,product,price FROM Electronics_orders 
ORDER BY product ASC, price DESC;

--step4
SELECT product, SUM(price) AS total_sales FROM Electronics_orders
GROUP BY product;

--step5
SELECT product, SUM(price) AS total_sales FROM Electronics_orders 
GROUP BY product HAVING SUM(price)>60000;

--step6
-- using groupby and where
SELECT product, SUM(price * quantity) AS total_sales FROM Electronics_orders 
WHERE SUM(price * quantity) > 60000 
GROUP BY product;

--using group by and having
SELECT product, SUM(price) FROM Electronics_orders GROUP BY product HAVING SUM(price)>60000;
