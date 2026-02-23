with source as (

    select * from {{ source('gtm_case', 'advertising') }}

),

cleaned as (

    select
        -- Parse 'Mon-YY' into a first-of-month date
        to_date('01-' || month, 'DD-Mon-YY') as expense_month,

        -- Parse currency: "US$<tab>55 779,40" -> 55779.40
        -- Strip everything non-numeric except the comma (decimal sep), then swap comma for dot
        try_to_number(
            replace(regexp_replace(advertising, '[^0-9,]', ''), ',', '.'),
            12, 2
        ) as advertising_spend

    from source

)

select * from cleaned
