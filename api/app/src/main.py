import os
from fastapi import FastAPI
from mangum import Mangum
from api_v1.api import router as api_router

api_stage = os.environ.get("API_STAGE", "")

app = FastAPI(
    root_path=f"{api_stage}",
    docs_url="/api/v1/docs",
    title="My Awesome FastAPI app",
    description="This is super fancy, with auto docs and everything!",
    version="0.0.1",
)


@app.get("/ping", name="Healthcheck", tags=["Healthcheck"])
async def healthcheck():
    return {"success": "pong!"}


app.include_router(api_router, prefix="/api/v1")

handler = Mangum(app)
