#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

cd /app || exit 1

echo "Installing CUDA dependencies..."
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cuda-toolkit-12-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

echo "Installing base Python packages..."
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip install --no-cache-dir wheel setuptools

# Ensure CUDA environment
export CUDA_HOME=/usr/local/cuda
export PATH=${CUDA_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

echo "Installing PyTorch with CUDA support..."
python3 -m pip install --no-cache-dir \
    torch==2.1.0+cu121 \
    torchvision==0.16.0+cu121 \
    torchaudio==2.1.0+cu121 \
    --index-url https://download.pytorch.org/whl/cu121

echo "Installing ComfyUI core dependencies..."
python3 -m pip install --no-cache-dir \
    numpy \
    opencv-python \
    pillow \
    transformers \
    safetensors \
    accelerate \
    insightface \
    onnxruntime-gpu

# Verify CUDA installation
echo "Verifying CUDA installation..."
if ! python3 -c "import torch; assert torch.cuda.is_available(), 'CUDA not available'; print('CUDA is available')"; then
    echo "ERROR: CUDA verification failed!"
    exit 1
fi

# Create required directories
mkdir -p /app/output /app/models
chmod 777 /app/output /app/models

echo "Dependencies installed successfully!"