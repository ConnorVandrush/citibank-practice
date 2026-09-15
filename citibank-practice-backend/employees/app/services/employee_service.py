from app.repositories.employee_repository import get_employee_by_id


class EmployeeNotFoundError(Exception):
    pass


class UnauthorizedEmployeeAccessError(Exception):
    pass


def get_employee(employee_id: int, authenticated_user_id: int):
    """
    Get an employee and their expenses.

    Employees are only allowed to access their own information.
    """

    # Make sure the employee can only access their own record
    if employee_id != authenticated_user_id:
        raise UnauthorizedEmployeeAccessError(
            "Employees can only access their own information."
        )

    employee = get_employee_by_id(employee_id)

    if employee is None:
        raise EmployeeNotFoundError(
            f"Employee {employee_id} not found."
        )

    return employee