import os
import getpass
import boto3
import bcrypt
import psycopg
from psycopg.types.json import Jsonb


# ============================================================
# Configuration
# ============================================================

AWS_REGION = os.getenv("AWS_REGION", "us-east-2")

DB_HOST = os.getenv(
    "DB_HOST",
    "database-1-instance-1.cp6ueu08a65t.us-east-2.rds.amazonaws.com"
)

DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")


# ============================================================
# IAM Authentication
# ============================================================

def get_iam_auth_token():
    """
    Generate a temporary IAM authentication token for Aurora.
    The token is valid for approximately 15 minutes.
    """

    rds = boto3.client("rds", region_name=AWS_REGION)

    token = rds.generate_db_auth_token(
        DBHostname=DB_HOST,
        Port=DB_PORT,
        DBUsername=DB_USER,
        Region=AWS_REGION,
    )

    return token


# ============================================================
# Database Connection
# ============================================================

def get_connection():
    """
    Connect to Aurora PostgreSQL using IAM authentication.
    SSL is required for IAM database authentication.
    """

    token = get_iam_auth_token()

    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=token,
        sslmode="require",
    )


# ============================================================
# Password Hashing
# ============================================================

def hash_password(password):
    """
    Hash an application user's password using bcrypt.
    """

    password_bytes = password.encode("utf-8")

    hashed = bcrypt.hashpw(
        password_bytes,
        bcrypt.gensalt()
    )

    return hashed.decode("utf-8")


# ============================================================
# Database Schema
# ============================================================

def recreate_tables(conn):

    with conn.cursor() as cur:

        print("Dropping existing tables...")

        cur.execute("""
            DROP TABLE IF EXISTS expenses;
        """)

        cur.execute("""
            DROP TABLE IF EXISTS users;
        """)

        print("Creating users table...")

        cur.execute("""
            CREATE TABLE users (
                user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                email VARCHAR(255) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                role VARCHAR(50) NOT NULL,
                manager_id BIGINT,
                CONSTRAINT fk_users_manager
                    FOREIGN KEY (manager_id)
                    REFERENCES users(user_id)
            );
        """)

        print("Creating expenses table...")

        cur.execute("""
            CREATE TABLE expenses (
                expense_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                employee_id BIGINT NOT NULL,
                expense_info JSONB NOT NULL,
                status VARCHAR(50) NOT NULL DEFAULT 'SUBMITTED',
                submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                approved_at TIMESTAMPTZ,
                approved_by BIGINT,

                CONSTRAINT fk_expenses_employee
                    FOREIGN KEY (employee_id)
                    REFERENCES users(user_id),

                CONSTRAINT fk_expenses_approved_by
                    FOREIGN KEY (approved_by)
                    REFERENCES users(user_id)
            );
        """)

    conn.commit()

    print("Tables created successfully.")


# ============================================================
# Seed Users
# ============================================================

def seed_users(conn):

    # --------------------------------------------------------
    # Hash passwords with bcrypt
    # --------------------------------------------------------

    manager_password = hash_password("Manager123!")
    manager2_password = hash_password("Manager456!")

    finance_password = hash_password("Finance123!")
    finance2_password = hash_password("Finance456!")

    employee_password = hash_password("Employee123!")
    employee2_password = hash_password("Employee456!")
    employee3_password = hash_password("Employee789!")

    with conn.cursor() as cur:

        # ----------------------------------------------------
        # Managers
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role
            )
            VALUES (%s, %s, %s)
            RETURNING user_id;
        """, (
            "manager1@example.com",
            manager_password,
            "MANAGER"
        ))

        manager1_id = cur.fetchone()[0]

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role
            )
            VALUES (%s, %s, %s)
            RETURNING user_id;
        """, (
            "manager2@example.com",
            manager2_password,
            "MANAGER"
        ))

        manager2_id = cur.fetchone()[0]

        # ----------------------------------------------------
        # Finance Administrators
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role
            )
            VALUES (%s, %s, %s)
            RETURNING user_id;
        """, (
            "finance1@example.com",
            finance_password,
            "FINANCE_ADMIN"
        ))

        finance1_id = cur.fetchone()[0]

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role
            )
            VALUES (%s, %s, %s)
            RETURNING user_id;
        """, (
            "finance2@example.com",
            finance2_password,
            "FINANCE_ADMIN"
        ))

        finance2_id = cur.fetchone()[0]

        # ----------------------------------------------------
        # Employees
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role,
                manager_id
            )
            VALUES (%s, %s, %s, %s)
            RETURNING user_id;
        """, (
            "employee1@example.com",
            employee_password,
            "EMPLOYEE",
            manager1_id
        ))

        employee1_id = cur.fetchone()[0]

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role,
                manager_id
            )
            VALUES (%s, %s, %s, %s)
            RETURNING user_id;
        """, (
            "employee2@example.com",
            employee2_password,
            "EMPLOYEE",
            manager1_id
        ))

        employee2_id = cur.fetchone()[0]

        cur.execute("""
            INSERT INTO users (
                email,
                password_hash,
                role,
                manager_id
            )
            VALUES (%s, %s, %s, %s)
            RETURNING user_id;
        """, (
            "employee3@example.com",
            employee3_password,
            "EMPLOYEE",
            manager2_id
        ))

        employee3_id = cur.fetchone()[0]

    conn.commit()

    print("Users seeded successfully.")

    return {
        "manager1": manager1_id,
        "manager2": manager2_id,
        "finance1": finance1_id,
        "finance2": finance2_id,
        "employee1": employee1_id,
        "employee2": employee2_id,
        "employee3": employee3_id,
    }


# ============================================================
# Seed Expenses
# ============================================================

def seed_expenses(conn, users):

    with conn.cursor() as cur:

        # ----------------------------------------------------
        # Employee 1 - Submitted expense
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO expenses (
                employee_id,
                expense_info,
                status
            )
            VALUES (%s, %s, %s);
        """, (
            users["employee1"],
            Jsonb({
                "description": "Business lunch",
                "category": "MEALS",
                "amount": 45.75,
                "currency": "USD",
                "merchant": "Downtown Restaurant",
                "receipt": "receipt-001.pdf"
            }),
            "SUBMITTED"
        ))

        # ----------------------------------------------------
        # Employee 1 - Approved expense
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO expenses (
                employee_id,
                expense_info,
                status,
                approved_at,
                approved_by
            )
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP, %s);
        """, (
            users["employee1"],
            Jsonb({
                "description": "Hotel for business trip",
                "category": "LODGING",
                "amount": 325.00,
                "currency": "USD",
                "merchant": "Business Hotel",
                "receipt": "receipt-002.pdf"
            }),
            "APPROVED",
            users["manager1"]
        ))

        # ----------------------------------------------------
        # Employee 2 - Submitted expense
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO expenses (
                employee_id,
                expense_info,
                status
            )
            VALUES (%s, %s, %s);
        """, (
            users["employee2"],
            Jsonb({
                "description": "Taxi to client office",
                "category": "TRANSPORTATION",
                "amount": 32.50,
                "currency": "USD",
                "merchant": "City Taxi",
                "receipt": "receipt-003.pdf"
            }),
            "SUBMITTED"
        ))

        # ----------------------------------------------------
        # Employee 2 - Rejected expense
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO expenses (
                employee_id,
                expense_info,
                status,
                approved_at,
                approved_by
            )
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP, %s);
        """, (
            users["employee2"],
            Jsonb({
                "description": "Personal entertainment",
                "category": "OTHER",
                "amount": 120.00,
                "currency": "USD",
                "merchant": "Entertainment Center",
                "receipt": "receipt-004.pdf"
            }),
            "REJECTED",
            users["manager1"]
        ))

        # ----------------------------------------------------
        # Employee 3 - Submitted expense
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO expenses (
                employee_id,
                expense_info,
                status
            )
            VALUES (%s, %s, %s);
        """, (
            users["employee3"],
            Jsonb({
                "description": "Mileage reimbursement",
                "category": "TRANSPORTATION",
                "amount": 86.40,
                "currency": "USD",
                "miles": 144,
                "receipt": None
            }),
            "SUBMITTED"
        ))

    conn.commit()

    print("Expenses seeded successfully.")


# ============================================================
# Display Seeded Data
# ============================================================

def display_data(conn):

    print("\nUsers:")
    print("-" * 80)

    with conn.cursor() as cur:

        cur.execute("""
            SELECT
                user_id,
                email,
                role,
                manager_id
            FROM users
            ORDER BY user_id;
        """)

        for row in cur.fetchall():
            print(row)

        print("\nExpenses:")
        print("-" * 80)

        cur.execute("""
            SELECT
                expense_id,
                employee_id,
                status,
                expense_info
            FROM expenses
            ORDER BY expense_id;
        """)

        for row in cur.fetchall():
            print(row)


# ============================================================
# Main
# ============================================================

def main():

    print("=" * 60)
    print("Expenses Application Database Seeder")
    print("=" * 60)

    print(f"\nAWS Region: {AWS_REGION}")
    print(f"Database Host: {DB_HOST}")
    print(f"Database Name: {DB_NAME}")
    print(f"Database User: {DB_USER}")

    print("\nWARNING:")
    print("This script will DROP and recreate the users and expenses tables.")
    print("All existing data in those tables will be deleted.")

    confirmation = input(
        '\nType "SEED" to continue: '
    )

    if confirmation != "SEED":
        print("Seeding cancelled.")
        return

    try:

        print("\nGenerating IAM database authentication token...")

        conn = get_connection()

        print("Connected to Aurora PostgreSQL using IAM authentication.")

        recreate_tables(conn)

        users = seed_users(conn)

        seed_expenses(conn, users)

        display_data(conn)

        conn.close()

        print("\n" + "=" * 60)
        print("DATABASE SEEDING COMPLETE")
        print("=" * 60)

    except Exception as e:

        print("\nERROR:")
        print(e)

        raise


if __name__ == "__main__":
    main()