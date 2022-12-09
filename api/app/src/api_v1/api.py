from fastapi import APIRouter

from .users import users

router = APIRouter()

router.include_router(users.router, prefix="/users", tags=["Users"])
