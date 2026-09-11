import os


AWS_REGION = os.getenv("AWS_REGION", "us-east-2")

DB_HOST = os.getenv(
    "DB_HOST",
    "database-1-instance-1.cp6ueu08a65t.us-east-2.rds.amazonaws.com"
)

DB_PORT = int(os.getenv("DB_PORT", "5432"))

DB_NAME = os.getenv("DB_NAME", "postgres")

DB_USER = os.getenv("DB_USER", "postgres")