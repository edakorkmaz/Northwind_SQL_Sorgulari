
1-
--Her Çalışanın En Çok Satış Yaptığı Ürünü Bulun Her çalışanın (Employees) sattığı ürünler içinde en çok sattığı (toplam adet olarak) ürünü bulun ve sonucu çalışana göre sıralayın.
--ÇÖZÜM 1--
WITH Sales AS (
    SELECT
        o.employee_id,
        od.product_id,
        SUM(od.quantity) AS TotalSold
    FROM Orders o
    JOIN Order_details od ON o.order_id = od.order_id
    GROUP BY o.employee_id, od.product_id
)
SELECT DISTINCT ON (s.employee_id)
    s.employee_id,
    s.product_id,
    s.TotalSold
FROM Sales s
ORDER BY s.employee_id, s.TotalSold DESC

--ÇÖZÜM 2--
WITH Sales AS (
    SELECT
        o.employee_id,
        od.product_id,
        SUM(od.quantity) AS TotalSold
    FROM Orders o
    JOIN Order_details od ON o.order_id = od.order_id
    GROUP BY o.employee_id, od.product_id
),
RankedSales AS (
    SELECT
        s.employee_id,
        s.product_id,
        s.TotalSold,
        RANK() OVER (PARTITION BY s.employee_id ORDER BY s.TotalSold DESC) AS rank
    FROM Sales s
)
SELECT
    r.employee_id,
    r.product_id,
    r.TotalSold
FROM RankedSales r
WHERE r.rank = 1;

2-
--Bir Ülkenin Müşterilerinin Satın Aldığı En Pahalı Ürünü Bulun Belli bir ülkenin (örneğin "Germany") müşterilerinin verdiği siparişlerde satın aldığı en pahalı ürünü (UnitPrice olarak) bulun ve hangi müşterinin aldığını listeleyin.
WITH CustomerOrders AS (
    SELECT
        c.Customer_id,
        c.contact_name,
        o.Order_id,
        od.product_id,
        od.Unit_price,
		c.Country
    FROM Customers c
    JOIN Orders o ON c.Customer_id = o.Customer_id
    JOIN Order_details od ON o.Order_id = od.Order_id
    WHERE c.Country = 'Germany'
)
SELECT
    co.Customer_id,
    co.contact_name,
    co.Order_id,
    co.product_id,
    p.Product_name,
    co.Unit_price,
	co.Country
FROM CustomerOrders co
JOIN Products p ON co.product_id= p.product_id
WHERE co.Unit_price = (SELECT MAX(Unit_price) FROM CustomerOrders)
ORDER BY co.Customer_id;

3-
--Her Kategoride (Categories) En Çok Satış Geliri Elde Eden Ürünü Bulun Her kategori için toplam satış geliri en yüksek olan ürünü bulun ve listeleyin.
WITH Sales AS (
SELECT
p.product_id,
p.product_name,
ct.category_id,
ct.category_name,
sum(od.unit_price * od.quantity) as total_revenue
FROM products p
JOIN categories ct ON p.category_id = ct.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, ct.category_id, ct.category_name
),
MaxRevenueProduct AS (
SELECT
category_id,
MAX(total_revenue) AS max_revenue
FROM Sales
GROUP BY category_id
)
SELECT s.category_id, s.category_name, s.product_id, s.product_name, s.total_revenue
FROM Sales s
JOIN MaxRevenueProduct rp ON s.category_id = rp.category_id AND s.total_revenue = rp.max_revenue
ORDER BY s.category_id;

4-
--Arka Arkaya En Fazla Sipariş Veren Müşteriyi Bulun Sipariş tarihleri (OrderDate) baz alınarak arka arkaya en fazla sipariş veren müşteriyi bulun. (Örneğin, bir müşteri ardışık günlerde kaç sipariş vermiş?)
--ÇÖZÜM 1--
WITH Sales AS (
SELECT
customer_id,
order_date,
order_date - INTERVAL '1 day' AS previous_date
FROM orders
),
Grouped AS (
SELECT
customer_id,
order_date,
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) -
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY previous_date) AS group_no
FROM Sales
)
SELECT customer_id, COUNT(*) AS consecutive_orders
FROM Grouped
GROUP BY customer_id, group_no
ORDER BY consecutive_orders DESC
LIMIT 1;

--ÇÖZÜM 2--
WITH OrderStreaks AS (
    SELECT
        customer_id,
        Order_date,
        Order_date - INTERVAL '1 day' * ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY Order_date) AS StreakGroup
    FROM Orders
)
SELECT
    customer_id,
    COUNT(*) AS MaxConsecutiveOrders
FROM OrderStreaks
GROUP BY customer_id, StreakGroup
ORDER BY MaxConsecutiveOrders DESC
LIMIT 1;

5-
--Çalışanların Sipariş Sayısına Göre Kendi Departmanındaki Ortalamanın Üzerinde Olup Olmadığını Belirleyin Her çalışanın aldığı sipariş sayısını hesaplayın ve kendi departmanındaki çalışanların ortalama sipariş sayısıyla karşılaştırın. Ortalama sipariş sayısının üstünde veya altında olduğunu belirten bir sütun ekleyin.
--ÇÖZÜM 1--
WITH Employees0rders AS (
    SELECT e.employee_id, e.first_name, e.last_name, SUM(o.order_id) AS total_order
    FROM employees e
    JOIN orders o ON o.employee_id = e.employee_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),
AvgOrder AS (
    SELECT AVG(total_order) AS average_order
    FROM  Employees0rders

)
SELECT
    eo.employee_id,
    eo.first_name,
    eo.last_name,
    eo.total_order,
    ao.average_order,
    CASE
        WHEN eo.total_order > ao.average_order THEN 'Above Average'
        WHEN eo.total_order = ao.average_order THEN 'Average'
        ELSE 'Below Average'
    END AS order_comparison
FROM Employees0rders eo
CROSS JOIN AvgOrder ao
ORDER BY eo.employee_id;

--ÇÖZÜM 2--
WITH Employees0rders AS (
    SELECT e.employee_id, e.first_name, e.last_name, SUM(o.order_id) AS total_order
    FROM employees e
    JOIN orders o ON o.employee_id = e.employee_id
    GROUP BY e.employee_id, e.first_name, e.last_name
),
AvgOrder AS (
    SELECT AVG(total_order) AS average_order
    FROM Employees0rders
)
SELECT
    eo.employee_id,
    eo.first_name,
    eo.last_name,
    eo.total_order,
    ao.average_order,
    CASE
        WHEN eo.total_order > ao.average_order THEN 'Above Average'
        WHEN eo.total_order = ao.average_order THEN 'Average'
        ELSE 'Below Average'
    END AS order_comparison,
    CASE
        WHEN eo.total_order > ao.average_order THEN eo.total_order
        ELSE NULL
    END AS above_average,
    CASE
        WHEN eo.total_order = ao.average_order THEN eo.total_order
        ELSE NULL
    END AS average,
    CASE
        WHEN eo.total_order < ao.average_order THEN eo.total_order
        ELSE NULL
    END AS below_average
FROM Employees0rders eo
CROSS JOIN AvgOrder ao
ORDER BY eo.employee_id;

