import json
import logging
import time

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

logger = logging.getLogger(__name__)

app = FastAPI(title="Continuous Learning Service", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

clients = set()


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "continuous_learning",
        "timestamp": time.time(),
        "connected_clients": len(clients),
    }


async def handle_socket(websocket: WebSocket):
    await websocket.accept()
    clients.add(websocket)

    await websocket.send_text(
        json.dumps(
            {
                "type": "connected",
                "service": "continuous_learning",
                "timestamp": time.time(),
            }
        )
    )

    try:
        while True:
            raw_message = await websocket.receive_text()

            try:
                payload = json.loads(raw_message)
            except json.JSONDecodeError:
                await websocket.send_text(
                    json.dumps(
                        {
                            "type": "error",
                            "message": "Invalid JSON payload",
                            "timestamp": time.time(),
                        }
                    )
                )
                continue

            message_type = payload.get("type", "unknown")
            response_type = "ack"

            if message_type == "subscribe":
                response_type = "subscribed"
            elif message_type in {"simulation_data", "move_made", "game_ended", "priority_learning"}:
                response_type = "queued"

            await websocket.send_text(
                json.dumps(
                    {
                        "type": response_type,
                        "receivedType": message_type,
                        "timestamp": time.time(),
                    }
                )
            )
    except WebSocketDisconnect:
        logger.info("Continuous learning websocket client disconnected")
    finally:
        clients.discard(websocket)


@app.websocket("/")
async def websocket_root(websocket: WebSocket):
    await handle_socket(websocket)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await handle_socket(websocket)
