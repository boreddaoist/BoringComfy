#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

# Check CUDA availability
check_cuda() {
    if ! nvidia-smi &> /dev/null; then
        echo "WARNING: NVIDIA GPU not detected!"
        return 1
    fi
    nvidia-smi --query-gpu=name,driver_version,compute_mode --format=csv,noheader
    return 0
}

# Version pinning for better reproducibility
TORCH_VERSION="2.1.0"
CUDA_VERSION="cu121"

# Verify working directory
if [ ! -d "/app" ]; then
    echo "ERROR: /app directory not found!"
    exit 1
fi

cd /app

# Check CUDA
echo "Checking CUDA installation..."
check_cuda

echo "Installing PyTorch dependencies..."
if ! pip3 install --no-cache-dir \
    torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCH_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCH_VERSION}+${CUDA_VERSION} \
    --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}; then
    echo "ERROR: PyTorch installation failed!"
    exit 1
fi

# Install base requirements
echo "Installing base requirements..."
if ! pip3 install --no-cache-dir numpy opencv-python pillow; then
    echo "ERROR: Base requirements installation failed!"
    exit 1
fi

# Install ComfyUI requirements
echo "Installing ComfyUI requirements..."
if [ ! -f "requirements.txt" ]; then
    echo "ERROR: requirements.txt not found in /app"
    exit 1
fi

if ! pip3 install --no-cache-dir -r requirements.txt; then
    echo "ERROR: ComfyUI requirements installation failed!"
    exit 1
fi

# Verify torch installation
echo "Verifying PyTorch installation..."
if ! python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"; then
    echo "WARNING: PyTorch CUDA verification failed!"
fi

echo "Dependencies installed successfully!"