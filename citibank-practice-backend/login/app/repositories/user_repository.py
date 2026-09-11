from typing import Optional

from app.database.connection import get_connection


def get_user_by_email(email: str) -> Optional[dict]:
    """
    Retrieve a user from the database by email address.

    Returns:
        A dictionary containing user information if found.
        None if no user exists with that email.
    """

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    user_id,
                    email,
                    password_hash,
                    role,
                    manager_id
                FROM users
                WHERE email = %s;
                """,
                (email,),
            )

            row = cursor.fetchone()

            if row is None:
                return None

            return {
                "user_id": row[0],
                "email": row[1],
                "password_hash": row[2],
                "role": row[3],
                "manager_id": row[4],
            }

    finally:
        connection.close()
