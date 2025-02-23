#!/bin/bash
set -eo pipefail

echo "Starting dependency installation..."

cd /app || exit 1

echo "Installing base Python packages..."
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip install --no-cache-dir wheel setuptools

echo "Installing PyTorch..."
python3 -m pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo "Installing base requirements..."
python3 -m pip install --no-cache-dir numpy opencv-python pillow

if [ -f "requirements.txt" ]; then
    echo "Installing requirements from requirements.txt..."
    while IFS= read -r requirement || [[ -n "$requirement" ]]; do
        if [[ ! -z "$requirement" && ! "$requirement" =~ ^# ]]; then
            echo "Installing $requirement..."
            python3 -m pip install --no-cache-dir "$requirement" || echo "Warning: Failed to install $requirement"
        fi
    done < requirements.txt
else
    echo "requirements.txt not found, installing minimal requirements..."
    python3 -m pip install --no-cache-dir transformers safetensors insightface onnxruntime-gpu
fi

echo "Dependencies installed successfully!"