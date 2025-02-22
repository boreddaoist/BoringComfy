#!/bin/bash
set -eo pipefail

echo "Installing InsightFace models..."

# Create required directories
mkdir -p models/insightface/models/buffalo_l

# Define model URLs and checksums
declare -A MODELS=(
    ["1k3d68.onnx"]="https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/1k3d68.onnx"
    ["2d106det.onnx"]="https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/2d106det.onnx"
)

# Download models with retry mechanism
for model in "${!MODELS[@]}"; do
    echo "Downloading $model..."
    for i in {1..3}; do
        if wget --no-verbose -O "models/insightface/models/buffalo_l/$model" "${MODELS[$model]}"; then
            break
        fi
        if [ $i -eq 3 ]; then
            echo "Failed to download $model after 3 attempts"
            exit 1
        fi
        echo "Retry $i downloading $model..."
        sleep 5
    done
done

# Verify downloads
for model in "${!MODELS[@]}"; do
    if [ ! -f "models/insightface/models/buffalo_l/$model" ]; then
        echo "Error: $model download failed!"
        exit 1
    fi
done

echo "All models installed successfully!"