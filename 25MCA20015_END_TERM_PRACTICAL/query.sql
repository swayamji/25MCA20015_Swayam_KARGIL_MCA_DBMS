-- =========================
-- CREATE TABLES
-- =========================

CREATE TABLE Tbl_Suppliers (
    sup_id INT PRIMARY KEY,
    sup_name VARCHAR(100),
    city VARCHAR(50),
    rating INT
);

CREATE TABLE Tbl_Products (
    prod_id INT PRIMARY KEY,
    prod_name VARCHAR(100),
    category VARCHAR(50),
    price INT,
    stock_qty INT,
    sup_id INT,
    FOREIGN KEY (sup_id) REFERENCES Tbl_Suppliers(sup_id)
);

CREATE TABLE Tbl_Orders (
    order_id INT PRIMARY KEY,
    prod_id INT,
    cust_id INT,
    order_date DATE,
    qty INT,
    FOREIGN KEY (prod_id) REFERENCES Tbl_Products(prod_id)
);

CREATE TABLE Tbl_Supply_logs (
    log_id INT PRIMARY KEY,
    action_type VARCHAR(20),
    prod_id INT,
    old_qty INT,
    new_qty INT,
    log_time TIMESTAMP,
    FOREIGN KEY (prod_id) REFERENCES Tbl_Products(prod_id)
);

-- =========================
-- INSERT DATA
-- =========================

-- Suppliers
INSERT INTO Tbl_Suppliers VALUES
(701, 'NextGen Tech', 'Bangalore', 5),
(702, 'Comfort Hub', 'Mumbai', 4);

-- Products (NOW linked to suppliers)
INSERT INTO Tbl_Products VALUES
(501, 'Laptop Pro', 'Electronics', 75000, 15, 701),
(502, 'Ergo Chair', 'Furniture', 15000, 8, 702);

-- Orders
INSERT INTO Tbl_Orders VALUES
(9001, 501, 101, '2026-04-20', 1),
(9002, 502, 102, '2026-04-21', 2);

-- Supply Logs
INSERT INTO Tbl_Supply_logs VALUES
(1, 'UPDATE', 501, 20, 15, '2026-04-20 10:00:00');



SELECT s.sup_name, p.prod_name, o.qty
FROM Tbl_Orders o
JOIN Tbl_Products p ON o.prod_id = p.prod_id
JOIN Tbl_Suppliers s ON p.sup_id = s.sup_id;


CREATE OR REPLACE FUNCTION update_stock()
RETURNS TRIGGER AS $$
BEGIN

    IF (SELECT stock_qty FROM Tbl_Products WHERE prod_id = NEW.prod_id) < NEW.qty THEN
        RAISE EXCEPTION 'Not enough stock';
    END IF;

    UPDATE Tbl_Products
    SET stock_qty = stock_qty - NEW.qty
    WHERE prod_id = NEW.prod_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock
AFTER INSERT ON Tbl_Orders
FOR EACH ROW
EXECUTE FUNCTION update_stock();

