{{ config(materialized='table') }}

with hourly as (
    select
        outlet_id,
        observation_date,
        temperature_celsius,
        wind_speed_10m,
        relative_humidity_2m
    from {{ ref('stg_weather_hourly') }}
)

select
    outlet_id,
    observation_date,
    avg(temperature_celsius) as avg_temperature_celsius,
    avg(wind_speed_10m) as avg_wind_speed_10m,
    avg(relative_humidity_2m) as avg_relative_humidity_2m
from hourly
group by outlet_id, observation_date
order by outlet_id, observation_date
