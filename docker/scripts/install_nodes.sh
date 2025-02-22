#!/bin/bash
set -eo pipefail

echo "Installing ComfyUI nodes..."

# Main nodes with version pinning
declare -A NODES=(
    ["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
    ["comfyui-reactor-node"]="https://codeberg.org/Gourieff/comfyui-reactor-node.git"
    ["ComfyUI_InstantID"]="https://github.com/cubiq/ComfyUI_InstantID.git"
    ["comfyui-inpaint-nodes"]="https://github.com/Acly/comfyui-inpaint-nodes.git"
    ["ComfyUI-KJNodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
    ["ComfyUI_essentials"]="https://github.com/cubiq/ComfyUI_essentials.git"
    ["ComfyUI-Impact-Pack"]="https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
    ["comfyui_segment_anything"]="https://github.com/storyicon/comfyui_segment_anything.git"
    ["comfyui_controlnet_aux"]="https://github.com/Fannovel16/comfyui_controlnet_aux.git"
)

# Create custom_nodes directory if it doesn't exist
mkdir -p custom_nodes

# Clone and install nodes
for node_name in "${!NODES[@]}"; do
    echo "Installing $node_name..."
    if [ ! -d "custom_nodes/$node_name" ]; then
        git clone "${NODES[$node_name]}" "custom_nodes/$node_name"
    fi
    
    if [ -f "custom_nodes/$node_name/requirements.txt" ]; then
        echo "Installing requirements for $node_name..."
        pip3 install -r "custom_nodes/$node_name/requirements.txt"
    fi
done

echo "All nodes installed successfully!"