from fastapi import FastAPI

from app.api.routes.finance_admin import router as finance_admin_router

app = FastAPI(
    title="Expenses Finance Administrator Service",
    version="1.0.0",
)

app.include_router(finance_admin_router)


@app.get("/health")
def health_check():
    return {"status": "healthy"}
