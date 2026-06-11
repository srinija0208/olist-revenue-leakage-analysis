use revenue_leakage;

-- Query 1: Monthly revenue trend with month-on-month growth %

select DATE_FORMAT(o.order_purchase_timestamp, '%y-%m') as month,
count(distinct o.order_id) as total_orders, 
round(sum(i.price),2) as total_revenue, 
round(sum(i.freight_value),2) as total_freight,
round(sum(i.freight_value)/sum(i.price)*100,2) as freight_pct,
round(sum(i.price) - lag(sum(i.price)) 
	over(order by DATE_FORMAT(o.order_purchase_timestamp, '%y-%m')),2) as month_growth
from orders o join items i 
on o.order_id = i.order_id
where o.order_status = 'delivered'
group by month
order by month;

-- Query 2: One Time vs Repeat Customer purchase rate

select sum(case when order_count >1 then 1 else 0 end) as repeat_cus,
sum(case when order_count = 1 then 1 else 0 end) as one_time_cus,
round(sum(case when order_count > 1 then 1 else 0 end) * 100 / count(*), 2) as repeat_cus_pct,
round(sum(case when order_count = 1 then 1 else 0 end) * 100 / count(*), 2) as one_time_cus_pct
from 
(select c.customer_unique_id, count(o.order_id) as order_count 
from customers c
join orders o 
on o.customer_id = c.customer_id
group by c.customer_unique_id) as sub_query;

-- Query 3: Top 10 Product categories driving the most cancellations

select c.product_category_name_english as category, count(o.order_id) as total_orders,
sum(case when o.order_status='canceled' then 1 else 0 end) as cancelled_orders,
round(sum(case when o.order_status='canceled' then 1 else 0 end) * 100 / count(o.order_id),2) as cancellation_rate_pct
from orders o
join items i on o.order_id = i.order_id
join products p on p.product_id = i.product_id
join category c on c.product_category_name = p.product_category_name
group by c.product_category_name_english
order by cancellation_rate_pct DESC
limit 10;

-- Query 4: Seller Late Delivery Analysis

with late_flags as(
	select o.order_id, i.seller_id,
    sum(i.price) as order_revenue,
    avg(r.review_score) as order_review,
    case when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 else 0 end as is_late
    from orders o 
    join items i on o.order_id = i.order_id
    join reviews r on r.order_id = o.order_id
    where o.order_status = 'delivered'
    group by o.order_id, i.seller_id,
    case when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 else 0 end
)
select seller_id, 
	count(distinct order_id) as total_orders,
    round(sum(order_revenue),2) as total_revenue,
    round(avg(order_review),2) as avg_review,
    sum(is_late) as late_orders,
    round(sum(is_late)*100/count(distinct order_id),2) as late_orders_pct
from late_flags
group by seller_id
order by late_orders_pct DESC;

-- Query 5: Revenue Loss Due to Cancellations

select p.payment_type,
round(sum(p.payment_value)) as revenue_loss,
count(distinct o.order_id) as cancelled_orders
from orders o
join payments p on o.order_id = p.order_id
where o.order_status = 'canceled'
group by p.payment_type
order by revenue_loss DESC;

-- Query 6: Top 3 Categories Per Year by Revenue

with top_cat as(
	select year(o.order_delivered_customer_date) as year,
	c.product_category_name_english as category, 
	round(sum(i.price),2) as total_revenue,
	rank() over(partition by year(o.order_delivered_customer_date) 
		order by sum(i.price) DESC) as rnk
	from orders o
	join items i on o.order_id = i.order_id
	join products p on i.product_id = p.product_id
    join category c on c.product_category_name = p.product_category_name
	where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
	group by year, category
	order by total_revenue
)
select year, category, total_revenue, rnk from top_cat
where rnk<=3 
order by year, rnk;

-- Query 7: Revenue Impact of Late Deliveries

select count(distinct o.order_id) as late_orders,
round(avg(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)),0) as avg_delay_days,
round(sum(i.price),2) as revenue_loss
from orders o
join items i on o.order_id = i.order_id
where o.order_status = 'delivered' 
and o.order_delivered_customer_date > o.order_estimated_delivery_date;

-- Query 8: Top Category Within Each State

with top_cat_state as(
    select 
    ct.product_category_name_english as category,   
    c.customer_state,
    round(sum(i.price), 2) as total_revenue,
    rank() over(partition by c.customer_state 
                order by sum(i.price) DESC) as rnk
    from orders o 
    join items i on o.order_id = i.order_id
    join products p on p.product_id = i.product_id
    join category ct on ct.product_category_name = p.product_category_name
    join customers c on c.customer_id = o.customer_id
    where o.order_status = 'delivered'
    group by c.customer_state, ct.product_category_name_english
)
select category, customer_state, total_revenue
from top_cat_state
where rnk = 1
order by total_revenue DESC;

-- Query 9: Payment Installment Risk

select count(distinct o.order_id) as total_orders,
case 
	when p.payment_installments = 1 then '1 installment'
    when p.payment_installments between 2 and 6 then '2-6 installments'
    else '7+ installments'
end as installment_bucket,
sum(case when o.order_status = 'canceled' then 1 else 0 end) as cancellations,
round(sum(case when o.order_status = 'canceled' then 1 else 0 end) * 100 / count(distinct o.order_id),2) as cancelled_pct
from orders o 
join payments p on o.order_id = p.order_id
group by installment_bucket
order by cancelled_pct DESC;

-- Query 10: Monthly late orders % (2016-2018) 

SELECT 
    year(o.order_delivered_customer_date) as year,
    month(o.order_delivered_customer_date) as month,
    COUNT(DISTINCT CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN o.order_id END) AS late_orders,
    COUNT(DISTINCT o.order_id) AS total_delivered_orders,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
            THEN o.order_id END
        ) * 100.0 / COUNT(DISTINCT o.order_id), 2
    ) AS late_orders_pct
FROM orders o
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

