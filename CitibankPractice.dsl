workspace "Expenses Web Application" {

    model {

        employee = person "Employee"
        manager = person "Manager"
        financeAdmin = person "Finance Administrator"


        frontend = softwareSystem "S3 Bucket Frontend" {
            description "Web frontend hosted in an Amazon S3 bucket"
        }


        ecs = softwareSystem "ECS Backend" {

            loginContainer = container "Login Container" {
                description "Handles authentication and user login"
                technology "Amazon ECS"

                loginPOST = component "Login API" {
                    description "POST /auth/login"
                }

                loginRequest = component "Login Request" {
                    description "{ email: employee@example.com, password: password123 }"
                }

                loginResponse = component "Login Response" {
                    description "{ token: eyJhbGciOiJIUzI1NiIs... }"
                }

                loginPOST -> loginRequest "expects"
                loginPOST -> loginResponse "returns"
            }


            employeeBackend = container "Employee Backend Container" {
                description "Handles employee information and expense submission"
                technology "Amazon ECS"

                getEmployee = component "Get Employee" {
                    description "GET /employees/{employeeID}"
                }

                getEmployeeResponse = component "Get Employee Response" {
                    description "{ employeeID: 123, email: employee@example.com, managerID: 456, expenses: [...] }"
                }

                createExpense = component "Create Expense" {
                    description "POST /employees/{employeeID}/expenses"
                }

                createExpenseRequest = component "Create Expense Request" {
                    description "{ expenseInfo: { amount: 125.50, merchant: Delta Airlines, description: Business flight, date: 2026-09-10, category: Travel } }"
                }

                createExpenseResponse = component "Create Expense Response" {
                    description "{ expenseID: 789, employeeID: 123, status: SUBMITTED, submittedAt: 2026-09-11T14:30:00Z }"
                }

                getEmployee -> getEmployeeResponse "returns"
                createExpense -> createExpenseRequest "expects"
                createExpense -> createExpenseResponse "returns"
            }


            managerBackend = container "Manager Backend Container" {
                description "Handles manager employee and expense management"
                technology "Amazon ECS"

                getManagerEmployees = component "Get Manager Employees" {
                    description "GET /manager/employees"
                }

                getManagerEmployeesResponse = component "Get Manager Employees Response" {
                    description "{ managerID: 456, email: manager@example.com, employees: [...] }"
                }

                getEmployeeExpenses = component "Get Employee Expenses" {
                    description "GET /manager/employees/{employeeID}"
                }

                getEmployeeExpensesResponse = component "Get Employee Expenses Response" {
                    description "{ employeeID: 123, email: employee@example.com, expenses: [...] }"
                }

                getManagerExpense = component "Get Expense" {
                    description "GET /manager/expenses/{expenseID}"
                }

                getManagerExpenseResponse = component "Get Expense Response" {
                    description "{ expenseID: 789, employeeID: 123, status: SUBMITTED, submittedAt: 2026-09-11T14:30:00Z }"
                }

                updateExpense = component "Update Expense Status" {
                    description "PATCH /manager/expenses/{expenseID}"
                }

                updateExpenseRequest = component "Update Expense Request" {
                    description "{ status: APPROVED } or { status: REJECTED, reason: Receipt is missing }"
                }

                updateExpenseResponse = component "Update Expense Response" {
                    description "{ expenseID: 789, status: APPROVED, approvedBy: 456, approvedAt: 2026-09-11T15:00:00Z }"
                }

                getManagerEmployees -> getManagerEmployeesResponse "returns"
                getEmployeeExpenses -> getEmployeeExpensesResponse "returns"
                getManagerExpense -> getManagerExpenseResponse "returns"
                updateExpense -> updateExpenseRequest "expects"
                updateExpense -> updateExpenseResponse "returns"
            }


            financeBackend = container "Finance Administrator Container" {
                description "Provides finance administrators with access to expense records"
                technology "Amazon ECS"

                getExpenses = component "Get Expenses" {
                    description "GET /admin/expenses"
                }

                getExpensesResponse = component "Get Expenses Response" {
                    description "{ expenses: [...] }"
                }

                getExpenses -> getExpensesResponse "returns"
            }
        }


        rds = softwareSystem "RDS Database" {
            description "Relational database storing users and expenses"
            url "https://lucid.app/lucidchart/0243e26a-4641-46ce-b239-fe9615d2b6af/edit?viewport_loc=24%2C-8%2C1239%2C739%2C0_0&invitationId=inv_f0c25355-515e-4312-a0b1-5680b544e01b"
        }


        // Employee interactions

        employee -> frontend "Uses"

        frontend -> loginContainer "POST /auth/login"

        frontend -> employeeBackend "Employee API requests"

        employeeBackend -> rds "Reads and writes employee and expense data"


        // Manager interactions

        manager -> frontend "Uses"

        frontend -> managerBackend "Manager API requests"

        managerBackend -> rds "Reads and updates employee and expense data"


        // Finance administrator interactions

        financeAdmin -> frontend "Uses"

        frontend -> financeBackend "Finance API requests"

        financeBackend -> rds "Reads expense data"


        // Authentication database access

        loginContainer -> rds "Reads user credentials"
    }


    views {

        systemLandscape "SystemLandscape" {
            include employee
            include manager
            include financeAdmin
            include frontend
            include ecs
            include rds

            autolayout lr
        }


        container ecs "ECSContainers" {
            include *

            autolayout lr
        }


        component loginContainer "LoginComponents" {
            include *

            autolayout lr
        }


        component employeeBackend "EmployeeComponents" {
            include *

            autolayout lr
        }


        component managerBackend "ManagerComponents" {
            include *

            autolayout lr
        }


        component financeBackend "FinanceComponents" {
            include *

            autolayout lr
        }


        styles {

            element "Person" {
                shape person
            }

            element "Software System" {
                shape roundedbox
            }

            element "Container" {
                shape roundedbox
            }

            element "Component" {
                shape roundedbox
            }
        }
    }
}