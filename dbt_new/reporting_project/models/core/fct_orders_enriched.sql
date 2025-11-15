{{ config(materialized='table') }}

select *
from {{ ref('int_orders_enriched') }}
