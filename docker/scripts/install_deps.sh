#!/bin/bash
set -eo pipefail

echo "Starting dependency verification..."

cd /app || exit 1

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

echo "Dependencies verified successfully!"