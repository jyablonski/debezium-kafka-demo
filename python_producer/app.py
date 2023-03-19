import datetime
import logging
import os
import random
import sys
import time

from faker import Faker
import pandas as pd
from sqlalchemy import exc, create_engine
from sqlalchemy.engine.base import Engine

logging.basicConfig(
    level=logging.INFO,
    format="[%(levelname)s] %(asctime)s %(message)s",
    datefmt="%Y-%m-%d %I:%M:%S %p",
    handlers=[logging.FileHandler("example.log"), logging.StreamHandler()],
)

logging.info("STARTING SCRIPT ...")

def sql_connection(
    rds_schema: str,
    RDS_USER: str = os.environ.get("RDS_USER"),
    RDS_PW: str = os.environ.get("RDS_PW"),
    RDS_IP: str = os.environ.get("IP"),
    RDS_DB: str = os.environ.get("RDS_DB"),
) -> Engine:
    """
    SQL Connection function to define the SQL Driver + connection variables needed to connect to the DB.
    This doesn't actually make the connection, use conn.connect() in a context manager to create 1 re-usable connection

    Args:
        rds_schema (str): The Schema in the DB to connect to.
    Returns:
        SQL Engine to a specified schema in my PostgreSQL DB
    """
    try:
        connection = create_engine(
            f"postgresql+psycopg2://{RDS_USER}:{RDS_PW}@{RDS_IP}:5432/{RDS_DB}",
            connect_args={"options": f"-csearch_path={rds_schema}"},
            # defining schema to connect to
            echo=False,
        )
        logging.info(f"SQL Engine to schema: {rds_schema} Successful")
        return connection
    except exc.SQLAlchemyError as e:
        logging.error(f"SQL Engine to schema: {rds_schema} Failed, Error: {e}")
        return e

def write_to_sql(con, table_name: str, df: pd.DataFrame, table_type: str) -> None:
    """
    SQL Table function to write a pandas data frame in aws_dfname_source format
    Args:
        con (SQL Connection): The connection to the SQL DB.
        table_name (str): The Table name to write to SQL as.
        df (DataFrame): The Pandas DataFrame to store in SQL
        table_type (str): Whether the table should replace or append to an existing SQL Table under that name
    Returns:
        Writes the Pandas DataFrame to a Table in the Schema we connected to.
    """
    try:
        if len(df) == 0:
            logging.info(f"{table_name} is empty, not writing to SQL")
        else:
            df.to_sql(
                con=con,
                name=f"{table_name}",
                index=False,
                if_exists=table_type,
            )
            logging.info(
                f"Writing {len(df)} {table_name} rows to {table_name} to SQL"
            )
    except BaseException as error:
        logging.error(f"SQL Write Script Failed, {error}")

# this is an acknowledgement function from 
# https://docs.confluent.io/clients-confluent-kafka-python/current/overview.html
# this ensures a notification upon delivery or failure of any message.
def acked(err, msg):
    if err is not None:
        logging.info(f"Failed to deliver message: {msg.value()}: {err.str()}")
    else:
        logging.info(f"Message produced: {msg.value()}")

# this takes the data out of a datetime.date(2022, 04, 06) datetime format and into a human readable date as a string
def json_serializer(obj):
    if isinstance(obj, (datetime.datetime, datetime.date)):
        return obj.isoformat()
    raise "Type %s not serializable" % type(obj)

def generate_fake_movies_data(faker: Faker):
    payload = {
        "movie_id": faker.unique.random_int(),
        "title": faker.email(),
        "release_year": faker.date_between(start_date='-105y', end_date='today').year,
        "country": faker.country(),
        "genres": random.choice(["Horror", "Comedy", "Action"]),
        "actors": faker.name(),
        "directors": faker.name(),
        "composers": faker.name(),
        "screenwriters": faker.name(),
        "cinematographer": faker.name(),
        "production_companies": faker.street_name(),
    }

    logging.info(f"Generating payload {payload['movie_id']}")

    return pd.DataFrame([payload])

if __name__ == "__main__":
    conn  = sql_connection(
        rds_schema="dbz_schema",
        RDS_USER="postgres",
        RDS_PW="postgres",
        RDS_IP="postgres",
        RDS_DB="postgres",
    )
    faker = Faker()
    starttime = time.time()
    invocations = 0

    try:
        while True:
            if invocations > 1000:
                logging.info(f"Exiting out ...")
                break
            else:
                invocations += 1
                payload = generate_fake_movies_data(faker)
                write_to_sql(conn, "second_movies", payload, "append")

                time.sleep(
                    5 - ((time.time() - starttime) % 5)
                ) # write a message every 5 seconds
                

    except Exception as e:
        logging.info(f"Error Occurred, {e}")
        sys.exit(1)