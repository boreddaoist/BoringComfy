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
    ["ComfyUI_InstantID"]="https://github.com/cubiq/ComfyUI_InstantID.git"
)

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
        if ! git clone "${NODES[$node_name]}" "$node_name"; then
            echo "Error: Failed to clone ${node_name}"
            exit 1
        fi
    fi
    
    install_requirements "$node_name"
done

# Set proper permissions
chmod -R 755 .

echo "ComfyUI nodes installed successfully!"