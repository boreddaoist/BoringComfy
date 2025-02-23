#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

# Version pinning for better reproducibility
TORCH_VERSION="2.1.0"
CUDA_VERSION="cu121"

# Verify working directory
if [ ! -d "/app" ]; then
    echo "ERROR: /app directory not found!"
    exit 1
fi

cd /app

echo "Installing base requirements..."
pip3 install --no-cache-dir numpy opencv-python pillow

echo "Installing PyTorch dependencies..."
pip3 install --no-cache-dir \
    torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCH_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCH_VERSION}+${CUDA_VERSION} \
    --index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# Install ComfyUI requirements
echo "Installing ComfyUI requirements..."
if [ ! -f "requirements.txt" ]; then
    echo "ERROR: requirements.txt not found in /app"
    exit 1
fi

# Install requirements one by one to prevent conflicts
while IFS= read -r requirement || [[ -n "$requirement" ]]; do
    if [[ ! -z "$requirement" && ! "$requirement" =~ ^# ]]; then
        echo "Installing $requirement..."
        pip3 install --no-cache-dir "$requirement" || echo "Warning: Failed to install $requirement"
    fi
done < requirements.txt

echo "Dependencies installed successfully!"