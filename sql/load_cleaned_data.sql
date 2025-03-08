CREATE OR REPLACE PROCEDURE load_cleaned_data_procedure()
RETURNS STRING
LANGUAGE SQL
AS
$$
INSERT INTO production.transactions
SELECT * FROM staging.transactions
WHERE transaction_id NOT IN (SELECT transaction_id FROM staging.anomaly_detection_results);
$$;
