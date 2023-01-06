#!/usr/bin/env python

import pandas as pd
from sqlalchemy import (Column, Date, Integer, MetaData, String, Table,
                        create_engine)
from sqlalchemy.ext.declarative import declarative_base

# Create a connection to the database
engine = create_engine('mysql://codetest:swordfish@localhost/codetest')

# Create a MetaData object
metadata = MetaData()
Base = declarative_base()

# Define and create the table if not exists
employees = Table('people', metadata,
    Column('id', Integer, primary_key=True),
    Column('given_name', String),
    Column('family_name', String),
    Column('date_of_birth', Date),
    Column('place_of_birth', String)
)
metadata.create_all(engine)


# load the csv file into a pandas DataFrame, write to the table
df = pd.read_csv('data/people.csv')

# Reflect the table from the database
people = Table('people', metadata, autoload=True)

# Open a connection to the database
conn = engine.connect()

# Use the `to_sql` method of the dataframe to load the data into the table
df.to_sql(people, conn, if_exists='append', index=False)

# Close the connection
conn.close()
