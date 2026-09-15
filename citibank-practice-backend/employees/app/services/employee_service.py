from app.repositories.employee_repository import (
    get_employee_by_id,
    create_expense_for_employee,
)


class EmployeeNotFoundError(Exception):
    pass


class UnauthorizedEmployeeAccessError(Exception):
    pass


def get_employee(
    employee_id: int,
    authenticated_user_id: int,
):
    if employee_id != authenticated_user_id:
        raise UnauthorizedEmployeeAccessError(
            "Employees can only access their own information."
        )

    employee = get_employee_by_id(employee_id)

    if employee is None:
        raise EmployeeNotFoundError(f"Employee {employee_id} not found.")

    return employee


def create_expense(
    employee_id: int,
    authenticated_user_id: int,
    expense_info,
):
    if employee_id != authenticated_user_id:
        raise UnauthorizedEmployeeAccessError(
            "Employees can only submit expenses for themselves."
        )

    expense = create_expense_for_employee(
        employee_id=employee_id,
        expense_info=expense_info.model_dump(mode="json"),
    )

    if expense is None:
        raise EmployeeNotFoundError(f"Employee {employee_id} not found.")

    return expense
