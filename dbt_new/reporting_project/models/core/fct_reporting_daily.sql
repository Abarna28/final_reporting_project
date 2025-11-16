{{ config(materialized='table') }}

select 
    o.listing_id,
    o.outlet_id,
    o.org_name,
    date(o.order_timestamp) as date,
    w.avg_temperature_celsius,
    w.avg_wind_speed_10m,
    w.avg_relative_humidity_2m
from {{ ref('fct_orders_enriched') }} o
left join {{ ref('fct_weather_daily') }} w
    on o.outlet_id = w.outlet_id
    and date(o.order_timestamp) = w.observation_date
