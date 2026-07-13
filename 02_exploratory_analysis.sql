DROP VIEW IF EXISTS vw_warehouse_bottleneck;
DROP VIEW IF EXISTS vw_driver_performance;

-- Warehouse Bottleneck
-- Calculate the the time delta between 'Picked' and 'Shipped' to find the warehouse that struggling with average hours to ship.

CREATE OR REPLACE VIEW vw_warehouse_bottleneck AS

WITH picked_shipped AS (
	SELECT 
		se.order_id ,
		se.event_time::timestamp   AS picked_time,
		se2.event_time::timestamp  AS shipped_time
	FROM status_events se
	JOIN status_events se2 
		ON se.order_id  = se2.order_id 
		AND se.status  = 'Picked' AND se2.status = 'Shipped' 
)

SELECT 
	w.warehouse_id,
	w.city,
	w.state ,
	AVG(EXTRACT(EPOCH FROM(ps.shipped_time - ps.picked_time) / 3600)) AS avg_hours_to_ship
FROM picked_shipped ps
JOIN orders o 
	ON ps.order_id = o.order_id
JOIN warehouses w 
	ON o.warehouse_id = w.warehouse_id 
GROUP BY w.warehouse_id , w.city , w.state 
ORDER BY avg_hours_to_ship DESC;
	

-- Ranking Driver Performance
-- Rank the delivery drivers based off of 'shipped' to 'delivered'

CREATE OR REPLACE VIEW vw_driver_performance_id AS

WITH shipped_delivered AS (
	SELECT
		se.driver_id, 
		se.event_time::timestamp AS shipped_time,
		se2.event_time ::timestamp  AS deliver_time
	FROM status_events se
	JOIN status_events se2 
		ON se.order_id  = se2.order_id  
		AND se.status ='Shipped' AND se2.status = 'Delivered'
),

delivery_time AS (
	SELECT
		driver_id,
		AVG(EXTRACT(EPOCH FROM(deliver_time - shipped_time)) / 3600) AS avg_hours_delivered 
	FROM shipped_delivered
	GROUP BY driver_id
)

SELECT
	d.driver_id, 
	d.name,
	d.vehicle_type,
	RANK() OVER(ORDER BY dt.avg_hours_delivered DESC) AS driver_rank,
	dt.avg_hours_delivered
FROM delivery_time dt
JOIN drivers d 
	ON dt.driver_id = d.driver_id
ORDER BY driver_rank ASC;


-------------------------------------------------------------------------------------------------


-- Created a new set of views to include additional columns to create a measurment in Power BI

-- Drop the existing views to clear old column signatures
DROP VIEW IF EXISTS vw_warehouse_bottleneck;
DROP VIEW IF EXISTS vw_driver_performance;

-- 1. Recreate the Warehouse Bottleneck View
-- Include warehouse_id, city, state, and avg_hours_to_ship for measue in Power BI
CREATE VIEW vw_warehouse_bottleneck AS
WITH picked_shipped AS (
	SELECT 
		se.order_id,
		se.event_time::TIMESTAMP AS picked_time,
		se2.event_time::TIMESTAMP AS shipped_time
	FROM status_events se
	JOIN status_events se2 
		ON se.order_id = se2.order_id  
		AND se.status = 'Picked' 
		AND se2.status = 'Shipped' 
)
SELECT 
	w.warehouse_id,
	w.city,
	w.state,
	AVG((EXTRACT(EPOCH FROM (ps.shipped_time - ps.picked_time))) / 3600) AS avg_hours_to_ship
FROM picked_shipped ps
JOIN Orders o 
	ON ps.order_id = o.order_id
JOIN Warehouses w 
	ON o.warehouse_id = w.warehouse_id
GROUP BY 
	w.warehouse_id, 
	w.city, 
	w.state;

-- 2. Recreate the Driver Performance View
-- Include driver_id, name, vehicle_type, avg_delivery_hours, and driver_rank for Power BI
CREATE VIEW vw_driver_performance AS
WITH shipped_delivered AS (
	SELECT
		se.order_id,
		se.driver_id, 
		se.event_time::timestamp AS shipped_time,
		se2.event_time::timestamp AS deliver_time
	FROM status_events se
	JOIN status_events se2 
		ON se.order_id = se2.order_id 
		AND se.status = 'Shipped' 
		AND se2.status = 'Delivered'
),
delivery_time AS (
	SELECT
		driver_id,
		AVG((EXTRACT(EPOCH FROM (deliver_time - shipped_time))) / 3600) AS avg_delivery_hours 
	FROM shipped_delivered
	GROUP BY driver_id
)
SELECT
	d.driver_id, 
	d.name,
	d.vehicle_type,
	dt.avg_delivery_hours, 
	RANK() OVER(ORDER BY dt.avg_delivery_hours DESC) AS driver_rank
FROM delivery_time dt
JOIN drivers d 
	ON dt.driver_id = d.driver_id;