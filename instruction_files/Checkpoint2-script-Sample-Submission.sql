-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Script
-- Project Title: LogiTrack: Multi-Facility Warehouse Management System
-- Team Members: Leia Organa, Miles Morales
-- File: Checkpoint2-script.sql
-- ============================================================================

-- ============================================================================
-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- ============================================================================
-- 1. Performance Indexes Added: Added secondary indexes on 
--    WarehouseStock(product_id), Orders(customer_name), and 
--    OrderLineItems(product_id) to optimize join and filtering performance.
-- 2. Trigger Integration: Added an audit trigger to track automated stock 
--    reductions when new customer order line items are inserted.
-- ============================================================================

-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: Leia Organa: 100%, Miles Morales: 0%
-- Statement 02: Miles Morales: 100%, Leia Organa: 0%
-- Statement 03: Leia Organa: 50%, Miles Morales: 50%
-- Statement 04: Miles Morales: 70%, Leia Organa: 30%
-- Statement 05: Leia Organa: 60%, Miles Morales: 40%
-- Statement 06: Miles Morales: 100%, Leia Organa: 0%
-- Statement 07: Leia Organa: 100%, Miles Morales: 0%
-- Statement 08: Miles Morales: 50%, Leia Organa: 50%
-- Statement 09: Leia Organa: 80%, Miles Morales: 20%
-- Statement 10: Miles Morales: 60%, Leia Organa: 40%
--
-- SECTION 2: INTERMEDIATE STATEMENTS
-- Statement 11: Leia Organa: 50%, Miles Morales: 50%
-- Statement 12: Miles Morales: 70%, Leia Organa: 30%
-- Statement 13: Leia Organa: 60%, Miles Morales: 40%
-- Statement 14: Miles Morales: 50%, Leia Organa: 50%
-- Statement 15: Leia Organa: 70%, Miles Morales: 30%
-- Statement 16: Miles Morales: 60%, Leia Organa: 40%
-- Statement 17: Leia Organa: 80%, Miles Morales: 20%
-- Statement 18: Miles Morales: 50%, Leia Organa: 50%
-- Statement 19: Leia Organa: 50%, Miles Morales: 50%
-- Statement 20: Miles Morales: 100%, Leia Organa: 0%
-- Statement 21: Leia Organa: 60%, Miles Morales: 40%
--
-- SECTION 3: COMPLEX STATEMENTS
-- Statement 22: Leia Organa: 50%, Miles Morales: 50%
-- Statement 23: Miles Morales: 70%, Leia Organa: 30%
-- Statement 24: Leia Organa: 70%, Miles Morales: 30%
-- Statement 25: Miles Morales: 50%, Leia Organa: 50%
-- Statement 26: Leia Organa: 60%, Miles Morales: 40%
-- Statement 27: Miles Morales: 80%, Leia Organa: 20%
-- Statement 28: Leia Organa: 50%, Miles Morales: 50%
-- Statement 29: Miles Morales: 50%, Leia Organa: 50%
-- Statement 30: Leia Organa: 70%, Miles Morales: 30%
-- Statement 31: Miles Morales: 60%, Leia Organa: 40%
-- Statement 32: Leia Organa: 50%, Miles Morales: 50%
-- ============================================================================

PRAGMA foreign_keys = ON;
.headers on
.mode column


-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS (Statements 1 to 10)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 01: Active Warehouses in California
-- Explanation: Retrieve the facility name, city, and square footage of all 
--              operational warehouses located in the state of California.
-- ----------------------------------------------------------------------------
SELECT facility_name, city, storage_capacity_sqft
FROM Warehouses
WHERE state = 'CA' AND is_active = 1
ORDER BY storage_capacity_sqft DESC;

-- ----------------------------------------------------------------------------
-- Statement 02: High-Value Products Filter
-- Explanation: Find the SKU, product name, and unit price of all catalog 
--              products priced at $100.00 or higher.
-- ----------------------------------------------------------------------------
SELECT sku_code, product_name, unit_price
FROM Products
WHERE unit_price >= 100.00
ORDER BY unit_price DESC;

-- ----------------------------------------------------------------------------
-- Statement 03: Distinct Order Status Values
-- Explanation: List all unique order statuses currently present in the 
--              customer orders table to verify operational workflow states.
-- ----------------------------------------------------------------------------
SELECT DISTINCT order_status
FROM Orders;

-- ----------------------------------------------------------------------------
-- Statement 04: Fast-Lead-Time Supplier Search
-- Explanation: Find all suppliers whose delivery lead time is under 5 days, 
--              or who provide a company contact email ending in '.com'.
-- ----------------------------------------------------------------------------
SELECT company_name, contact_email, lead_time_days
FROM Suppliers
WHERE lead_time_days < 5 OR contact_email LIKE '%.com';

-- ----------------------------------------------------------------------------
-- Statement 05: Aggregate Warehouse Storage Metrics
-- Explanation: Compute the total count of warehouses, the total storage 
--              capacity across all facilities, and the average facility size.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_facilities,
    SUM(storage_capacity_sqft) AS network_capacity_sqft,
    ROUND(AVG(storage_capacity_sqft), 2) AS average_facility_sqft
FROM Warehouses;

-- ----------------------------------------------------------------------------
-- Statement 06: Insert New Product Category
-- Explanation: Insert a new product classification for temperature-sensitive 
--              items requiring cold storage into the Categories table.
-- ----------------------------------------------------------------------------
INSERT INTO Categories (category_id, category_name, description, reorder_strategy)
VALUES (6, 'Perishables', 'Cold chain goods requiring refrigeration', 'JUST_IN_TIME');

-- ----------------------------------------------------------------------------
-- Statement 07: Insert New Supplier Profile
-- Explanation: Record a new regional logistics packaging supplier into the 
--              Suppliers registry with a 4-day delivery SLA.
-- ----------------------------------------------------------------------------
INSERT INTO Suppliers (supplier_id, company_name, contact_email, phone_number, lead_time_days)
VALUES (105, 'Pacific Pack Co', 'orders@pacificpack.com', '209-555-0199', 4);

-- ----------------------------------------------------------------------------
-- Statement 08: Update Employee Role Assignment
-- Explanation: Promote employee 1002 to Senior Fulfillment Lead and update 
--              their current role title.
-- ----------------------------------------------------------------------------
UPDATE Employees
SET role = 'Senior Fulfillment Lead'
WHERE employee_id = 1002;

-- ----------------------------------------------------------------------------
-- Statement 09: Bulk Update Stock Thresholds
-- Explanation: Increase the reorder threshold by 5 units for all inventory 
--              stored in Bay A aisles to accommodate peak seasonal demand.
-- ----------------------------------------------------------------------------
UPDATE WarehouseStock
SET reorder_threshold = reorder_threshold + 5
WHERE aisle_location LIKE 'Aisle-A%';

-- ----------------------------------------------------------------------------
-- Statement 10: Delete Cancelled Orders Without Line Items
-- Explanation: Remove cancelled test orders that have a total amount of 0.00 
--              and were logged under obsolete mock accounts.
-- ----------------------------------------------------------------------------
DELETE FROM Orders
WHERE order_status = 'CANCELLED' AND total_amount = 0.00;


-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS (Statements 11 to 21)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 11: Products with Category and Supplier Details (2-Table Inner Join)
-- Explanation: Retrieve catalog products alongside their category classification 
--              name and primary supplier company name.
-- ----------------------------------------------------------------------------
SELECT 
    P.sku_code,
    P.product_name,
    C.category_name,
    S.company_name AS supplier_name,
    P.unit_price
FROM Products P
JOIN Categories C ON P.category_id = C.category_id
JOIN Suppliers S ON P.supplier_id = S.supplier_id
ORDER BY C.category_name, P.product_name;

-- ----------------------------------------------------------------------------
-- Statement 12: Warehouse Facility Inventory Breakdown (Multi-Table Join)
-- Explanation: List all inventory held across facilities, showing warehouse name, 
--              product SKU, aisle location, and quantity on hand.
-- ----------------------------------------------------------------------------
SELECT 
    W.facility_name,
    P.sku_code,
    P.product_name,
    WS.aisle_location,
    WS.quantity_on_hand
FROM WarehouseStock WS
JOIN Warehouses W ON WS.warehouse_id = W.warehouse_id
JOIN Products P ON WS.product_id = P.product_id
ORDER BY W.facility_name, WS.aisle_location;

-- ----------------------------------------------------------------------------
-- Statement 13: Customer Order Header and Line Item Aggregation
-- Explanation: Summarize each customer order with the number of line items 
--              and the calculated itemized total.
-- ----------------------------------------------------------------------------
SELECT 
    O.order_id,
    O.customer_name,
    O.order_status,
    COUNT(OLI.item_number) AS total_line_items,
    SUM(OLI.quantity_ordered * OLI.unit_sale_price) AS computed_order_value
FROM Orders O
JOIN OrderLineItems OLI ON O.order_id = OLI.order_id
GROUP BY O.order_id, O.customer_name, O.order_status;

-- ----------------------------------------------------------------------------
-- Statement 14: Supplier Product Catalog Breadth (GROUP BY & HAVING)
-- Explanation: Identify suppliers that provide at least 3 distinct products in 
--              the catalog and calculate their average product price.
-- ----------------------------------------------------------------------------
SELECT 
    S.supplier_id,
    S.company_name,
    COUNT(P.product_id) AS products_supplied,
    ROUND(AVG(P.unit_price), 2) AS average_product_price
FROM Suppliers S
JOIN Products P ON S.supplier_id = P.supplier_id
GROUP BY S.supplier_id, S.company_name
HAVING COUNT(P.product_id) >= 3;

-- ----------------------------------------------------------------------------
-- Statement 15: Staffing Distribution per Warehouse
-- Explanation: Count how many staff members are assigned to each warehouse 
--              facility, filtering for facilities with more than 1 employee.
-- ----------------------------------------------------------------------------
SELECT 
    W.warehouse_id,
    W.facility_name,
    W.city,
    COUNT(E.employee_id) AS total_assigned_staff
FROM Warehouses W
JOIN Employees E ON W.warehouse_id = E.assigned_warehouse_id
GROUP BY W.warehouse_id, W.facility_name, W.city
HAVING COUNT(E.employee_id) > 1;

-- ----------------------------------------------------------------------------
-- Statement 16: Warehouses with Unstocked Products (LEFT OUTER JOIN)
-- Explanation: Identify products in the catalog that are not stocked in any 
--              warehouse by using a left outer join and filtering for NULLs.
-- ----------------------------------------------------------------------------
SELECT 
    P.product_id,
    P.sku_code,
    P.product_name,
    WS.warehouse_id
FROM Products P
LEFT JOIN WarehouseStock WS ON P.product_id = WS.product_id
WHERE WS.warehouse_id IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 17: Products Priced Above Their Category Average (Scalar Subquery)
-- Explanation: Find all products whose unit price is strictly higher than the 
--              average unit price of all items within their category.
-- ----------------------------------------------------------------------------
SELECT 
    P1.product_id,
    P1.product_name,
    P1.unit_price,
    P1.category_id
FROM Products P1
WHERE P1.unit_price > (
    SELECT AVG(P2.unit_price)
    FROM Products P2
    WHERE P2.category_id = P1.category_id
);

-- ----------------------------------------------------------------------------
-- Statement 18: Total Stock Valuation per Facility
-- Explanation: Calculate total inventory asset valuation (quantity * unit price) 
--              held inside each operational warehouse facility.
-- ----------------------------------------------------------------------------
SELECT 
    W.warehouse_id,
    W.facility_name,
    SUM(WS.quantity_on_hand) AS total_units_stored,
    ROUND(SUM(WS.quantity_on_hand * P.unit_price), 2) AS total_stock_valuation
FROM Warehouses W
JOIN WarehouseStock WS ON W.warehouse_id = WS.warehouse_id
JOIN Products P ON WS.product_id = P.product_id
GROUP BY W.warehouse_id, W.facility_name;

-- ----------------------------------------------------------------------------
-- Statement 19: Order Processing Workload by Employee
-- Explanation: Determine how many customer orders each employee has processed, 
--              along with the total revenue handled.
-- ----------------------------------------------------------------------------
SELECT 
    E.employee_id,
    E.first_name || ' ' || E.last_name AS employee_full_name,
    E.role,
    COUNT(O.order_id) AS orders_handled,
    COALESCE(SUM(O.total_amount), 0.00) AS total_revenue_processed
FROM Employees E
LEFT JOIN Orders O ON E.employee_id = O.processed_by_employee_id
GROUP BY E.employee_id, employee_full_name, E.role;

-- ----------------------------------------------------------------------------
-- Statement 20: Restock Low-Stock Items (Subquery Update)
-- Explanation: Automatically increase stock by 50 units for any product in Bay B 
--              whose quantity on hand is below its reorder threshold.
-- ----------------------------------------------------------------------------
UPDATE WarehouseStock
SET quantity_on_hand = quantity_on_hand + 50,
    last_restocked_date = CURRENT_DATE
WHERE aisle_location LIKE 'Aisle-B%'
  AND quantity_on_hand <= reorder_threshold;

-- ----------------------------------------------------------------------------
-- Statement 21: Products Never Ordered by Specific Customers (Subquery IN)
-- Explanation: Find all products that have never been included in any order 
--              placed by customer 'Acme Corp'.
-- ----------------------------------------------------------------------------
SELECT product_id, sku_code, product_name
FROM Products
WHERE product_id NOT IN (
    SELECT OLI.product_id
    FROM OrderLineItems OLI
    JOIN Orders O ON OLI.order_id = O.order_id
    WHERE O.customer_name = 'Acme Corp'
);


-- ============================================================================
-- SECTION 3: COMPLEX STATEMENTS (Statements 22 to 32)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 22: Correlated Subquery with NOT EXISTS (Critical Reorder Alert)
-- Explanation: Find suppliers who have at least one product stocked in a 
--              warehouse that has dropped strictly below its safety threshold.
-- ----------------------------------------------------------------------------
SELECT S.supplier_id, S.company_name, S.contact_email
FROM Suppliers S
WHERE EXISTS (
    SELECT 1
    FROM Products P
    JOIN WarehouseStock WS ON P.product_id = WS.product_id
    WHERE P.supplier_id = S.supplier_id
      AND WS.quantity_on_hand < WS.reorder_threshold
);

-- ----------------------------------------------------------------------------
-- Statement 23: Set Difference (EXCEPT) for Multi-Facility Presence
-- Explanation: Find the IDs and names of products stocked in Warehouse 1 but 
--              NOT stocked in Warehouse 2 using the relational EXCEPT operator.
-- ----------------------------------------------------------------------------
SELECT P.product_id, P.product_name
FROM Products P
JOIN WarehouseStock WS ON P.product_id = WS.product_id
WHERE WS.warehouse_id = 1
EXCEPT
SELECT P.product_id, P.product_name
FROM Products P
JOIN WarehouseStock WS ON P.product_id = WS.product_id
WHERE WS.warehouse_id = 2;

-- ----------------------------------------------------------------------------
-- Statement 24: Set Intersection (INTERSECT) for Mutual Supplier Cataloging
-- Explanation: Find products that are supplied by Supplier 101 AND also 
--              stocked in the central depot (Warehouse 1).
-- ----------------------------------------------------------------------------
SELECT product_id, product_name
FROM Products
WHERE supplier_id = 101
INTERSECT
SELECT P.product_id, P.product_name
FROM Products P
JOIN WarehouseStock WS ON P.product_id = WS.product_id
WHERE WS.warehouse_id = 1;

-- ----------------------------------------------------------------------------
-- Statement 25: Set Union (UNION ALL) for Logistics Contact Directory
-- Explanation: Build a consolidated communications directory combining all 
--              internal employees and external supplier contact emails.
-- ----------------------------------------------------------------------------
SELECT 
    first_name || ' ' || last_name AS contact_name,
    email AS contact_email,
    'INTERNAL EMPLOYEE' AS affiliation
FROM Employees
UNION ALL
SELECT 
    company_name AS contact_name,
    contact_email AS contact_email,
    'EXTERNAL VENDOR' AS affiliation
FROM Suppliers
ORDER BY contact_name ASC;

-- ----------------------------------------------------------------------------
-- Statement 26: Common Table Expression (CTE) for Warehouse Capacity Utilization
-- Explanation: Calculate total cubic inventory foot footprint using a CTE, 
--              then compute the percentage of facility capacity consumed.
-- ----------------------------------------------------------------------------
WITH FacilityUtilization AS (
    SELECT 
        W.warehouse_id,
        W.facility_name,
        W.storage_capacity_sqft,
        COALESCE(SUM(WS.quantity_on_hand * P.weight_kg), 0.0) AS current_weight_stored
    FROM Warehouses W
    LEFT JOIN WarehouseStock WS ON W.warehouse_id = WS.warehouse_id
    LEFT JOIN Products P ON WS.product_id = P.product_id
    GROUP BY W.warehouse_id, W.facility_name, W.storage_capacity_sqft
)
SELECT 
    warehouse_id,
    facility_name,
    storage_capacity_sqft,
    current_weight_stored,
    ROUND((current_weight_stored / storage_capacity_sqft) * 100.0, 2) AS utilization_pct
FROM FacilityUtilization
ORDER BY utilization_pct DESC;

-- ----------------------------------------------------------------------------
-- Statement 27: Window Function (RANK) for Best-Selling Products
-- Explanation: Rank products by total sales revenue using the DENSE_RANK() 
--              window function partitioned by category.
-- ----------------------------------------------------------------------------
SELECT 
    P.category_id,
    P.product_name,
    SUM(OLI.quantity_ordered * OLI.unit_sale_price) AS category_revenue,
    DENSE_RANK() OVER (
        PARTITION BY P.category_id 
        ORDER BY SUM(OLI.quantity_ordered * OLI.unit_sale_price) DESC
    ) AS rank_in_category
FROM Products P
JOIN OrderLineItems OLI ON P.product_id = OLI.product_id
GROUP BY P.category_id, P.product_name;

-- ----------------------------------------------------------------------------
-- Statement 28: DDL View Creation for Low-Stock Reorder Dashboard
-- Explanation: Create an administrative view joining products, warehouses, and 
--              suppliers to expose real-time low-stock items.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS View_LowStockDashboard;

CREATE VIEW View_LowStockDashboard AS
SELECT 
    W.facility_name,
    P.sku_code,
    P.product_name,
    WS.quantity_on_hand,
    WS.reorder_threshold,
    S.company_name AS vendor_to_order_from,
    S.contact_email AS vendor_email
FROM WarehouseStock WS
JOIN Warehouses W ON WS.warehouse_id = W.warehouse_id
JOIN Products P ON WS.product_id = P.product_id
JOIN Suppliers S ON P.supplier_id = S.supplier_id
WHERE WS.quantity_on_hand <= WS.reorder_threshold;

-- ----------------------------------------------------------------------------
-- Statement 29: Query Against Reorder Dashboard View
-- Explanation: Query the newly created View_LowStockDashboard to retrieve all 
--              critical restock alerts for facilities in California.
-- ----------------------------------------------------------------------------
SELECT facility_name, sku_code, product_name, quantity_on_hand, vendor_to_order_from
FROM View_LowStockDashboard
ORDER BY quantity_on_hand ASC;

-- ----------------------------------------------------------------------------
-- Statement 30: Automated Inventory Decrement Trigger
-- Explanation: Create a trigger that automatically decrements stock in 
--              WarehouseStock whenever a customer order line item is inserted.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_AfterOrderLineItemInsert;

CREATE TRIGGER trg_AfterOrderLineItemInsert
AFTER INSERT ON OrderLineItems
FOR EACH ROW
WHEN NEW.fulfilled_from_warehouse_id IS NOT NULL
BEGIN
    UPDATE WarehouseStock
    SET quantity_on_hand = quantity_on_hand - NEW.quantity_ordered
    WHERE warehouse_id = NEW.fulfilled_from_warehouse_id
      AND product_id = NEW.product_id;
END;

-- ----------------------------------------------------------------------------
-- Statement 31: Test Order Total Sync Trigger
-- Explanation: Create a trigger that updates the Orders table total_amount 
--              attribute when a new line item is added to that order.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_UpdateOrderTotalOnInsert;

CREATE TRIGGER trg_UpdateOrderTotalOnInsert
AFTER INSERT ON OrderLineItems
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = total_amount + (NEW.quantity_ordered * NEW.unit_sale_price)
    WHERE order_id = NEW.order_id;
END;

-- ----------------------------------------------------------------------------
-- Statement 32: Cross-Tab Analytics with CASE Expressions
-- Explanation: Perform a pivot summary of customer orders tallying counts 
--              across pending, shipped, and delivered states per employee.
-- ----------------------------------------------------------------------------
SELECT 
    E.employee_id,
    E.first_name || ' ' || E.last_name AS employee_name,
    COUNT(CASE WHEN O.order_status = 'PENDING' THEN 1 END) AS pending_orders,
    COUNT(CASE WHEN O.order_status = 'PROCESSING' THEN 1 END) AS processing_orders,
    COUNT(CASE WHEN O.order_status = 'SHIPPED' THEN 1 END) AS shipped_orders,
    COUNT(CASE WHEN O.order_status = 'DELIVERED' THEN 1 END) AS delivered_orders,
    COUNT(O.order_id) AS total_orders
FROM Employees E
LEFT JOIN Orders O ON E.employee_id = O.processed_by_employee_id
GROUP BY E.employee_id, employee_name;