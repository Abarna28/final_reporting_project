FROM apache/airflow:2.5.1

USER root
RUN apt-get update && apt-get install -y git && apt-get clean

USER airflow
RUN pip install --no-cache-dir dbt-core==1.5.0 dbt-postgres==1.5.0