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

# Verify CUDA installation
echo "Verifying CUDA installation..."
python3 -c 'import torch; print(f"CUDA Available: {torch.cuda.is_available()}"); print(f"CUDA Version: {torch.version.cuda}"); print(f"PyTorch Version: {torch.__version__}")'

echo "Installing ComfyUI core dependencies..."
python3 -m pip install --no-cache-dir \
    numpy \
    opencv-python \
    pillow \
    transformers \
    safetensors \
    accelerate \
    insightface \
    onnxruntime-gpu \
    xformers==0.0.23 \
    aiohttp \
    einops \
    scipy \
    tqdm \
    psutil \
    requests \
    pyyaml \
    hjson \
    websockets

# Verify installations
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