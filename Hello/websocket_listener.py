import asyncio
import websockets

async def listen():
    url = "wss://websocket.myfox.io/events/websocket?token=YzEzNjUzZjkxODU3MTE1ODI5ZThjOTliYzA4MzRmODY1NDAyZWZiMjhhZTY0YjgwMWI2ZWM1YTFlM2FmOWMwMA"
    while True:
        try:
            async with websockets.connect(url) as ws:
                print("🔌 Connecté au WebSocket")
                async for message in ws:
                    print(f"📩 Message reçu : {message}")
        except Exception as e:
            print(f"⚠️ Erreur WebSocket : {e}, reconnexion dans 5...")
            await asyncio.sleep(5)

asyncio.run(listen())
