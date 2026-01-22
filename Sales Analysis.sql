use classicmodels;


/* Q1 A */
Select distinct employeeNumber, firstName, lastname from employees 
where jobTitle = "sales rep" and reportsto = 1102;


/* Q1 B */
select productLine from productlines 
where productline like "%cars";


/* Q2*/
SELECT customerNumber, customerName,
CASE WHEN country IN ('USA', 'Canada') THEN 'North America'
WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
ELSE 'Other'
END
AS CustomerSegment FROM customers;


/* Q3 A*/
SELECT productCode, SUM(quantityOrdered) AS total_quantity FROM orderdetails
GROUP BY productCode ORDER BY total_quantity DESC LIMIT 10;


/* Q3 B */
SELECT MONTHNAME(paymentDate) AS month_name, COUNT(*) AS total_payments FROM payments
GROUP BY MONTH(paymentDate)
HAVING COUNT(*) > 20
ORDER BY total_payments DESC;


/* Q4 A */
SELECT MONTHNAME(paymentDate) AS month_name, COUNT(*) AS total_payments FROM payments
GROUP BY MONTH(paymentDate) HAVING COUNT(*) > 20
ORDER BY total_payments DESC;


/* Q4 B */
CREATE TABLE Q4Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES Q4Customers(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0));


/* Q5 */
SELECT c.country,
       COUNT(o.orderNumber) AS order_count
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;


/* Q6 */
CREATE TABLE project (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male','Female'),
    ManagerID INT
);
INSERT INTO project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3)
;
SELECT m.FullName AS `Manager Name`,e.FullName AS `Emp Name` FROM project e
JOIN project m
ON e.ManagerID = m.EmployeeID
ORDER BY m.FullName;


/* Q7 */
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);
ALTER TABLE facility
MODIFY Facility_ID INT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (Facility_ID);
desc facility;


/* Q8 */
CREATE VIEW product_category_sales AS
SELECT pl.productLine,
       SUM(od.quantityOrdered * od.priceEach) AS total_sales,
       COUNT(DISTINCT od.orderNumber) AS number_of_orders
FROM productlines pl
JOIN products p 
    ON pl.productLine = p.productLine
JOIN orderdetails od 
    ON p.productCode = od.productCode
GROUP BY pl.productLine;
SELECT * FROM product_category_sales;


/* Q9 */
DELIMITER $$
CREATE PROCEDURE Get_country_payments(
    IN p_year INT,
    IN p_country VARCHAR(50)
)
BEGIN
    SELECT YEAR(p.paymentDate) AS Year,
           c.country,
           CONCAT(ROUND(SUM(p.amount)/1000), 'K') AS TotalAmount
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = p_year
      AND c.country = p_country
    GROUP BY YEAR(p.paymentDate), c.country;
END$$
DELIMITER ;
CALL Get_country_payments(2003, 'France');


/* Q10 A */
SELECT c.customerName,
       COUNT(o.orderNumber) AS Order_count,
       RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM customers c
JOIN orders o 
    ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY Order_count DESC;


/* Q10 B */
WITH monthly_orders AS (
    SELECT DATE_FORMAT(orderDate, '%Y-%m-01') AS MonthStart, YEAR(orderDate) AS Year, MONTH(orderDate) AS MonthNum,
        MONTHNAME(orderDate) AS Month,
        COUNT(orderNumber) AS TotalOrders
    FROM orders
    GROUP BY YEAR(orderDate), MONTH(orderDate)
),
calc AS ( SELECT Year, Month, MonthNum, TotalOrders,
        LAG(TotalOrders) OVER (ORDER BY MonthStart) AS Prev_Month_Orders
    FROM monthly_orders)
SELECT Year, Month, TotalOrders,
    CASE 
        WHEN Prev_Month_Orders IS NULL THEN NULL
        ELSE CONCAT(ROUND(((TotalOrders - Prev_Month_Orders) / Prev_Month_Orders) * 100), '%')
    END AS `% YoY Change`
FROM calc
ORDER BY Year, MonthNum;


/* Q11 */
SELECT productLine,
       COUNT(*) AS Total
FROM products
WHERE buyPrice > (
    SELECT AVG(buyPrice)
    FROM products AS p2
    WHERE p2.productLine = products.productLine
)
GROUP BY productLine
ORDER BY Total DESC;


/* Q12 */
CREATE TABLE Emp_EH ( EmpID INT PRIMARY KEY, EmpName VARCHAR(100), EmailAddress VARCHAR(255));
 DELIMITER $$

CREATE PROCEDURE Insert_Emp_EH( IN p_EmpID INT, IN p_EmpName VARCHAR(100), IN p_Email VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;
INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) VALUES (p_EmpID, p_EmpName, p_Email);
END$$
DELIMITER ;
CALL Insert_Emp_EH(2, 'ram', 'ram@example.com');
CALL Insert_Emp_EH(2, 'sonu', 'alex@example.com');


/* Q13 */
CREATE TABLE Emp_BIT ( Name VARCHAR(100), Occupation VARCHAR(100), Working_date DATE, Working_hours INT);
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);
DELIMITER $$
CREATE TRIGGER trg_positive_hours
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END$$
DELIMITER ;
INSERT INTO Emp_BIT VALUES ('Test User', 'Intern', '2020-10-05', -7);
SELECT * FROM Emp_BIT;



   
    










 



   

    








