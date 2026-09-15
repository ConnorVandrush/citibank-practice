from fastapi import FastAPI

from app.api.routes.employees import router as employees_router


app = FastAPI(
    title="Expenses Employee Service",
    version="1.0.0",
)


app.include_router(employees_router)


@app.get("/health")
def health_check():
    return {"status": "healthy"}