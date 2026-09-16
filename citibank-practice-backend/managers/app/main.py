from fastapi import FastAPI

from app.api.routes.managers import router as managers_router

app = FastAPI(
    title="Expenses Manager Service",
    version="1.0.0",
)

app.include_router(managers_router)


@app.get("/health")
def health_check():
    return {"status": "healthy"}
