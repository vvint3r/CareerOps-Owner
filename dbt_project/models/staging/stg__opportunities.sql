with source as (

    select * from {{ source('gtm_case', 'opportunities') }}

),

cleaned as (

    select
        opportunity_id,
        stage_name,
        lost_reason_c   as lost_reason,
        closed_lost_notes_c as closed_lost_notes,
        business_issue_c    as business_issue,
        how_did_you_hear_about_us_c as how_did_you_hear_about_us,

        try_to_timestamp(created_date) as created_date,

        case
            when upper(demo_held) = 'TRUE' then true
            else false
        end as demo_held,

        -- Fix year prefix typo (00XX -> 20XX) on date-only fields
        case
            when demo_set_date is not null and demo_set_date != ''
                then try_to_date(regexp_replace(demo_set_date, '^00', '20'), 'YYYY-MM-DD')
        end as demo_set_date,

        try_to_timestamp(demo_time) as demo_time,

        case
            when close_date is not null and close_date != ''
                then try_to_date(regexp_replace(close_date, '^00', '20'), 'YYYY-MM-DD')
        end as close_date,

        try_to_timestamp(last_sales_call_date_time) as last_sales_call_date_time,
        account_id,

        -- Derived: stage boolean flags
        stage_name = 'Closed Won'  as is_closed_won,
        stage_name = 'Closed Lost' as is_closed_lost,
        stage_name not in ('Closed Won', 'Closed Lost') as is_open,

        -- Derived: channel bucket from attribution field
        case
            when how_did_you_hear_about_us_c in ('Facebook/IG', 'Media Outlet', 'Youtube', 'Word of mouth')
                then 'inbound'
            when how_did_you_hear_about_us_c = 'Cold call'
                then 'outbound'
            else 'unknown'
        end as attributed_channel,

        -- Derived: days from opportunity creation to close
        case
            when close_date is not null and close_date != '' and created_date is not null
                then datediff(
                    'day',
                    try_to_timestamp(created_date)::date,
                    try_to_date(regexp_replace(close_date, '^00', '20'), 'YYYY-MM-DD')
                )
        end as days_to_close,

        -- Derived: days from opportunity creation to demo
        case
            when demo_time is not null and created_date is not null
                then datediff(
                    'day',
                    try_to_timestamp(created_date)::date,
                    try_to_timestamp(demo_time)::date
                )
        end as days_to_demo,

        -- Derived: month of opportunity creation for time-series analysis
        date_trunc('month', try_to_timestamp(created_date))::date as created_month

    from source

)

select * from cleaned
