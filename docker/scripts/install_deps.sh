#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

# Remove CUDA check during build
# check_cuda() {
#     if ! nvidia-smi &> /dev/null; then
#         echo "WARNING: NVIDIA GPU not detected!"
#         return 1
#     fi
#     return 0
# }

# Version pinning for better reproducibility
TORCH_VERSION="2.1.0"
CUDA_VERSION="cu121"

# Verify working directory
if [ ! -d "/app" ]; then
    echo "ERROR: /app directory not found!"
    exit 1
fi

cd /app

echo "Installing PyTorch dependencies..."
pip3 install --no-cache-dir \
    torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCH_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCH_VERSION}+${CUDA_VERSION} \
    --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# Install base requirements
echo "Installing base requirements..."
pip3 install --no-cache-dir numpy opencv-python pillow

# Install ComfyUI requirements
echo "Installing ComfyUI requirements..."
if [ ! -f "requirements.txt" ]; then
    echo "ERROR: requirements.txt not found in /app"
    exit 1
fi

pip3 install --no-cache-dir -r requirements.txt

echo "Dependencies installed successfully!"