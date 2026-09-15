from app.database.connection import get_connection


def get_employee_by_id(employee_id: int):
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT user_id, email, manager_id
                FROM users
                WHERE user_id = %s
                  AND role = 'EMPLOYEE'
                """,
                (employee_id,),
            )

            employee = cursor.fetchone()

            if employee is None:
                return None

            user_id, email, manager_id = employee

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


def create_expense_for_employee(
    employee_id: int,
    expense_info: dict,
):
    """
    Insert a new expense for an employee.
    """
    connection = get_connection()

    try:
        with connection.cursor() as cursor:

            # Make sure the employee exists.
            cursor.execute(
                """
                SELECT user_id
                FROM users
                WHERE user_id = %s
                  AND role = 'EMPLOYEE'
                """,
                (employee_id,),
            )

            employee = cursor.fetchone()

            if employee is None:
                return None

            cursor.execute(
                """
                INSERT INTO expenses (
                    employee_id,
                    expense_info,
                    status
                )
                VALUES (
                    %s,
                    %s,
                    'SUBMITTED'
                )
                RETURNING
                    expense_id,
                    employee_id,
                    expense_info,
                    status,
                    submitted_at;
                """,
                (
                    employee_id,
                    expense_info,
                ),
            )

            expense = cursor.fetchone()

        connection.commit()

        return {
            "expense_id": expense[0],
            "employee_id": expense[1],
            "expense_info": expense[2],
            "status": expense[3],
            "submitted_at": expense[4],
        }

    finally:
        connection.close()
