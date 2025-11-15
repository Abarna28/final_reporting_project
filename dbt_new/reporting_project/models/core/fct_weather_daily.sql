{{ config(materialized='table') }}

select
    outlet_id,
    observation_date,
    avg_temperature_celsius,
    avg_wind_speed_10m,
    avg_relative_humidity_2m
from {{ ref('int_weather_hourly_aggregates') }}
order by outlet_id, observation_date
