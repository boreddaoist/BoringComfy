#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

cd /app || exit 1

# Install Python packages
echo "Installing ComfyUI core dependencies..."
python3 -m pip install --no-cache-dir \
    numpy==1.24.3 \
    opencv-python==4.8.0.76 \
    pillow==10.0.0 \
    transformers==4.31.0 \
    safetensors==0.3.3 \
    accelerate==0.21.0 \
    insightface==0.7.3 \
    onnxruntime-gpu==1.15.1 \
    xformers==0.0.21 \
    aiohttp \
    einops \
    scipy \
    tqdm \
    psutil \
    requests \
    pyyaml \
    hjson \
    websockets

# Verify CUDA and dependencies
echo "Verifying CUDA installation..."
python3 -c '
import torch
print(f"CUDA Available: {torch.cuda.is_available()}")
print(f"CUDA Version: {torch.version.cuda}")
print(f"PyTorch Version: {torch.__version__}")
'

# Verify other installations
echo "Verifying installations..."
for pkg in torch numpy PIL einops transformers safetensors pyyaml hjson websockets; do
    if ! python3 -c "import $pkg" 2>/dev/null; then
        echo "ERROR: Failed to import $pkg"
        exit 1
    fi
done

# Create required directories with proper permissions
mkdir -p /app/output /app/models /app/custom_nodes
chmod -R 777 /app/output /app/models /app/custom_nodes

echo "Dependencies installed successfully!"