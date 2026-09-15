from app.database.connection import get_connection


def get_employee_by_id(employee_id: int):
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            # Get employee information
            cursor.execute(
                """
                SELECT
                    u.user_id,
                    u.email,
                    u.manager_id
                FROM users u
                WHERE u.user_id = %s
                  AND u.role = 'EMPLOYEE'
                """,
                (employee_id,),
            )

            employee = cursor.fetchone()

            if employee is None:
                return None

            user_id, email, manager_id = employee

            # Get the employee's expenses
            cursor.execute(
                """
                SELECT
                    expense_id,
                    expense_info,
                    status,
                    submitted_at,
                    approved_at,
                    approved_by
                FROM expenses
                WHERE employee_id = %s
                ORDER BY submitted_at DESC
                """,
                (employee_id,),
            )

            expenses = cursor.fetchall()

            return {
                "user_id": user_id,
                "email": email,
                "manager_id": manager_id,
                "expenses": [
                    {
                        "expense_id": expense[0],
                        "expense_info": expense[1],
                        "status": expense[2],
                        "submitted_at": expense[3],
                        "approved_at": expense[4],
                        "approved_by": expense[5],
                    }
                    for expense in expenses
                ],
            }

    finally:
        connection.close()