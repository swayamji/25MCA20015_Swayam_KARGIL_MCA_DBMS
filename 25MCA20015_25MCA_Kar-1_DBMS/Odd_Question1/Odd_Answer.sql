CREATE TABLE Purchases (
    purchase_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    product_id INT,
    purchase_date DATE
);

INSERT INTO Purchases (purchase_id, customer_name, product_id, purchase_date) VALUES
(1, 'Swayam', 101, '2026-03-01'),
(2, 'Roshan', 101, '2026-03-01'),
(3, 'Sanchit', 101, '2026-03-01'),
(4, 'Swayam', 102, '2026-03-02'),
(5, 'Sanchit', 102, '2026-03-02'),
(6, 'Roshan', 103, '2026-03-03');

SELECT 
    p1.customer_name AS customer1,
    p2.customer_name AS customer2,
    p1.product_id,
    p1.purchase_date
FROM Purchases p1
JOIN Purchases p2
ON p1.product_id = p2.product_id
AND p1.purchase_date = p2.purchase_date
AND p1.customer_name < p2.customer_name;
