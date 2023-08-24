from datetime import datetime
import uuid

import mysql.connector
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine.base import Connection

# https://stackoverflow.com/questions/70435792/pandas-mysql-how-to-update-some-columns-of-rows-using-a-dataframe

# mysql connector which is shit
cnx = mysql.connector.connect(
    user="mysqluser", password="mysqlpw", host="127.0.0.1", database="demo"
)
df = pd.read_sql_query(sql = "select * from demo.movies;", con=cnx)
df2 = df.query("genres == 'Western'")

# this doesnt work
df2.to_sql(name="movies_test", con=cnx, if_exists="append", index=False)

cnx.close()

# sqlalchemy connector
connection_string = "mysql+mysqlconnector://mysqluser:mysqlpw@127.0.0.1:3306/demo"
mysql_engine = create_engine(connection_string, echo=True)
connection = mysql_engine.connect()
table = "movies_test"

# this also works
# df = pd.read_sql_query(sql = "select * from demo.movies;", con=mysql_engine)
df = pd.read_sql_query(sql = "select * from demo.movies;", con=connection)
df2 = df.query("genres == 'Western'")

# insert new records
results = df2.to_sql(name="movies_test", con=connection, if_exists="append", index=False)
print(f"{results} records inserted into {table}")


# update existing records
# cant get the results returned to see how many rows were affected
sql = """
UPDATE movies_test
SET release_year = 2023, created_at = now()
WHERE genres = 'Western'
"""
z = connection.execute(sql)

# only keep the pk and the column(s) to update
df2["country"] = "Zimbabwe"
df2 = df2[["id", "country"]]

sql = """ss
UPDATE movies_test
SET country = :country, created_at_datetime = now()
WHERE id = :id
"""

params = df2.to_dict("records")
# text is needed so it can understand the :country bullshit
connection.execute(text(sql), params)


# CREATE TEMPORARY TABLE test SELECT * FROM PostStaySurveyModeration LIMIT 0;
# poststaysurvey crap
reviews_json = {
    "postStaySurveyId": [1, 2, 3],
    "machineReviewStatus": ["REJECTED", "NEEDS_HUMAN_REVIEW", "APPROVED"],
    "humanReviewStatus": [None, None, None],
    "campspotResponse": [None, None, None],
    "campspotInternalComment": ["", "", ""],
    "parkResponse": [None, None, None],
    "parkComment": ["", "", ""],
    "viewable": [None, None, None],
    "language": ["eng", "eng", "eng"],
}

reviews = pd.DataFrame(data=reviews_json)
reviews["uuid"] = [str(uuid.uuid4()) for _ in range(len(reviews))]

# only keep the pk and the column(s) to update
reviews_to_delete = reviews[["postStaySurveyId"]]

sql_delete = """
DELETE FROM PostStaySurveyModeration
WHERE postStaySurveyId = :postStaySurveyId
"""
params = reviews.to_dict("records")
connection.execute(text(sql_delete), params)

reviews.to_sql(name="PostStaySurveyModeration", con=connection, if_exists="append", index=False)
connection.close()