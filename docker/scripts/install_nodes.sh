#!/bin/bash

# Main nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
git clone https://codeberg.org/Gourieff/comfyui-reactor-node.git custom_nodes/comfyui-reactor-node
git clone https://github.com/cubiq/ComfyUI_InstantID.git custom_nodes/ComfyUI_InstantID
git clone https://github.com/Acly/comfyui-inpaint-nodes.git custom_nodes/comfyui-inpaint-nodes

# Workflow-specific nodes from your correction
git clone https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes
git clone https://github.com/cubiq/ComfyUI_essentials.git custom_nodes/ComfyUI_essentials
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git custom_nodes/ComfyUI-Impact-Pack
git clone https://github.com/storyicon/comfyui_segment_anything.git custom_nodes/comfyui_segment_anything
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux

# Install requirements for all nodes
find custom_nodes/ -name "requirements.txt" -exec pip install -r {} \;