
1-
--En Çok Satış Yapan Çalışanı Bulun Her çalışanın (Employees) sattığı toplam ürün adedini hesaplayarak, en çok satış yapan ilk 3 çalışanı listeleyen sorgu
select * from employees
select * from orders
select * from order_details
select e.employee_id, e.first_name, e.last_name , SUM(od.quantity) from employees e 
inner join orders o on e.employee_id = o.employee_id
inner join order_details od on o.order_id = od.order_id
group by e.employee_id, e.first_name, e.last_name 
ORDER BY SUM(od.quantity)
DESC LIMIT 3;


2-
--Aylık Satış Trendlerini Bulun Siparişlerin (Orders) hangi yıl ve ayda ne kadar toplam satış geliri oluşturduğunu hesaplayan ve yıllara göre sıralayan sorgu .
select * from orders
select EXTRACT(YEAR FROM o.order_date) as Year, 
       EXTRACT(MONTH FROM o.order_date) AS Month,
 SUM(od.quantity * od.unit_price) as total_sales
from orders o 
inner join order_details od on o.order_id = od.order_id
GROUP BY Year, Month
order by Year, Month;

3-
--En Karlı Ürün Kategorisini Bulun Her ürün kategorisinin (Categories), o kategoriye ait ürünlerden (Products) yapılan satışlar sonucunda elde ettiği toplam geliri hesaplayan sorgu
Select * from categories
select * from products
select * from order_details
select c.category_id, c.category_name, SUM(od.quantity * od.unit_price * (1 - od.discount))  as total_sales
from categories c
inner join products p on c.category_id = p.category_id
inner join order_details od on p.product_id = od.product_id
group by c.category_id, c.category_name
order by total_sales DESC
LIMIT 1;

4-
--Belli Bir Tarih Aralığında En Çok Sipariş Veren Müşterileri Bulun 1997 yılında en fazla sipariş veren ilk 5 müşteriyi listeleyen sorgu.
select * from customers
select * from orders
select c.customer_id, c.contact_name, count(o.order_id) as total_order
from customers c 
inner join orders o on c.customer_id = o.customer_id
where EXTRACT(YEAR FROM o.order_date) = 1997 
group by c.customer_id, c.contact_name
order by total_order DESC
LIMIT 5;


5-
--Ülkelere Göre Toplam Sipariş ve Ortalama Sipariş Tutarını Bulun Müşterilerin bulunduğu ülkeye göre toplam sipariş sayısını ve ortalama sipariş tutarını hesaplayan bir sorgu yazınız. Sonucu toplam sipariş sayısına göre büyükten küçüğe sıralayın.
select * from customers
select * from orders
select * from order_details
select c.country, count(o.order_id) as total_order,
    AVG(od.quantity * od.unit_price * (1 - od.discount)) as avg_order
from customers c 
inner join orders o on c.customer_id = o.customer_id
inner join order_details od on o.order_id = od.order_id
group by c.country
order by total_order DESC