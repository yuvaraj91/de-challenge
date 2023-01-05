import datetime
from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.bash import BashOperator
from airflow.utils.task_group import TaskGroup
import logging
from commons import copy_table, write_output_json

logger = logging.getLogger(__name__)
DBT_PROJECT_DIR = '/opt/airflow/dbt'

with DAG(
    dag_id='fotograf-de-challenge',
    start_date=datetime.datetime(2023, 1, 1),
    schedule_interval="@once",
    catchup=False,
    ) as dag:

    start = EmptyOperator(
        dag=dag,
        task_id='start'
    )
    
    with TaskGroup(group_id="loading_data") as load_data:
        create_places = PostgresOperator(
            task_id='create_places_table',
            sql='./sql/create_table_places.sql'
        )

        create_people = PostgresOperator(
            task_id='create_people_table',
            sql='./sql/create_table_people.sql'
        )

        load_places = PythonOperator(
            task_id='load_places_table',
            python_callable=copy_table,
            op_kwargs={"dest_table": "places",
                       "src_file": "/opt/airflow/data/places.csv"}
        )

        load_people = PythonOperator(
            task_id='load_people_table',
            python_callable=copy_table,
            op_kwargs={"dest_table": "people",
                       "src_file": "/opt/airflow/data/people.csv"}
        )

        create_places >> load_places
        create_people >> load_people
    
    dbt_myoutput = BashOperator(
        task_id='dbt_myoutput',
        bash_command=f"dbt run --profiles-dir {DBT_PROJECT_DIR} --project-dir {DBT_PROJECT_DIR} --select myoutput",
        )
    
    dbt_average_age = BashOperator(
        task_id='dbt_average_age',
        bash_command=f"dbt run --profiles-dir {DBT_PROJECT_DIR} --project-dir {DBT_PROJECT_DIR} --select average_age",
        )
    
    write_output = PythonOperator(
            task_id='write_output_json_file',
            python_callable=write_output_json
        )

    end = EmptyOperator(
        dag=dag,
        task_id='end'
    )

    start >> load_data >> dbt_myoutput >> dbt_average_age >> write_output >> end
