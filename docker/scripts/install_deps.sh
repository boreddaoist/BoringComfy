#!/bin/bash
set -eo pipefail

# Version pinning for better reproducibility
TORCH_VERSION="2.1.0"
CUDA_VERSION="cu121"

echo "Installing PyTorch dependencies..."
pip3 install torch==${TORCH_VERSION}+${CUDA_VERSION} \
    torchvision==${TORCH_VERSION}+${CUDA_VERSION} \
    torchaudio==${TORCH_VERSION}+${CUDA_VERSION} \
    --extra-index-url https://download.pytorch.org/whl/${CUDA_VERSION}

echo "Installing ComfyUI requirements..."
if ! pip3 install -r requirements.txt; then
    echo "Error installing ComfyUI requirements"
    exit 1
fi

echo "Cleaning up Python cache..."
find /usr -name __pycache__ -exec rm -r {} +
python3 -m pip cache purge