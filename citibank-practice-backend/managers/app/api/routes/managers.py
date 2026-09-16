from fastapi import APIRouter

router = APIRouter(
    prefix="/manager",
    tags=["Managers"],
)
