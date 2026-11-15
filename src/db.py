"""Database connection utilities for the project."""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, URL
from pathlib import Path
import pandas as pd
from sqlalchemy import text

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

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = PROJECT_ROOT / "sql"


def read_sql_file(filename: str, engine: Engine | None = None) -> pd.DataFrame:
    """Run a single SELECT statement stored in sql/<filename> and return the result.

    Keeping queries in .sql files (rather than as strings in notebooks) means the
    same query can be run from the MySQL client or from Python.
    """
    engine = engine or get_engine()
    query = (SQL_DIR / filename).read_text(encoding="utf-8")
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)