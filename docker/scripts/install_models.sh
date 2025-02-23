#!/bin/bash
set -eo pipefail

echo "Installing InsightFace models..."
cd /app

# Create required directories
mkdir -p models/insightface/models/buffalo_l

# Define primary model only for initial testing
MODEL_URL="https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/1k3d68.onnx"
MODEL_FILE="models/insightface/models/buffalo_l/1k3d68.onnx"

echo "Downloading model..."
if ! wget --no-verbose -O "$MODEL_FILE" "$MODEL_URL"; then
    echo "Error: Model download failed!"
    exit 1
fi

echo "Model installed successfully!"