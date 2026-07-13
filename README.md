# Ecommerce Logistics & Delivery Performance Analysis
End-to-end logistics analysis using Python, PostgreSQL, and Power BI
## Executive Summary
This project evalutes end-to-end logistics performance across warehouse and delivery drivers. Identifying supply chain bottlenecks and driver delivery trends. Utilizing custom-genrated simulation data in Python, relational modeling in PsotgreSQL, and dynamic reporting in Power BI. This analysis isolates core operational inefficiencies affecting SLA compliance.

---

## Tech Stack & Tools
* **Data Simultion:** Python (`pandas`, `faker`, `datetime`)
* **Data Engine:** PostgreSQL
* **Data Querying & EDA:** SQL (CTEs, Window Functions, Interval Math, Aggregations)
* **Data Visualization:** Power Bi (`.pbip` Developer Mode with Star_Schema design)

---

## Repository Structure
```text
├── 01_dashboard_views.sql         # Production SQL Views feeding Power BI
├── 02_exploratory_analysis.sql    # Deep-dive EDA queries & anomaly detection
├── data_generation_script.py      # Python script generating relational dataset
├── Logistics_Analysis.pbip        # Power BI Project main file
├── Logistics_Analysis.Report/     # Power BI visual layouts & report configs
└── Logistics_Analysis.Dataset/    # Semantic model & DAX calculations
