# 🚚 E-Commerce Logistics & Delivery Performance Analysis

## 📌 Executive Summary
This end-to-end data analytics project simulates and analyzes a 90-day e-commerce supply chain pipeline. The objective was to track orders from warehouse pick to final customer delivery, identify operational bottlenecks, and rank driver performance. 

By designing a custom data generation script in **Python**, querying transactional event logs in **PostgreSQL**, and building a star-schema model in **Power BI Developer Mode (`.pbip`)**, this project provides actionable operational insights to improve delivery SLA compliance.

---

## 🛠️ Tools & Technologies Used
* **Data Generation & Engineering:** Python (`pandas`, `faker`, `datetime`)
* **Database Management:** PostgreSQL
* **Data Querying & Analysis:** Advanced SQL (Common Table Expressions (CTEs), Window Functions, Date/Time Interval Extraction, Aggregations)
* **Data Visualization & Analytics:** Power BI saved in Developer Project format (`.pbip`)

---

## 📁 Repository Structure

```text
├── 01_dashboard_views.sql         # Production SQL views used to feed Power BI
├── 02_exploratory_analysis.sql    # Deep-dive EDA, anomaly detection, & supplementary views
├── data_generation_script.py      # Python script used to build relational simulation data
├── Logistics_Analysis.pbip        # Power BI Project main file
├── Logistics_Analysis.Report/     # Visual layouts, theme configurations, & report pages
└── Logistics_Analysis.Dataset/    # Semantic model, data connections, & DAX measures
