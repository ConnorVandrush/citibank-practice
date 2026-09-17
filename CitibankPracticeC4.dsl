workspace "Expenses Web Application" {

    model {

        employee = person "Employee"
        manager = person "Manager"
        financeAdmin = person "Finance Administrator"

                api = softwareSystem "ECS Cluster" {

            loginContainer = container "Login Container" {
                description "Handles authentication and user login"
                technology "Amazon ECS"

                loginPOST = component "Login POST" {
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


            employeeBackend = container "Employee Container" {
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


            managerBackend = container "Manager Container" {
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


            financeBackend = container "Finance Container" {
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

            employee -> api "Uses"
            manager -> api "Uses"
            financeAdmin -> api "Uses"
        }

                    rds = softwareSystem "RDS Database" {
                description "Relational database storing users and expenses"
                url "https://lucid.app/lucidchart/0243e26a-4641-46ce-b239-fe9615d2b6af/edit?viewport_loc=24%2C-8%2C1239%2C739%2C0_0&invitationId=inv_f0c25355-515e-4312-a0b1-5680b544e01b"
            }

            api -> rds "Reads and writes employee and expense data"

            cloudfront = softwareSystem "CloudFront" {
                description "Content Delivery Network for the application"
            }
            s3 = softwareSystem "S3" {
                description "Amazon S3 bucket for hosting the frontend"
            }
            vpc = softwareSystem "VPC" {
                description "Virtual Private Cloud for the application"
                publicGateway = container "Public Gateway" {
                    description "Public gateway for the VPC"
                }
                natGateway = container "NAT Gateway" {
                    description "NAT gateway for the VPC"
                }

                publicSubnet = container "Public Subnet" {
                    description "Public subnet within the VPC"
                    alb = component "Application Load Balancer" {
                        description "Application Load Balancer within the public subnet"
                    }
                }
                privateSubnet = container "Private Subnet" {
                    description "Private subnet within the VPC"
                    ecs = component "ECS Cluster" {
                        description "ECS cluster within the private subnet"
                    }
                    privateRds = component "RDS Database" {
                        description "RDS database within the private subnet"
                    }
                    ecs -> privateRds "Communicates with"
                }
                privateSubnet -> natGateway "Internet access for private subnet"
                publicGateway -> publicSubnet "Routes traffic to the public subnet"
                publicSubnet -> privateSubnet "ALB routes traffic to the private subnet"
            }
            employee -> cloudfront "Uses"
            manager -> cloudfront "Uses"
            financeAdmin -> cloudfront "Uses"
            cloudfront -> s3 "Serves frontend content from"
            cloudfront -> vpc "Delivers content through the VPC"
    }

        views {

        systemLandscape "API" {
            include employee
            include manager
            include financeAdmin
            include api
            include rds

            autolayout lr
        }
        container api "Endpoints" {
            include *

            autolayout lr
        }
        component loginContainer "LoginEndpoints" {
            include *

            autolayout lr
        }
        component employeeBackend "EmployeeEndpoints" {
            include *

            autolayout lr
        }
        component managerBackend "ManagerEndpoints" {
            include *

            autolayout lr
        }
        component financeBackend "FinanceEndpoints" {
            include *

            autolayout lr
        }

        systemLandscape "AWSInfrastructure" {
                        include employee
            include manager
            include financeAdmin
            include cloudfront
            include s3
            include vpc

            autolayout lr
        }

            container vpc "VPCComponents" {
        include *
        autolayout lr
    }
    component publicSubnet "PublicSubnetComponents" {
        include *
        autolayout lr
    }
    component privateSubnet "PrivateSubnetComponents" {
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