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

# Function to verify service ports
check_ports() {
    local ports=(8188 8888 7681)
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
    supervisorctl stop all
    sleep 2
    echo "Cleanup complete"
}

# Function to verify directories
check_directories() {
    local dirs=("/app" "/root/config" "/var/log/supervisor")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "ERROR: Required directory $dir not found!"
            return 1
        fi
    done
    return 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check CUDA
echo "Checking CUDA availability..."
check_cuda

# Check required directories
echo "Checking required directories..."
check_directories || exit 1

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

# Create log directory if it doesn't exist
mkdir -p /var/log/supervisor

# Display access information
echo "========================================"
echo "Service Access Information:"
echo "ComfyUI: http://localhost:8188"
echo "Jupyter: http://localhost:8888/?token=${JUPYTER_TOKEN}"
echo "Terminal: http://localhost:7681"
echo "========================================"

# Start supervisor with logging
echo "Starting services..."
exec "$@"