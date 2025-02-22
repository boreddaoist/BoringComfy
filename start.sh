#!/bin/bash

# Generate credentials if not provided
if [ -z "$JUPYTER_TOKEN" ] || [ -z "$JUPYTER_PASSWORD" ]; then
  echo "Generating new Jupyter credentials..."
  JUPYTER_TOKEN=$(openssl rand -hex 32)
  JUPYTER_PASSWORD=$(python3 -c "from jupyter_server.auth.security import passwd; print(passwd())")
fi

# Configure Jupyter
cat > /root/config/jupyter_server_config.py << EOL
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = '$JUPYTER_TOKEN'
c.ServerApp.password = '$JUPYTER_PASSWORD'
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
EOL

# Start services
python3 /app/main.py --listen --port 8188 > /var/log/comfyui.log 2>&1 &
jupyter lab --config=/root/config/jupyter_server_config.py > /var/log/jupyter.log 2>&1 &
ttyd -p 7681 bash > /var/log/ttyd.log 2>&1 &

# Display credentials
echo "========================================"
echo "Jupyter Access: http://localhost:8888/?token=${JUPYTER_TOKEN}"
echo "========================================"

# Zombie-proof keepalive
exec tail -f /dev/null