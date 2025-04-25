
1-
--Her Müşteri İçin En Son 3 Siparişi ve Toplam Harcamalarını Listeleyin Her müşterinin en son 3 siparişini (OrderDate’e göre en güncel 3 sipariş) ve bu siparişlerde harcadığı toplam tutarı gösteren sorgu.Sonuçlar müşteri bazında sıralı ve her müşterinin sadece en son 3 siparişi görülür.
--ÇÖZÜM 1--

WITH RecentOrders AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_amount,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) AS rn
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
)
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (PARTITION BY customer_id) AS total_spent
FROM RecentOrders
WHERE rn <= 3
ORDER BY customer_id, order_date DESC;

--ÇÖZÜM 2--
SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_amount,
    (
      -- Aynı müşteriye ait, daha yeni siparişlerin sayısı hesaplanıyor.
      SELECT COUNT(*)
      FROM (
            SELECT o2.order_date
            FROM orders o2
            JOIN order_details od2 ON o2.order_id = od2.order_id
            WHERE o2.customer_id = o.customer_id
            GROUP BY o2.order_id, o2.order_date
      ) AS sub
      WHERE sub.order_date > o.order_date
    ) AS newer_count
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.customer_id, o.order_id, o.order_date
HAVING
    (
      SELECT COUNT(*)
      FROM (
            SELECT o2.order_date
            FROM orders o2
            JOIN order_details od2 ON o2.order_id = od2.order_id
            WHERE o2.customer_id = o.customer_id
            GROUP BY o2.order_id, o2.order_date
      ) AS sub
      WHERE sub.order_date > o.order_date
    ) < 3
ORDER BY o.customer_id, o.order_date DESC;


2-
--Aynı Ürünü 3 veya Daha Fazla Kez Satın Alan Müşterileri Bulun Bir müşteri eğer aynı ürünü (ProductID) 3 veya daha fazla sipariş verdiyse, bu müşteriyi ve ürünleri listeleyen bir sorgu yazın. Aynı ürün bir siparişte değil, farklı siparişlerde tekrar tekrar alınmış olabilir. 

--ÇÖZÜM 1--
WITH OrderCounts AS (  
    SELECT 
        o.customer_id,
        od.product_id,
        COUNT(od.product_id) OVER(PARTITION BY o.customer_id, od.product_id) AS order_count
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id  
)  
SELECT DISTINCT customer_id, product_id, order_count  
FROM OrderCounts  
WHERE order_count >= 3;

--ÇÖZÜM 2--
SELECT customer_id, product_id, order_count
FROM (
    SELECT 
        o.customer_id,
        od.product_id,
        COUNT(*) AS order_count
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_id, od.product_id
) AS CustomerProductCounts
WHERE order_count >= 3;


3-
--Bir Çalışanın 30 Gün İçinde Verdiği Siparişlerin Bir Önceki 30 Güne Göre Artış/ Azalışını Hesaplayın Her çalışanın (Employees), sipariş sayısının son 30 gün içinde bir önceki 30 güne kıyasla nasıl değiştiğini hesaplayan sorgu .

WITH OrdersWithPeriod AS (
  -- Son 60 günde yer alan siparişleri alıp, siparişin hangi zaman dilimine ait olduğunu belirliyoruz.
  SELECT
    employee_id,
    CASE
      WHEN order_date >= current_date - interval '30 days' THEN 'current'
      WHEN order_date >= current_date - interval '60 days'
           AND order_date < current_date - interval '30 days' THEN 'previous'
      ELSE NULL
    END AS period
  FROM orders
  WHERE order_date >= current_date - interval '60 days'
),
AggregatedOrders AS (
  -- Her çalışan için, belirlenen zaman dilimine göre sipariş sayısını hesaplıyoruz.
  SELECT
    employee_id,
    period,
    COUNT(*) AS order_count
  FROM OrdersWithPeriod
  WHERE period IS NOT NULL
  GROUP BY employee_id, period
),
PivotedOrders AS (
  -- Zaman dilimlerine göre hesaplanan sipariş sayılarını sütunlara döndürüyoruz.
  SELECT
    employee_id,
    MAX(CASE WHEN period = 'current' THEN order_count ELSE 0 END) AS current_orders,
    MAX(CASE WHEN period = 'previous' THEN order_count ELSE 0 END) AS previous_orders
  FROM AggregatedOrders
  GROUP BY employee_id
)
SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  p.current_orders,
  p.previous_orders,
  CASE
    WHEN p.previous_orders = 0 THEN NULL
    ELSE (p.current_orders - p.previous_orders) * 100.0 / p.previous_orders
  END AS percentage_change,
  RANK() OVER (
    ORDER BY
      CASE
        WHEN p.previous_orders = 0 THEN NULL
        ELSE (p.current_orders - p.previous_orders) * 100.0 / p.previous_orders
      END DESC
  ) AS rank_percentage_change
FROM employees e
LEFT JOIN PivotedOrders p ON e.employee_id = p.employee_id;

4-
--Her Müşterinin Siparişlerinde Kullanılan İndirim Oranının Zaman İçinde Nasıl Değiştiğini Bulun Müşterilerin siparişlerinde uygulanan indirim oranlarının zaman içindeki trendini hesaplayan sorgu.

--ÇÖZÜM 1--
WITH find_discount AS (
	Select c.customer_id,c.contact_name,o.order_date,od.discount from customers c
	JOIN orders o ON o.customer_id=c.customer_id
	JOIN order_details od ON od.order_id=o.order_id

),
trend_analysis AS (
    SELECT
        customer_id,
        contact_name,
        order_date,
        discount,
        LAG(discount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS prev_discount,
        AVG(discount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS moving_avg_discount
    FROM find_discount
)
SELECT
    customer_id,
    contact_name,
    order_date,
    discount,
    moving_avg_discount,
    CASE
        WHEN discount > prev_discount THEN 'growing'
        WHEN discount < prev_discount THEN 'decreasing'
        ELSE 'stable'
    END AS trend
FROM trend_analysis;

--ÇÖZÜM 2--
WITH find_discount AS (
	Select c.customer_id,c.contact_name,o.order_date,od.discount from customers c
	JOIN orders o ON o.customer_id=c.customer_id
	JOIN order_details od ON od.order_id=o.order_id

),
trend_analysis AS (
    SELECT
        customer_id,
        contact_name,
        order_date,
        discount,
        LAG(discount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS prev_discount,
        AVG(discount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS moving_avg_discount
    FROM find_discount
)
SELECT
    customer_id,
    contact_name,
    order_date,
    discount,
    moving_avg_discount,
    CASE
        WHEN discount > prev_discount THEN 'growing'
        WHEN discount < prev_discount THEN 'decreasing'
        ELSE 'Stable'
    END AS trend,
 CASE
        WHEN discount > prev_discount THEN discount
        ELSE NULL
    END AS growing,
	 CASE
        WHEN discount = prev_discount THEN discount
        ELSE NULL
    END AS stable,
	CASE
        WHEN discount < prev_discount THEN discount
        ELSE NULL
    END AS decreasing
FROM trend_analysis;

