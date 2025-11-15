Final Reporting Project — ELT Pipeline (Airflow, dbt, Postgres, Open-Meteo)

Summary
This repository implements an end-to-end ELT pipeline that processes raw restaurant and order datasets, fetches hourly weather data via Airflow, loads all data into Postgres, and transforms it into clean, analytics-ready reporting tables using dbt.  
The objective is to produce a unified reporting model that allows the business to evaluate daily performance and understand relationships between sales, platform data, ratings, rank, and weather conditions.

Project Objectives (Based on Assessment Requirements)
- Clean, standardize, and deduplicate raw CSV data.  
- Model the data using staging, intermediate, and fact layers in dbt.  
- Produce a reporting-ready fact table containing listing, outlet, organization, platform, date, orders, aggregated orders, ratings, rating deltas, and ranking metrics.  
- Fetch hourly weather metrics from the Open-Meteo API using an Airflow DAG and load them into Postgres.  
- Aggregate weather data into daily metrics to support sales and performance analysis.  
- Implement robust data quality tests using dbt.  
- Provide clean SQL and Python code and deliver the project in a structured Git repository.

Architecture Overview

Raw Data (CSV Seeds)  
    → Loaded via dbt seed into Postgres as raw tables  

Hourly Weather Data (Open-Meteo API)  
    → Extracted through Airflow DAG  
    → Transformed into tabular format  
    → Loaded into Postgres as public_raw.weather_hourly  

Warehouse Transformations (dbt)  
    1. Staging models     (cleaning and standardizing raw data)  
    2. Intermediate models (joining and enriching datasets)  
    3. Fact models         (final reporting tables)  

Final Output  
    - fct_orders_enriched  
    - fct_weather_daily  

## Repository Structure

```
Airflow - final_reporting_project/
│
├── README.md
├── docker-compose.yml
│
├── airflow/
│   └── dags/
│       └── weather_etl.py
│
├── dbt_new/
│   └── reporting_project/
│       ├── dbt_project.yml
│       ├── packages.yml
│       │
│       ├── models/
│       │   ├── sources.yml
│       │
│       │   ├── staging/
│       │   │   ├── stg_orders.sql
│       │   │   ├── stg_orders_daily.sql
│       │   │   ├── stg_listing.sql
│       │   │   ├── stg_org.sql
│       │   │   ├── stg_outlet.sql
│       │   │   └── schema.yml
│       │
│       │   ├── intermediate/
│       │   │   ├── int_orders_enriched.sql
│       │   │   ├── int_weather_hourly_aggregates.sql
│       │   │   └── int_models.yml
│       │
│       │   └── core/
│       │       ├── fct_orders_enriched.sql
│       │       ├── fct_weather_daily.sql
│       │       └── core.yml
│       │
│       ├── seeds/
│       │   ├── listing.csv
│       │   ├── orders.csv
│       │   ├── orders_daily.csv
│       │   ├── org.csv
│       │   ├── outlet.csv
│       │   ├── platform.csv
│       │   ├── rank.csv
│       │   └── ratings_agg.csv
│       │
│       ├── macros/
│       └── analyses/
│
└── data_raw/
    └── weather_raw_open_meteo.json
```


dbt Model Layers

1. Staging Models (stg_*)
   - Clean and standardize raw CSV data.
   - Apply data type corrections.
   - Remove duplicates and fix null inconsistencies.

2. Intermediate Models (int_*)
   - Join listing, outlet, org, and platform data.
   - Enrich orders with metadata.
   - Aggregate hourly weather into daily, outlet-level metrics.

3. Fact Models (fct_*)
   - fct_orders_enriched: One row per order with listing, outlet, org, platform, ratings, rank, and timestamp fields.
   - fct_weather_daily: One row per outlet per day with aggregated temperature, humidity, and wind metrics.

Weather ETL (Airflow)
DAG: weather_etl.py

- Sends HTTP requests to Open-Meteo API to fetch hourly weather metrics.
- Parses and converts JSON into a structured DataFrame.
- Loads the result into Postgres (public_raw.weather_hourly).
- dbt later aggregates this into daily reporting metrics.

How to Run the Project

1. Start Airflow
   docker-compose up -d  
   Access Airflow UI at http://localhost:8080  
   Trigger the weather_etl DAG.

2. Run dbt Transformations
   cd dbt_new/reporting_project  
   dbt seed  
   dbt run  
   dbt test  

Data Quality Checks
Implemented using dbt tests:
- not_null tests for critical fields  
- unique test on order_id  
- relationships tests for listing_id and outlet_id  
- freshness tests for weather data  

ELT Approach
This project uses ELT:
- Extract raw data (API + CSV)
- Load into Postgres with minimal transformation
- Transform inside the warehouse using SQL models

This approach ensures reproducibility, transparency, and efficient use of warehouse compute.

Notes
This project was created specifically for a data engineering assessment.  
The company name is intentionally omitted as requested.
