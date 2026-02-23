/*
    Channel Performance — deep-dive into conversion rates, win rates,
    lost reason distribution, and deal velocity by channel.

    Grain: one row per resolved_channel (overall summary).
*/

with funnel as (

    select * from {{ ref('int__lead_opportunity_funnel') }}

),

costs as (

    select
        channel,
        sum(total_channel_cost) as total_cost_6mo
    from {{ ref('int__monthly_channel_costs') }}
    group by 1

),

-- Overall funnel metrics by channel
channel_summary as (

    select
        resolved_channel as channel,

        -- Volume
        count(distinct lead_id)                            as total_leads,
        count(distinct case when is_converted
                            then lead_id end)              as converted_leads,
        count(distinct opportunity_id)                     as total_opportunities,
        count(distinct case when demo_set_date is not null
                            then opportunity_id end)       as demos_set,
        count(distinct case when demo_held
                            then opportunity_id end)       as demos_held,
        count(distinct case when is_closed_won
                            then opportunity_id end)       as closed_won,
        count(distinct case when is_closed_lost
                            then opportunity_id end)       as closed_lost,

        -- Conversion rates
        round(count(distinct case when is_converted then lead_id end)
              * 100.0 / nullif(count(distinct lead_id), 0), 2)
            as lead_to_opp_rate_pct,

        round(count(distinct case when demo_set_date is not null then opportunity_id end)
              * 100.0 / nullif(count(distinct opportunity_id), 0), 2)
            as opp_to_demo_set_rate_pct,

        round(count(distinct case when demo_held then opportunity_id end)
              * 100.0 / nullif(count(distinct case when demo_set_date is not null then opportunity_id end), 0), 2)
            as demo_set_to_held_rate_pct,

        round(count(distinct case when is_closed_won then opportunity_id end)
              * 100.0 / nullif(count(distinct case when demo_held then opportunity_id end), 0), 2)
            as demo_held_to_won_rate_pct,

        -- Win rate (of all closed deals)
        round(count(distinct case when is_closed_won then opportunity_id end)
              * 100.0 / nullif(
                  count(distinct case when is_closed_won then opportunity_id end)
                + count(distinct case when is_closed_lost then opportunity_id end), 0
              ), 2)
            as win_rate_pct,

        -- LTV
        avg(case when is_closed_won then estimated_annual_ltv end) as avg_ltv_won_deals,
        sum(case when is_closed_won then estimated_annual_ltv end) as total_ltv_won_deals,

        -- Deal velocity
        avg(days_to_close) as avg_days_to_close,
        avg(days_to_demo)  as avg_days_to_demo,
        avg(total_touches)  as avg_touches_per_lead

    from funnel
    group by 1

),

-- Lost reason breakdown by channel
lost_reasons as (

    select
        resolved_channel as channel,
        lost_reason,
        count(distinct opportunity_id) as lost_count
    from funnel
    where is_closed_lost
      and lost_reason is not null
      and lost_reason != ''
    group by 1, 2

),

-- Top lost reason per channel
top_lost_reason as (

    select
        channel,
        lost_reason as top_lost_reason,
        lost_count  as top_lost_reason_count
    from lost_reasons
    qualify row_number() over (partition by channel order by lost_count desc) = 1

),

final as (

    select
        cs.*,

        c.total_cost_6mo,

        -- Cost-based unit economics (6-month totals)
        case when cs.closed_won > 0
             then c.total_cost_6mo / cs.closed_won
        end as cac_6mo,

        case when cs.closed_won > 0 and cs.avg_ltv_won_deals is not null
             then cs.avg_ltv_won_deals / nullif(c.total_cost_6mo / cs.closed_won, 0)
        end as ltv_to_cac_ratio_6mo,

        case when cs.total_leads > 0
             then c.total_cost_6mo / cs.total_leads
        end as cost_per_lead_6mo,

        tlr.top_lost_reason,
        tlr.top_lost_reason_count

    from channel_summary as cs
    left join costs as c
        on cs.channel = c.channel
    left join top_lost_reason as tlr
        on cs.channel = tlr.channel

)

select * from final
order by channel
