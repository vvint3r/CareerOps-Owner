with source as (

    select * from {{ source('gtm_case', 'leads') }}

),

cleaned as (

    select
        lead_id,

        -- Fix year prefix typo (00XX -> 20XX) and cast to date
        case
            when form_submission_date is not null and form_submission_date != ''
                then try_to_date(regexp_replace(form_submission_date, '^00', '20'), 'YYYY-MM-DD')
        end as form_submission_date,

        coalesce(sales_call_count, 0)  as sales_call_count,
        coalesce(sales_text_count, 0)  as sales_text_count,
        coalesce(sales_email_count, 0) as sales_email_count,

        try_to_timestamp(first_sales_call_date)    as first_sales_call_date,
        try_to_timestamp(first_text_sent_date)     as first_text_sent_date,
        try_to_timestamp(first_meeting_booked_date) as first_meeting_booked_date,
        try_to_timestamp(last_sales_call_date)     as last_sales_call_date,
        try_to_timestamp(last_sales_activity_date) as last_sales_activity_date,
        try_to_timestamp(last_sales_email_date)    as last_sales_email_date,

        -- European format (comma decimal) -> numeric; handle 'nan' and '0'
        case
            when predicted_sales_with_owner in ('nan', '', '0') or predicted_sales_with_owner is null
                then null
            else try_to_number(replace(predicted_sales_with_owner, ',', '.'), 12, 2)
        end as predicted_sales_with_owner,

        marketplaces_used,
        online_ordering_used,
        cuisine_types,

        coalesce(location_count, 0) as location_count,

        case
            when upper(connected_with_decision_maker) = 'TRUE' then true
            else false
        end as connected_with_decision_maker,

        status as lead_status,
        converted_opportunity_id,

        -- Derived: channel inference based on form submission
        case
            when form_submission_date is not null and form_submission_date != ''
                then 'inbound'
            else 'outbound'
        end as inferred_channel,

        -- Derived: total outreach touches
        coalesce(sales_call_count, 0)
            + coalesce(sales_text_count, 0)
            + coalesce(sales_email_count, 0)
        as total_touches,

        -- Derived: days from lead creation to first sales contact
        case
            when first_sales_call_date is not null
                 and form_submission_date is not null
                 and form_submission_date != ''
                then datediff(
                    'day',
                    try_to_date(regexp_replace(form_submission_date, '^00', '20'), 'YYYY-MM-DD'),
                    try_to_timestamp(first_sales_call_date)::date
                )
        end as days_to_first_contact,

        -- Derived: is this lead converted to an opportunity?
        case
            when converted_opportunity_id is not null and converted_opportunity_id != ''
                then true
            else false
        end as is_converted

    from source

)

select * from cleaned
