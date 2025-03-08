# AI-Driven ETL Pipeline with Fivetran, dbt, Airflow, Snowflake, and Terraform

## Overview
This project demonstrates an AI-enhanced ETL pipeline using **Fivetran** for data ingestion, **dbt** for transformation, **Apache Airflow** for orchestration, and **Snowflake** as the cloud data warehouse. **Terraform** is used to automate the deployment of infrastructure, and **AI-driven anomaly detection** is integrated to enhance data quality.

## **1. Setup the Environment**

### **Install Required Dependencies**
```bash
pip install fivetran airflow pandas scikit-learn snowflake-connector-python dbt-core dbt-snowflake
```

## **2. Infrastructure as Code (IaC) Deployment**

### **Terraform Configuration**
Deploy **Snowflake, Airflow, and Fivetran** using Terraform.

```bash
terraform init
terraform apply -auto-approve
```

## **3. Data Ingestion with Fivetran**

### **Configure Fivetran (`fivetran/config.json`)**
```json
{
  "service": "postgres",
  "host": "your_database_host",
  "port": 5432,
  "database": "transactions_db",
  "user": "your_db_user",
  "password": "your_db_password",
  "schemas": ["public"],
  "schedule": "5 minutes",
  "destination": "snowflake_staging"
}
```
Run data ingestion:
```bash
fivetran sync --config fivetran/config.json
```

## **4. Orchestration with Airflow**

### **Define DAG (`dags/ai_etl_pipeline.py`)**
```python
from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'data_team',
    'start_date': days_ago(1),
    'depends_on_past': False,
    'retries': 1,
}

with DAG('ai_etl_pipeline', default_args=default_args, schedule_interval='@daily', catchup=False) as dag:

    extract_data = BashOperator(
        task_id='fivetran_sync',
        bash_command='fivetran sync --config /path/to/fivetran/config.json'
    )

    dbt_run = BashOperator(
        task_id='run_dbt_models',
        bash_command='dbt run --project-dir /path/to/dbt_project'
    )

    anomaly_detection = BashOperator(
        task_id='ai_anomaly_detection',
        bash_command='python /path/to/scripts/ai_anomaly_detection.py'
    )

    load_to_prod = SnowflakeOperator(
        task_id='load_clean_data',
        snowflake_conn_id='snowflake_default',
        sql='CALL load_cleaned_data_procedure();'
    )

    extract_data >> dbt_run >> anomaly_detection >> load_to_prod
```

## **5. AI-Driven Anomaly Detection**

### **AI Model (`scripts/ai_anomaly_detection.py`)**
```python
import pandas as pd
from sklearn.ensemble import IsolationForest
import snowflake.connector

ctx = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account',
    warehouse='your_warehouse',
    database='your_database',
    schema='staging'
)

query = "SELECT transaction_id, transaction_amount, product_price, discount_applied FROM staging.transactions"
df = pd.read_sql(query, ctx)

model = IsolationForest(n_estimators=100, contamination=0.01, random_state=42)
df['anomaly_score'] = model.fit_predict(df[['transaction_amount', 'product_price', 'discount_applied']])

anomalies = df[df['anomaly_score'] == -1]
anomalies.to_csv('anomalies.csv', index=False)
```

Run anomaly detection:
```bash
python scripts/ai_anomaly_detection.py
```

## **6. Loading Cleaned Data into Snowflake**
### **Stored Procedure (`sql/load_cleaned_data.sql`)**
```sql
CREATE OR REPLACE PROCEDURE load_cleaned_data_procedure()
RETURNS STRING
LANGUAGE SQL
AS
$$
INSERT INTO production.transactions
SELECT * FROM staging.transactions
WHERE transaction_id NOT IN (SELECT transaction_id FROM staging.anomaly_detection_results);
$$;
```

Run the procedure in Snowflake:
```sql
CALL load_cleaned_data_procedure();
```

## **7. Running the Full Pipeline**
Trigger the full ETL process using Airflow:
```bash
airflow dags trigger ai_etl_pipeline
```