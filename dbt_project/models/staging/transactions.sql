WITH transactions AS (
    SELECT 
        transaction_id, 
        transaction_amount, 
        product_price, 
        discount_applied,
        transaction_date
    FROM {{ source('staging', 'transactions') }}
)
SELECT * FROM transactions;
