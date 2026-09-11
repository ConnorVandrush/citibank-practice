from fastapi import FastAPI

from app.api.routes.auth import router as auth_router

app = FastAPI(
    title="Expenses Login Service",
    version="1.0.0",
)

app.include_router(auth_router)


@app.get("/health")
def health_check():
    return {"status": "healthy"}