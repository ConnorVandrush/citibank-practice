import boto3
import psycopg

from app.core.config import (
    AWS_REGION,
    DB_HOST,
    DB_PORT,
    DB_NAME,
    DB_USER,
)


def get_iam_auth_token():
    """
    Generate a temporary IAM authentication token
    for connecting to Aurora PostgreSQL.
    """

    rds = boto3.client(
        "rds",
        region_name=AWS_REGION
    )

    return rds.generate_db_auth_token(
        DBHostname=DB_HOST,
        Port=DB_PORT,
        DBUsername=DB_USER,
        Region=AWS_REGION,
    )


def get_connection():
    """
    Create a connection to Aurora PostgreSQL
    using IAM database authentication.
    """

    token = get_iam_auth_token()

    connection = psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=token,
        sslmode="require",
    )

    return connection

if __name__ == "__main__":
    connection = get_connection()
    print("Successfully connected to Aurora PostgreSQL using IAM authentication.")
    connection.close()