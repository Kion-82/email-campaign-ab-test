"""Database connection utilities for the project."""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, URL

# Load environment variables from the .env file in the project root
load_dotenv()


def get_engine() -> Engine:
    """Create a SQLAlchemy engine for the project's MySQL database.

    Connection settings are read from environment variables so that
    no credentials are hard-coded in the source code.
    """
    url = URL.create(
        drivername="mysql+pymysql",
        username=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],  # special characters are escaped automatically
        host=os.environ["MYSQL_HOST"],
        port=int(os.environ["MYSQL_PORT"]),
        database=os.environ["MYSQL_DB"],
    )
    # local_infile must be enabled on the client as well as the server
    # to allow LOAD DATA LOCAL INFILE for bulk CSV imports.
    return create_engine(url, connect_args={"local_infile": True})