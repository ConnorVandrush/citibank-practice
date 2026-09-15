from datetime import date, datetime

from pydantic import BaseModel


class ExpenseInfo(BaseModel):
    amount: float
    merchant: str
    description: str
    date: date
    category: str


class ExpenseResponse(BaseModel):
    expenseID: int
    expenseInfo: ExpenseInfo
    status: str
    submittedAt: datetime
    approvedAt: datetime | None = None
    approvedBy: int | None = None


class EmployeeResponse(BaseModel):
    employeeID: int
    email: str
    managerID: int | None = None
    expenses: list[ExpenseResponse]


class ExpenseRequest(BaseModel):
    expenseInfo: ExpenseInfo


class ExpenseCreatedResponse(BaseModel):
    expenseID: int
    employeeID: int
    expenseInfo: ExpenseInfo
    status: str
    submittedAt: datetime