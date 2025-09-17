--Basic

--1.Retrieve the total number of orders placed

SELECT 
    COUNT(order_id) AS Total_Number_Of_Orders
FROM
    orders

--2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
--3.Identify the highest-priced pizza.

SELECT TOP 1
    pizza_types.name, ROUND(pizzas.price, 2) AS highest_price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC

--4.Identify the most common pizza size ordered.
SELECT TOP 1
    pizzas.size,
    COUNT(order_details.order_details_id) AS most_common_pizza
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY most_common_pizza DESC

--5.List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    pizza_types.name, SUM(order_details.quantity) AS quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantities DESC

--Intermediate:

--1.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC

--2.Determine the distribution of orders by hour of the day.
WITH hourly_only AS 
	(SELECT 
    DATEPART(hour, order_time) AS order_hour, order_id
FROM
    orders
)
SELECT 
    order_hour, COUNT(order_id) AS total_count
FROM
    hourly_only
GROUP BY order_hour

--3.Join relevant tables to find the category-wise distribution of pizzas.

 SELECT 
    category, COUNT(name) AS total_pizzas
FROM
    pizza_types
GROUP BY category

--4.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_quentity
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS total_quantity

--5.Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC


--Advanced:

--1.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * .pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category

--2.Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue 
FROM
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    orders
        JOIN
    order_details ON order_details.order_id = orders.order_id
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY orders.order_date) AS sales

--3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    category,
    revenue
FROM (
    SELECT 
        category,
        name,
        revenue,
        RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS ranking
    FROM (
        SELECT 
            pizza_types.category,
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM 
            pizza_types
            JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
            JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.category, 
            pizza_types.name
    ) AS b
) AS c
WHERE ranking <= 3;
