with leads as (

    select * from {{ ref('stg__leads') }}

),

opportunities as (

    select * from {{ ref('stg__opportunities') }}

),

joined as (

    select
        l.lead_id,
        l.form_submission_date,
        l.lead_status,
        l.inferred_channel,
        l.predicted_sales_with_owner,
        l.sales_call_count,
        l.sales_text_count,
        l.sales_email_count,
        l.total_touches,
        l.days_to_first_contact,
        l.connected_with_decision_maker,
        l.location_count,
        l.cuisine_types,
        l.marketplaces_used,
        l.online_ordering_used,
        l.is_converted,
        l.first_sales_call_date,
        l.last_sales_activity_date,

        o.opportunity_id,
        o.stage_name,
        o.lost_reason,
        o.closed_lost_notes,
        o.business_issue,
        o.how_did_you_hear_about_us,
        o.created_date       as opportunity_created_date,
        o.demo_held,
        o.demo_set_date,
        o.demo_time,
        o.close_date,
        o.is_closed_won,
        o.is_closed_lost,
        o.is_open,
        o.attributed_channel as opp_attributed_channel,
        o.days_to_close,
        o.days_to_demo,
        o.created_month      as opportunity_created_month,
        o.account_id,

        -- Resolved channel: opportunity attribution takes priority, then lead-level inference
        coalesce(
            nullif(o.attributed_channel, 'unknown'),
            l.inferred_channel
        ) as resolved_channel,

        -- Funnel stage (ordered for analysis)
        case
            when o.is_closed_won                       then '5_closed_won'
            when o.is_closed_lost and o.demo_held       then '4_closed_lost_after_demo'
            when o.is_closed_lost and not o.demo_held   then '3_closed_lost_no_demo'
            when o.opportunity_id is not null and o.is_open then '2_open_opportunity'
            when l.is_converted                         then '2_open_opportunity'
            else '1_lead_only'
        end as funnel_stage,

        -- Estimated annual LTV: $500/mo subscription + 5% take rate on predicted monthly online sales
        case
            when l.predicted_sales_with_owner is not null
                then (500.00 * 12) + (l.predicted_sales_with_owner * 0.05 * 12)
        end as estimated_annual_ltv

    from leads as l
    left join opportunities as o
        on l.converted_opportunity_id = o.opportunity_id

)

select * from joined
