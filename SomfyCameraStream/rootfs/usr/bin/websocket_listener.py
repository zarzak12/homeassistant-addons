import asyncio
import websockets
import json
import os
import sys
import logging

# 🔧 Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] %(levelname)s: %(message)s",
    datefmt="%H:%M:%S",  # Format HH:MM:SS
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

# 🔌 URL du WebSocket (injectée par le script shell)
WS_URL = os.getenv("WS_URL")
if not WS_URL:
    logging.error("❌ WS_URL n'est pas défini. Vérifiez votre configuration.")
    sys.exit(1)

async def connect_websocket():
    """Connexion au WebSocket et gestion des messages."""
    while True:
        try:
            logging.info("🔌 Connexion au WebSocket...")
            async with websockets.connect(WS_URL) as websocket:
                logging.info("✅ Connexion WebSocket établie !")

                async for message in websocket:
                    try:
                        data = json.loads(message)
                        logging.info(f"📩 Message reçu : {data}")

                        # 🎯 Vérifier si le message contient une URL stream_url
                        if "stream_url" in data:
                            rtmps_url = data["stream_url"]
                            logging.info(f"🎥 URL RTMPS détectée : {rtmps_url}")

                            # 💾 Sauvegarder l'URL pour que run.sh puisse l'utiliser
                            with open("/tmp/rtmps_url", "w") as f:
                                f.write(rtmps_url)
                            break  # 🔄 Arrêter la boucle une fois l'URL récupérée
                    except json.JSONDecodeError:
                        logging.warning("⚠️ Impossible de décoder le message JSON reçu.")

        except websockets.exceptions.ConnectionClosed:
            logging.warning("🔄 WebSocket déconnecté, tentative de reconnexion dans 5s...")
            await asyncio.sleep(5)
        except Exception as e:
            logging.error(f"❌ Erreur WebSocket : {e}, tentative de reconnexion dans 5s...")
            await asyncio.sleep(5)

# 🏁 Lancer l'écoute WebSocket en asynchrone
if __name__ == "__main__":
    asyncio.run(connect_websocket())
