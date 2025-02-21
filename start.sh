#!/bin/bash

# Start ComfyUI
python3 /app/main.py --listen --port 8188 &

# Start Jupyter Lab
jupyter lab --config=/root/config/jupyter_server_config.py &

# Start Web Terminal
ttyd -p 7681 bash &

# Keep container alive
wait -n  # Properly handle process exits