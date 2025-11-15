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
        outlet_id,
        null as item_name
    from {{ ref('stg_listing') }}
),

orders as (
    select
        order_id,
        order_ts as order_timestamp,
        listing_id,
        status
    from {{ ref('stg_orders') }}
)

select
    o.order_id,
    o.order_timestamp,
    o.status,
    l.outlet_id,
    out.outlet_name,
    out.latitude,
    out.longitude,
    org.org_name,
    o.listing_id,
    l.item_name
from orders o
left join listing l on o.listing_id = l.listing_id
left join outlet out on l.outlet_id = out.outlet_id
left join org on out.org_id = org.org_id
