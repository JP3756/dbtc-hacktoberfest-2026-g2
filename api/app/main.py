from datetime import datetime, timedelta

from fastapi import Depends, FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import Base, engine, get_db
from app.models import Pump, PumpHistory, PumpMode, SensorData
from app.schemas import PumpHistoryRequest, PumpModeRequest, SensorDataRequest
from .config import settings

app = FastAPI()
active_websocket: WebSocket | None = None

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL],
    allow_credentials=True,
    allow_methods=["GET", "PUT", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)


@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


@app.get("/sensor/")
async def get_sensor(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(SensorData))
    return result.scalars().all()


@app.get("/sensor-data/")
async def get_sensor_data(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(SensorData))
    return result.scalars().all()


@app.get("/pump/")
async def get_pump(
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Pump))
    return result.scalars().all()


@app.get("/pump-mode/")
async def get_pump_mode(
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(PumpMode))
    return result.scalars().all()


@app.put("/pump-mode/")
async def update_pump_mode(
    body: PumpModeRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(PumpMode).where(PumpMode.pump_id == body.pump))
    db_pump_mode = result.scalars().first()

    if db_pump_mode:
        db_pump_mode.mode = body.pump_mode
    else:
        db_pump_mode = PumpMode(pump_id=body.pump, mode=body.pump_mode)
        db.add(db_pump_mode)

    await db.commit()
    await db.refresh(db_pump_mode)

    if active_websocket:
        await active_websocket.send_json(
            {"pump": db_pump_mode.pump_id, "pump_mode": db_pump_mode.mode}
        )
    return db_pump_mode


@app.get("/pump-history/")
async def get_pump_history(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(PumpHistory).order_by(PumpHistory.recorded_at.desc())
    )
    return result.scalars().all()


@app.get("/alerts/")
async def get_alerts(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(SensorData).order_by(SensorData.recorded_at.desc()).limit(1)
    )
    latest = result.scalars().first()
    if latest is None:
        return {
            "alerts": [
                {"message": "No sensor readings yet", "severity": "warning"}
            ]
        }

    alerts = []
    if latest.water_level <= 20:
        alerts.append(
            {"message": "Check water level in reservoir", "severity": "critical"}
        )
    if latest.moisture_level <= 30:
        alerts.append(
            {"message": "Soil moisture is low", "severity": "warning"}
        )
    if datetime.now() - latest.recorded_at > timedelta(minutes=30):
        alerts.append(
            {"message": "Sensor readings are stale", "severity": "warning"}
        )
    return {"alerts": alerts}


@app.get("/usage/today/")
async def get_today_usage(db: AsyncSession = Depends(get_db)):
    start_of_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    result = await db.execute(
        select(func.coalesce(func.sum(PumpHistory.liters), 0.0)).where(
            PumpHistory.recorded_at >= start_of_day,
            PumpHistory.recorded_at < start_of_day + timedelta(days=1),
        )
    )
    return {"liters": float(result.scalar_one())}


# @app.post("/pump-history/")
# async def create_pump_history(
#     body: PumpHistoryRequest,
#     db: AsyncSession = Depends(get_db),
# ):
#     db_pump_history = PumpHistory(
#         liters=body.liters,
#         recorded_at=body.recorded_at or datetime.now(),
#         pump_id=body.pump,
#     )
#     db.add(db_pump_history)
#     await db.commit()
#     await db.refresh(db_pump_history)
#     return db_pump_history


@app.websocket("/mc-ws/")
async def mc_ws(
    websocket: WebSocket,
    db: AsyncSession = Depends(get_db),
):
    global active_websocket
    await websocket.accept()
    active_websocket = websocket
    try:
        while True:
            sensor_data = await websocket.receive_json()
            sensor_data_validated = SensorDataRequest.model_validate_json(sensor_data)
            new_sensor_data = SensorData(
                sensor_id=sensor_data_validated.sensor,
                moisture_level=sensor_data_validated.moisture_level,
                water_level=sensor_data_validated.water_level,
                recorded_at=sensor_data_validated.recorded_at or datetime.now(),
            )
            db.add(new_sensor_data)
            await db.commit()
            await db.refresh(new_sensor_data)
    except WebSocketDisconnect:
        pass
    active_websocket = None
