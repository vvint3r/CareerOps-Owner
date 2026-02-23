with source as (

    select * from {{ source('gtm_case', 'expenses_salary_and_commissions') }}

),

cleaned as (

    select
        -- Parse 'Mon-YY' into a first-of-month date
        to_date('01-' || month, 'DD-Mon-YY') as expense_month,

        -- Parse currency: "US$<tab>38 075,75" -> 38075.75
        -- Strip everything non-numeric except the comma (decimal sep), then swap comma for dot
        try_to_number(
            replace(regexp_replace(outbound_sales_team, '[^0-9,]', ''), ',', '.'),
            12, 2
        ) as outbound_sales_team_cost,

        try_to_number(
            replace(regexp_replace(inbound_sales_team, '[^0-9,]', ''), ',', '.'),
            12, 2
        ) as inbound_sales_team_cost

    from source

)

select * from cleaned
