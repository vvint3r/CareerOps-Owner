/*
    GTM Unit Economics — monthly + channel grain.
    Core SSOT model for tracking CAC, LTV, and CAC:LTV ratio over time.

    Grain: one row per (month, resolved_channel).
*/

with funnel as (

    select * from {{ ref('int__lead_opportunity_funnel') }}

),

costs as (

    select * from {{ ref('int__monthly_channel_costs') }}

),

-- Aggregate funnel metrics by month + channel at the opportunity level
monthly_funnel as (

    select
        opportunity_created_month                        as month,
        resolved_channel                                 as channel,

        -- Volume metrics
        count(distinct lead_id)                          as total_leads,
        count(distinct opportunity_id)                   as total_opportunities,
        count(distinct case when demo_set_date is not null
                            then opportunity_id end)     as demos_set,
        count(distinct case when demo_held
                            then opportunity_id end)     as demos_held,
        count(distinct case when demo_held = false
                             and opportunity_id is not null
                            then opportunity_id end)     as demos_not_held,
        count(distinct case when is_closed_won
                            then opportunity_id end)     as closed_won,
        count(distinct case when is_closed_lost
                            then opportunity_id end)     as closed_lost,
        count(distinct case when is_open
                            then opportunity_id end)     as open_pipeline,

        -- Revenue estimates for won deals
        sum(case when is_closed_won
                 then estimated_annual_ltv end)           as total_estimated_annual_revenue,
        avg(case when is_closed_won
                 then estimated_annual_ltv end)           as avg_ltv_per_won_deal,

        -- Predicted revenue across all leads (for sizing the addressable market)
        avg(predicted_sales_with_owner)                  as avg_predicted_monthly_sales,

        -- Sales effort
        avg(total_touches)                               as avg_touches_per_lead,
        avg(days_to_close)                               as avg_days_to_close

    from funnel
    where opportunity_created_month is not null
    group by 1, 2

),

-- Join costs onto the monthly funnel metrics
with_costs as (

    select
        mf.*,

        c.advertising_cost,
        c.team_cost,
        c.total_channel_cost,

        -- Unit economics
        case
            when mf.closed_won > 0
                then c.total_channel_cost / mf.closed_won
        end as cac,

        case
            when mf.closed_won > 0 and mf.avg_ltv_per_won_deal is not null
                then mf.avg_ltv_per_won_deal / nullif(c.total_channel_cost / mf.closed_won, 0)
        end as ltv_to_cac_ratio,

        -- Cost per funnel stage
        case
            when mf.total_leads > 0
                then c.total_channel_cost / mf.total_leads
        end as cost_per_lead,

        case
            when mf.total_opportunities > 0
                then c.total_channel_cost / mf.total_opportunities
        end as cost_per_opportunity,

        case
            when mf.demos_held > 0
                then c.total_channel_cost / mf.demos_held
        end as cost_per_demo

    from monthly_funnel as mf
    left join costs as c
        on mf.month = c.expense_month
        and mf.channel = c.channel

)

select * from with_costs
order by month, channel
