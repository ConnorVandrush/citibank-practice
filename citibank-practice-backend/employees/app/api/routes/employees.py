from fastapi import APIRouter, Depends, HTTPException, status
from app.auth.jwt import get_current_user
from app.schemas.employee import (
    EmployeeResponse,
    ExpenseRequest,
    ExpenseCreatedResponse,
)
from app.services.employee_service import (
    get_employee,
    create_expense,
    EmployeeNotFoundError,
    UnauthorizedEmployeeAccessError,
)

router = APIRouter(
    prefix="/employees",
    tags=["Employees"],
)


@router.get(
    "/{employee_id}",
    response_model=EmployeeResponse,
)
def get_employee_endpoint(
    employee_id: int,
    current_user: dict = Depends(get_current_user),
):
    """
    Get an employee and their expenses.
    """
    try:
        employee = get_employee(
            employee_id=employee_id,
            authenticated_user_id=current_user["user_id"],
        )

        return {
            "employeeID": employee["user_id"],
            "email": employee["email"],
            "managerID": employee["manager_id"],
            "expenses": [
                {
                    "expenseID": expense["expense_id"],
                    "expenseInfo": expense["expense_info"],
                    "status": expense["status"],
                    "submittedAt": expense["submitted_at"],
                    "approvedAt": expense["approved_at"],
                    "approvedBy": expense["approved_by"],
                }
                for expense in employee["expenses"]
            ],
        }

    except UnauthorizedEmployeeAccessError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to access this employee.",
        )

    except EmployeeNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found.",
        )


@router.post(
    "/{employee_id}",
    response_model=ExpenseCreatedResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_expense_endpoint(
    employee_id: int,
    request: ExpenseRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Submit a new expense for the authenticated employee.
    """
    try:
        expense = create_expense(
            employee_id=employee_id,
            authenticated_user_id=current_user["user_id"],
            expense_info=request.expenseInfo,
        )

        return {
            "expenseID": expense["expense_id"],
            "employeeID": expense["employee_id"],
            "expenseInfo": expense["expense_info"],
            "status": expense["status"],
            "submittedAt": expense["submitted_at"],
        }

    except UnauthorizedEmployeeAccessError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to submit an expense for this employee.",
        )

    except EmployeeNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found.",
        )
