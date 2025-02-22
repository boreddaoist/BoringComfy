#!/bin/bash

# Start ComfyUI with proper logging
python3 /app/main.py --listen --port 8188 > /var/log/comfyui.log 2>&1 &

# Start Jupyter Lab with config
jupyter lab --config=/root/config/jupyter_server_config.py > /var/log/jupyter.log 2>&1 &

# Start Web Terminal (optional)
ttyd -p 7681 bash > /var/log/ttyd.log 2>&1 &

# Keep container alive with process monitoring
while sleep 60; do
  ps aux | grep -q "[p]ython3 /app/main.py" || { echo "ComfyUI died"; exit 1; }
  ps aux | grep -q "[j]upyter lab" || { echo "Jupyter died"; exit 1; }
done