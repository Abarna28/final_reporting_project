{{ config(materialized='table') }}

with outlet as (
    select
        outlet_id,
        org_id,
        outlet_name,
        latitude,
        longitude
    from {{ ref('stg_outlet') }}
),

org as (
    select
        org_id,
        org_name
    from {{ ref('stg_org') }}
),

listing as (
    select
        listing_id,
        outlet_id,  -- ADDED: Get outlet_id from listing
        null as item_name
    from {{ ref('stg_listing') }}
),

orders as (
    select
        order_id,
        order_ts as order_timestamp,
        listing_id,
        status  -- ADDED: Include status, REMOVED: outlet_id, quantity, price, total_amount
    from {{ ref('stg_orders') }}
),

orders_daily as (
    select
        order_date as order_day,
        listing_id,  -- CHANGED: Use listing_id instead of outlet_id
        daily_orders as total_orders,
        daily_orders * 1.0 as total_revenue
    from {{ ref('stg_orders_daily') }}
),

orders_enriched as (
    select
        o.order_id,
        o.order_timestamp,
        o.status,
        l.outlet_id,  -- CHANGED: Get outlet_id from listing
        out.outlet_name,
        out.latitude,
        out.longitude,
        org.org_name,
        o.listing_id,
        l.item_name
    from orders o
    left join listing l on o.listing_id = l.listing_id  -- Join to listing first
    left join outlet out on l.outlet_id = out.outlet_id  -- Then to outlet
    left join org on out.org_id = org.org_id
),

daily_enriched as (
    select
        od.order_day,
        l.outlet_id,  -- CHANGED: Get outlet_id from listing
        out.outlet_name,
        sum(od.total_orders) as total_orders,
        sum(od.total_revenue) as total_revenue
    from orders_daily od
    left join listing l on od.listing_id = l.listing_id  -- Join to listing first
    left join outlet out on l.outlet_id = out.outlet_id  -- Then to outlet
    group by
        od.order_day,
        l.outlet_id,
        out.outlet_name
)

select
    order_id,
    order_timestamp,
    status,
    outlet_id,
    outlet_name,
    latitude,
    longitude,
    org_name,
    listing_id,
    item_name,
    null as order_day,
    null as total_orders,
    null as total_revenue
from orders_enriched

union all

select
    null as order_id,
    null as order_timestamp,
    null as status,
    outlet_id,
    outlet_name,
    null as latitude,
    null as longitude,
    null as org_name,
    null as listing_id,
    null as item_name,
    order_day,
    total_orders,
    total_revenue
from daily_enriched