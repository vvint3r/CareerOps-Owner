with advertising as (

    select * from {{ ref('stg__advertising') }}

),

expenses as (

    select * from {{ ref('stg__expenses') }}

),

-- Inbound costs: advertising spend + inbound sales team salaries
inbound_costs as (

    select
        a.expense_month,
        'inbound'              as channel,
        a.advertising_spend    as advertising_cost,
        e.inbound_sales_team_cost as team_cost,
        a.advertising_spend + e.inbound_sales_team_cost as total_channel_cost

    from advertising as a
    inner join expenses as e
        on a.expense_month = e.expense_month

),

-- Outbound costs: outbound sales team salaries only (no ad spend)
outbound_costs as (

    select
        e.expense_month,
        'outbound'                  as channel,
        0                           as advertising_cost,
        e.outbound_sales_team_cost  as team_cost,
        e.outbound_sales_team_cost  as total_channel_cost

    from expenses as e

),

combined as (

    select * from inbound_costs
    union all
    select * from outbound_costs

)

select * from combined
