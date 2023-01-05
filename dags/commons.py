import logging
import psycopg2
import json

logger = logging.getLogger(__name__)


def create_engine() -> None:
    return psycopg2.connect("host=local_database dbname=local_db user=admin password=admin")


def copy_table(dest_table: str, src_file: str) -> None:
    conn = create_engine()
    cur = conn.cursor()
    logger.info(f'Writing file {src_file} to table {dest_table}')
    with open(src_file, 'r') as f:
        next(f)  # Skip the header row.
        cur.copy_from(f, dest_table, sep=',')
    conn.commit()
    conn.close()


def write_output_json() -> None:
    """To output a JSON file as:
    {"Scotland":8048,"Northern Ireland":1952}
    """
    conn = create_engine()
    cur = conn.cursor()
    cur.execute("SELECT * FROM myoutput")
    rows = [{'country': row[0], 'population_count': row[1]} for row in cur.fetchall()]
    output_data = {row['country']: int(row['population_count']) for row in rows}
    logger.info("Writing output file")
    with open('/opt/airflow/data/myoutput.json', 'w') as f:
        json.dump(output_data, f)
    conn.close()
