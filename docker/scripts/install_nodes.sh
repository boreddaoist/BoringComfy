#!/bin/bash
set -eo pipefail

echo "Installing ComfyUI nodes..."
cd /app

# Create custom_nodes directory if it doesn't exist
mkdir -p custom_nodes
cd custom_nodes

# Define essential nodes only
declare -A NODES=(
    ["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
    ["ComfyUI-Impact-Pack"]="https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
)

# Clone and install nodes
for node_name in "${!NODES[@]}"; do
    echo "Installing $node_name..."
    if [ ! -d "$node_name" ]; then
        git clone "${NODES[$node_name]}" "$node_name"
        if [ -f "$node_name/requirements.txt" ]; then
            echo "Installing requirements for $node_name..."
            pip3 install --no-cache-dir -r "$node_name/requirements.txt"
        fi
    fi
done

echo "Nodes installed successfully!"