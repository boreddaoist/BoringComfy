#!/bin/bash
set -eo pipefail

echo "Installing ComfyUI nodes..."
cd /app || exit 1

# Create custom_nodes directory if it doesn't exist
mkdir -p custom_nodes
cd custom_nodes || exit 1

# Define essential nodes with their repositories
declare -A NODES=(
    ["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
    ["ComfyUI-Impact-Pack"]="https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
    ["comfyui-reactor-node"]="https://codeberg.org/Gourieff/comfyui-reactor-node.git"
    ["ComfyUI_InstantID"]="https://github.com/cubiq/ComfyUI_InstantID.git"  # Verify URL is correct
)

# Function to clone with retry
clone_with_retry() {
    local repo_url=$1
    local dir_name=$2
    local max_attempts=3
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Cloning attempt $attempt of $max_attempts..."
        if git clone "$repo_url" "$dir_name"; then
            return 0
        fi
        attempt=$((attempt + 1))
        echo "Retrying in 10 seconds..."
        sleep 10
    done
    echo "Error: Failed to clone $repo_url after $max_attempts attempts"
    return 1
}

# Function to install node requirements
install_requirements() {
    local node_dir=$1
    if [ -f "${node_dir}/requirements.txt" ]; then
        echo "Installing requirements for ${node_dir}..."
        if ! pip3 install --no-cache-dir -r "${node_dir}/requirements.txt"; then
            echo "Warning: Failed to install some requirements for ${node_dir}"
            return 1
        fi
    fi
    return 0
}

# Clone and install nodes
for node_name in "${!NODES[@]}"; do
    echo "Installing ${node_name}..."
    if [ -d "$node_name" ]; then
        echo "Updating existing node ${node_name}..."
        cd "$node_name"
        git pull
        cd ..
    else
        if ! clone_with_retry "${NODES[$node_name]}" "$node_name"; then
            exit 1  # Exit on persistent failure
        fi
    fi
    
    install_requirements "$node_name"
done

# Set proper permissions
chmod -R 755 .

echo "ComfyUI nodes installed successfully!"