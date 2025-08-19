-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    pizzahut.orders;
    
-- Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(orders_detail_id.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_detail_id
        JOIN
    pizzas ON pizzas.pizza_id = orders_detail_id.pizza_id


-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1


-- Identify the most common pizza size ordered
SELECT 
    pizzas.size, COUNT(orders_detail_id.quantity) AS order_cout
FROM
    orders_detail_id
        JOIN
    pizzas ON pizzas.pizza_id = orders_detail_id.pizza_id
GROUP BY pizzas.size
ORDER BY order_cout DESC;


-- List the top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name,
    SUM(orders_detail_id.quantity) AS total_quan
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_detail_id ON orders_detail_id.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quan DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select sum(orders_detail_id.quantity) ,pizza_types.category 
from 
pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_detail_id 
on orders_detail_id.pizza_id = pizzas.pizza_id
group by pizza_types.category


-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) as hour, COUNT(order_id) as order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day

select avg(quantity) from
(select order_date,sum(orders_detail_id.quantity) as quantity
from orders join orders_detail_id
on orders_detail_id.order_id = orders.order_id
group by order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue

select name,sum(pizzas.price*orders_detail_id.quantity) as revenue from pizza_types
join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id
join orders_detail_id on 
orders_detail_id.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;


-- Calculate the percentage contribution of each pizza type to total revenue

select pizza_types.category,
round(sum(pizzas.price*orders_detail_id.quantity)/(SELECT 
    SUM(orders_detail_id.quantity*pizzas.price) AS total_sales
FROM orders_detail_id 
        JOIN
    pizzas ON pizzas.pizza_id = orders_detail_id.pizza_id) *100,2) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join orders_detail_id on 
orders_detail_id.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;


-- Analyze the cumulative revenue generated over time
select order_date,sum(rev) over(order by order_date) as cumulicative_rev from
(select orders.order_date,sum(orders_detail_id.quantity*pizzas.price) as rev from orders_detail_id
join pizzas on 
orders_detail_id.pizza_id = pizzas.pizza_id
join orders on orders.order_id =orders_detail_id.order_id
group by order_date) as sales  ;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category,pizza_types.name,
sum((orders_detail_id.quantity) * pizzas.price) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_detail_id 
on orders_detail_id.pizza_id = pizzas.pizza_id   
group by pizza_types.category, pizza_types.name) as A ;
