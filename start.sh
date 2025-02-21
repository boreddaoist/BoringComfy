#!/bin/bash
# Start ComfyUI
python3 main.py --listen --port 8188 &

# Start Jupyter
jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser &

# Start terminal
ttyd -p 7681 bash &

wait