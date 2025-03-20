import asyncio
import websockets
import json
import os

# 🔌 URL du WebSocket (injectée par le script shell)
WS_URL = os.getenv("WS_URL")

async def connect_websocket():
    """Connexion au WebSocket et gestion des messages."""
    while True:
        try:
            async with websockets.connect(WS_URL) as websocket:
                print("✅ Connexion WebSocket établie !")

                async for message in websocket:
                    data = json.loads(message)
                    print(f"📩 Message reçu : {data}")

                    # 🎯 Vérifier si le message contient une URL RTMPS
                    if "rtmps_url" in data:
                        rtmps_url = data["rtmps_url"]
                        print(f"🎥 URL RTMPS détectée : {rtmps_url}")

                        # 💾 Sauvegarder l'URL pour que run.sh puisse l'utiliser
                        with open("/tmp/rtmps_url", "w") as f:
                            f.write(rtmps_url)
                        break  # 🔄 Arrêter la boucle une fois l'URL récupérée

        except websockets.exceptions.ConnectionClosed:
            print("🔄 WebSocket déconnecté, tentative de reconnexion dans 5s...")
            await asyncio.sleep(5)
        except Exception as e:
            print(f"❌ Erreur WebSocket : {e}, tentative de reconnexion dans 5s...")
            await asyncio.sleep(5)

# 🏁 Lancer l'écoute WebSocket en asynchrone
asyncio.run(connect_websocket())
