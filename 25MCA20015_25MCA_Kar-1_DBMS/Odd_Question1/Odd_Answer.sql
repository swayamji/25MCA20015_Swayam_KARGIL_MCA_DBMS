--25MCA20015
CREATE TABLE Purchases (
    purchase_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    purchase_date DATE
);

INSERT INTO Purchases (customer_id, product_id, purchase_date) VALUES
(101, 1, '2026-03-01'),
(102, 1, '2026-03-01'),
(103, 2, '2026-03-01'),
(104, 1, '2026-03-01'),
(105, 3, '2026-03-02'),
(101, 2, '2026-03-02'),
(102, 2, '2026-03-02'),
(106, 1, '2026-03-01'),
(107, 3, '2026-03-02'),
(108, 1, '2026-03-03');

SELECT 
    p1.customer_id AS customer1,
    p2.customer_id AS customer2,
    p1.product_id,
    p1.purchase_date
FROM Purchases p1
JOIN Purchases p2
ON p1.product_id = p2.product_id
AND p1.purchase_date = p2.purchase_date
AND p1.customer_id < p2.customer_id;
