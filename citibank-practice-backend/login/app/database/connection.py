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
    sts = boto3.client("sts", region_name=AWS_REGION)
    identity = sts.get_caller_identity()

    print(f"AWS caller identity: {identity['Arn']}")

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

    print(f"DB host: {DB_HOST}")
    print(f"DB port: {DB_PORT}")
    print(f"DB name: {DB_NAME}")
    print(f"DB user: {DB_USER}")
    print(f"AWS region: {AWS_REGION}")
    print("Attempting Aurora IAM connection...")

    connection = psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=token,
        sslmode="require",
    )

    print("Aurora IAM connection successful.")

    return connection