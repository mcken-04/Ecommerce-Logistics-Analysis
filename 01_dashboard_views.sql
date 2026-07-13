-- Final View Created after Explority Analysis
-- Drop any old views first to prevent signature conflicts
DROP VIEW IF EXISTS vw_warehouse_bottleneck CASCADE;
DROP VIEW IF EXISTS vw_driver_performance CASCADE;
DROP VIEW IF EXISTS vw_delivery_sla_details CASCADE;
DROP VIEW IF EXISTS vw_supply_chain_lifecycle CASCADE;

-- Create the Master Analytics View
-- This view merges both logistics legs into a single clean record per order
CREATE VIEW vw_supply_chain_lifecycle AS

--Create a CTE to find the timestamp of an order_id 'Picked', 'Shipped', or 'Delivered'
WITH order_timestamps AS (
	SELECT 
		se_p.order_id,
		se_p.event_time::TIMESTAMP AS picked_time,
		se_s.event_time::TIMESTAMP AS shipped_time,
		se_d.event_time::TIMESTAMP AS delivered_time,
		se_s.driver_id
	FROM status_events se_p
	LEFT JOIN status_events se_s 
		ON se_p.order_id = se_s.order_id AND se_s.status = 'Shipped'
	LEFT JOIN status_events se_d 
		ON se_p.order_id = se_d.order_id AND se_d.status = 'Delivered'
	WHERE se_p.status = 'Picked'
)
SELECT
	ot.order_id,
	ot.driver_id,
	d.name AS driver_name,
	d.vehicle_type,
	w.warehouse_id,
	w.state AS warehouse_state,
	w.city AS warehouse_city,
	ot.shipped_time::DATE AS shipping_date,
	
	-- Leg 1: Warehouse Prep Time (Picked to Shipped)
	EXTRACT(EPOCH FROM (ot.shipped_time - ot.picked_time)) / 3600 AS hours_to_ship,
	
	-- Leg 2: Driver Transit Time (Shipped to Delivered)
	EXTRACT(EPOCH FROM (ot.delivered_time - ot.shipped_time)) / 3600 AS delivery_hours,
	
	-- SLA Compliance Status (Transit <= 48 Hours)
	CASE 
		WHEN (EXTRACT(EPOCH FROM (ot.delivered_time - ot.shipped_time)) / 3600) <= 48 THEN 1 
		ELSE 0 
	END AS is_compliant
FROM order_timestamps ot
JOIN orders o 
	ON ot.order_id = o.order_id
JOIN warehouses w 
	ON o.warehouse_id = w.warehouse_id
LEFT JOIN drivers d 
	ON ot.driver_id = d.driver_id;