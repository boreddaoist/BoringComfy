#!/bin/bash
set -eo pipefail

# Function to check CUDA availability
check_cuda() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo "WARNING: NVIDIA GPU not detected!"
        return 1
    fi
    return 0
}

# Function for cleanup
cleanup() {
    echo "Performing cleanup..."
    supervisorctl stop all
    sleep 2
}

# Set trap for cleanup
trap cleanup EXIT

# Check CUDA
check_cuda

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

# Create log directory if it doesn't exist
mkdir -p /var/log/supervisor

# Display access information
echo "========================================"
echo "Service Access Information:"
echo "ComfyUI: http://localhost:8188"
echo "Jupyter: http://localhost:8888/?token=${JUPYTER_TOKEN}"
echo "Terminal: http://localhost:7681"
echo "========================================"

# Start supervisor
exec "$@"