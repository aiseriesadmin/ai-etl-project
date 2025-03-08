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
