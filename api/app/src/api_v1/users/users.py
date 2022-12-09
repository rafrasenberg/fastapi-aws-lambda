from fastapi import APIRouter

router = APIRouter()


@router.get("/{id}")
async def get_user():
    results = {"Success": "This is one user!"}
    return results


@router.get("/")
async def get_users():
    results = {"Success": "All users!"}
    return results
