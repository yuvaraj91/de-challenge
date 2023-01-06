# Starting Airflow

Please ensure no conflicting images in Docker running on the same port.

Spin up the containers instance by running (ignore deprecation warnings):
<pre>
make airflow-up
</pre>

Airflow will then be reachable at [localhost:8080](http://localhost:8080), via these credentials:
<pre>
user: airflow
password: airflow
</pre>

# Postgres Connection
In Airflow Connections, create a Postgres Connection:

<pre>
connection id: postgres_default
host: host.docker.internal
schema: local_db
user: admin
password: admin
</pre>

## Source data

The folder containing the two csv files (data/ folder) are mounted in the volume.

## Shutting down

To shut down Airflow run:

<pre>
make airflow-down
</pre>

## Others

SQL files can be found in this folder: `dags/sql/`


## Database IDE
Connection settings in Dbeaver (or other IDE):

<pre>
host: locahost
port: 5432
database: local_db
username: admin
password: admin
</pre>


# cannot use MSQL
https://github.com/apache/airflow/discussions/25831



due to time limit and simplicity - mostly hardcoded the connection settings and other setup.

# dbt commands

check if setup is fine:

`dbt debug`

run the sample models:

`dbt run --select myoutput`

Creates the table public.myoutput

`dbt run --select average_age`

Creates the table public.average_age



Notes on running dbt in the terminal (outside Airflow)

change profiles.yml host to `localhost`




https://stackoverflow.com/questions/67876857/mysqlclient-wont-install-via-pip-on-macbook-pro-m1-with-latest-version-of-big-s


