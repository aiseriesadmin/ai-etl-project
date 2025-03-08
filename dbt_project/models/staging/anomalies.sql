WITH anomalies AS (
    SELECT 
        transaction_id, 
        transaction_amount, 
        product_price, 
        discount_applied, 
        anomaly_score
    FROM staging.anomaly_detection_results
    WHERE anomaly_score = -1
)
SELECT * FROM anomalies;
