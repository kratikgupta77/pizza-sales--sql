-- Retrieve the total number of orders placed.
	select count(*) as total_orders from orders;
-- Calculate the total revenue generated from pizza sales.
 select sum(order_details.quantity *pizzas.price) as revenue
 from order_details
 join pizzas
 on pizzas.pizza_id=order_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name , pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc limit 1;
-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as size
from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by size desc ;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name , sum(order_details.quantity) as units
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id 
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by units desc limit 5;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name	,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by revenue DESC limit 3; 

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category	,sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id)*100 as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue DESC ; 

-- Analyze the cumulative revenue generated over time.
select date,sum(revenue) over(order by date) as cum_revenue 
from
(select orders.date ,sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id
join orders on  orders.order_id=order_details.order_id  
group by orders.date ) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name ,revenue 
from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category,pizza_types.name) as sum) as temp
where rnk>=3;