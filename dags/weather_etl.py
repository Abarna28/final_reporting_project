from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

from datetime import datetime, timedelta
import requests
import pandas as pd

default_args = {
    "owner": "airflow",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}

def fetch_weather_data():
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": 50.94,
        "longitude": 6.96,
        "hourly": ["temperature_2m", "relativehumidity_2m", "windspeed_10m"],
        "timezone": "UTC"
    }

    response = requests.get(url, params=params)
    data = response.json()

    df = pd.DataFrame({
        "outlet_id": [1] * len(data["hourly"]["temperature_2m"]),     
        "observation_time_utc": data["hourly"]["time"],
        "temperature_celsius": data["hourly"]["temperature_2m"],
        "relative_humidity_2m": data["hourly"]["relativehumidity_2m"],
        "wind_speed_10m": data["hourly"]["windspeed_10m"],
        "created_at": datetime.utcnow()
    })

    pg_hook = PostgresHook(postgres_conn_id="pg_dev")
    engine = pg_hook.get_sqlalchemy_engine()

    df.to_sql(
        "weather_hourly",
        engine,
        schema="public_raw",
        if_exists="append",
        index=False
    )


with DAG(
    dag_id="weather_etl",
    default_args=default_args,
    schedule_interval="0 * * * *",
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    fetch_weather = PythonOperator(
        task_id="fetch_weather",
        python_callable=fetch_weather_data
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command="cd /opt/airflow/dbt_new/reporting_project && dbt seed --profiles-dir /opt/airflow/dbt_new"
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="cd /opt/airflow/dbt_new/reporting_project && dbt run --profiles-dir /opt/airflow/dbt_new"
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="cd /opt/airflow/dbt_new/reporting_project && dbt test --profiles-dir /opt/airflow/dbt_new || true"
    )

    fetch_weather >> dbt_seed >> dbt_run >> dbt_test
