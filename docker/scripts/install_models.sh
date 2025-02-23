#!/bin/bash
set -eo pipefail

echo "Installing InsightFace models..."
cd /app || exit 1

# Create required directories
mkdir -p models/insightface/models/buffalo_l

# Define models with their checksums
declare -A MODELS=(
    ["1k3d68.onnx"]="https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/1k3d68.onnx"
    ["2d106det.onnx"]="https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/2d106det.onnx"
)

# Function to download with retry
download_with_retry() {
    local url=$1
    local output=$2
    local max_attempts=3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Download attempt $attempt of $max_attempts..."
        if wget --no-verbose -O "$output" "$url"; then
            return 0
        fi
        attempt=$((attempt + 1))
        if [ $attempt -le $max_attempts ]; then
            echo "Retrying download in 5 seconds..."
            sleep 5
        fi
    done
    
    echo "Error: Failed to download after $max_attempts attempts"
    return 1
}

# Download models
for model in "${!MODELS[@]}"; do
    echo "Downloading $model..."
    output_path="models/insightface/models/buffalo_l/$model"
    if ! download_with_retry "${MODELS[$model]}" "$output_path"; then
        echo "Error: Failed to download $model"
        exit 1
    fi
    
    if [ ! -f "$output_path" ]; then
        echo "Error: $model download verification failed!"
        exit 1
    fi
    
    echo "$model downloaded successfully"
done

# Set permissions
chmod -R 755 models/
echo "Models installed successfully!"