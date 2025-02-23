#!/bin/bash
set -eo pipefail

# Function to check CUDA availability
check_cuda() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo "WARNING: NVIDIA GPU not detected!"
        return 1
    fi
    nvidia-smi --query-gpu=name,driver_version,compute_mode --format=csv,noheader
    return 0
}

# Function to check ComfyUI dependencies
check_comfy_deps() {
    echo "Checking ComfyUI dependencies..."
    cd /app || exit 1
    python3 -c '
import sys
import torch
import numpy
import PIL
import einops
import transformers
import safetensors
print("Python:", sys.version)
print("CUDA available:", torch.cuda.is_available())
print("CUDA version:", torch.version.cuda)
print("PyTorch:", torch.__version__)
print("Dependencies OK")
' 2>/dev/null || {
        echo "ERROR: Missing ComfyUI dependencies!"
        cat /var/log/supervisor/comfyui.err
        return 1
    }
    return 0
}

# Function to verify service ports
check_ports() {
    local ports=(8188 8888 7681 8189 8889 7682)
    for port in "${ports[@]}"; do
        if lsof -i ":$port" >/dev/null 2>&1; then
            echo "ERROR: Port $port is already in use!"
            return 1
        fi
    done
    return 0
}

# Function for cleanup
cleanup() {
    echo "Performing cleanup..."
    if [ ! -z "$TAIL_PID" ]; then
        kill $TAIL_PID 2>/dev/null || true
    fi
    supervisorctl stop all
    sleep 2
    echo "Cleanup complete"
}

# Function to verify directories and permissions
check_directories() {
    local dirs=("/app" "/root/config" "/var/log/supervisor" "/app/output" "/app/models" "/app/custom_nodes")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "Creating directory $dir..."
            mkdir -p "$dir"
            chmod 777 "$dir"
        fi
    done
}

# Function to monitor logs
monitor_logs() {
    mkdir -p /var/log/supervisor
    touch /var/log/supervisor/comfyui.log /var/log/supervisor/comfyui.err
    tail -F /var/log/supervisor/comfyui.log /var/log/supervisor/comfyui.err &
    TAIL_PID=$!
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check CUDA
echo "Checking CUDA availability..."
check_cuda

# Check directories
echo "Verifying directories..."
check_directories

# Check ports
echo "Checking service ports..."
check_ports || exit 1

# Generate credentials if not provided
if [ -z "$JUPYTER_TOKEN" ] || [ -z "$JUPYTER_PASSWORD" ]; then
    echo "Generating new Jupyter credentials..."
    JUPYTER_TOKEN=$(openssl rand -hex 32)
    JUPYTER_PASSWORD=$(python3 -c "from jupyter_server.auth.security import passwd; print(passwd())")
fi

# Configure Jupyter
echo "Configuring Jupyter..."
cat > /root/config/jupyter_server_config.py << EOL
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = '$JUPYTER_TOKEN'
c.ServerApp.password = '$JUPYTER_PASSWORD'
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
c.ServerApp.root_dir = '/app'
EOL

# Create log directory
mkdir -p /var/log/supervisor

# Display access information
echo "========================================"
echo "Service Access Information:"
echo "ComfyUI Web: http://localhost:8188"
echo "ComfyUI API: http://localhost:8189"
echo "Jupyter Lab: http://localhost:8888/?token=${JUPYTER_TOKEN}"
echo "Terminal Web: http://localhost:7681"
echo "Terminal API: http://localhost:7682"
echo "========================================"

# Check ComfyUI dependencies
echo "Checking ComfyUI dependencies..."
check_comfy_deps || exit 1

# Start log monitoring
monitor_logs

# Start supervisor
echo "Starting services..."
exec "$@"