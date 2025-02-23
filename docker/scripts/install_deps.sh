#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

cd /app || exit 1

echo "Installing base Python packages..."
python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

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

# Create required directories
mkdir -p /app/output /app/models
chmod 777 /app/output /app/models

echo "Dependencies installed successfully!"