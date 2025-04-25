--INNER JOIN SORULARI
1-
--Müşterilerin Siparişleri Müşteriler (Customers) ve siparişler (Orders) tablolarını kullanarak, en az 5 sipariş vermiş müşterilerin adlarını ve verdikleri toplam sipariş sayısını listeleyin.

select * from customers

select c.contact_name, count(o.order_id) as Total_Orders
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.contact_name
having count(o.order_id) >=5

2-
--En Çok Satış Yapan Çalışanlar Çalışanlar (Employees) ve siparişler (Orders) tablolarını kullanarak, her çalışanın toplam kaç sipariş aldığını ve en çok sipariş alan 3 çalışanı listeleyin.
 select * from employees

 select concat(e.first_name , ' ', e.last_name) as full_name , count(o.order_id) as Total_Orders
 from employees e
 inner join orders o on e.employee_id = o.employee_id
 group by full_name
 order by Total_Orders desc
 limit 3

3-
--En Çok Satılan Ürünler Sipariş detayları (Order Details) ve ürünler (Products) tablolarını kullanarak, toplamda en fazla satılan (miktar olarak) ilk 5 ürünü listeleyin.

select * from order_details
select * from products

select p.product_name, sum(od.quantity) as Total_Sold
from order_details od
inner join products p on od.product_id = p.product_id
group by p.product_name
order by Total_Sold desc
limit 5

4-
--Her Müşterinin Aldığı Kategoriler Müşteriler (Customers), siparişler (Orders), sipariş detayları (Order Details), ürünler (Products) ve kategoriler (Categories) tablolarını kullanarak,her müşterinin satın aldığı farklı kategorileri listeleyin.

select * from customers
select * from orders
select * from order_details
select * from products
select * from categories

select c.customer_id, c.contact_name, STRING_AGG(DISTINCT cat.category_name, ', ') AS purchased_categories
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p ON od.product_id = p.product_id
join categories cat ON p.category_id = cat.category_id
group by c.customer_id



SELECT DISTINCT c.customer_id, c.contact_name, cat.category_name AS purchased_categories
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
ORDER BY c.customer_id, cat.category_name;


5-
--Müşteri-Sipariş-Ürün Kombinasyonu Müşteriler (Customers), siparişler (Orders), sipariş detayları (Order Details) ve ürünler (Products) tablolarını kullanarak, her müşterinin kaç farklı ürün satın aldığını ve toplam kaç adet aldığını listeleyin.

select * from customers
select * from orders
select * from order_details
select * from products

select c.contact_name, count(distinct p.product_id ) as DiffProducts, SUM(od.quantity) as Total_Quantity
from customers c
inner join orders o on c.customer_id = o.customer_id
inner join order_details od on o.order_id = od.order_id
inner join products p on od.product_id = p.product_id
group by c.customer_id, c.contact_name
order by Total_Quantity desc

--LEFT JOIN SORULARI
6-
--Hiç Sipariş Vermeyen Müşteriler Müşteriler (Customers) ve siparişler (Orders) tablolarını kullanarak hiç sipariş vermemiş müşterileri listeleyin.

select * from customers
select * from orders

SELECT c.customer_id, c.contact_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

7-
--Ürün Satmayan Tedarikçiler Tedarikçiler (Suppliers) ve ürünler (Products) tablolarını kullanarak,hiç ürün satmamış tedarikçileri listeleyin.

select * from products
select * from suppliers

SELECT s.supplier_id, s.contact_name, p.product_id
FROM  suppliers s
LEFT JOIN products p ON s.supplier_id = p.supplier_id
WHERE p.product_id IS NULL;

8-
--Siparişleri Olmayan Çalışanlar Çalışanlar (Employees) ve siparişler (Orders) tablolarını kullanarak,hiç sipariş almamış çalışanları listeleyin

select * from employees
select * from orders

SELECT e.employee_id, e.last_name, e.first_name, o.order_id
FROM  employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id
WHERE o.order_id IS NULL;

--RIGHT JOIN SORULARI
9-
--Her Sipariş İçin Müşteri Bilgisi RIGHT JOIN kullanarak, tüm siparişlerin yanında müşteri bilgilerini de listeleyin. Eğer müşteri bilgisi eksikse, "Bilinmeyen Müşteri" olarak gösterin.

select * from customers
select * from orders

SELECT o.order_id, 
       COALESCE(c.contact_name, 'Bilinmeyen Müşteri') AS contactName,
       o.order_date
FROM Orders O 
RIGHT JOIN Customers c ON o.customer_id = c.customer_id;


10-
--Tüm kategoriler ve bu kategorilere ait ürünleri listeleyin. Eğer bir kategoriye ait ürün yoksa, kategori adını ve "Ürün Yok" bilgisini gösterin.
select * from Products
select * from Categories

SELECT c.category_id, 
       c.category_name, 
       COALESCE(p.product_Name, 'Ürün Yok') AS ProductName
FROM Products p 
RIGHT JOIN Categories c ON p.category_id = c.category_id




