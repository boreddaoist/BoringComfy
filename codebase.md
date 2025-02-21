# .github\workflows\docker-build.yml

```yml
name: Build and Push to GHCR

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4
      
      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/boreddaoist/boringcomfy:latest
          labels: |
            org.opencontainers.image.source=https://github.com/boreddaoist/BoringComfy
          build-args: |
            CIVITAI_TOKEN=${{ secrets.CIVITAI_TOKEN }}
```

# docker\config\jupyter_server_config.py

```py
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
```

# Dockerfile.txt

```txt
FROM ubuntu:22.04

+ ARG CIVITAI_TOKEN
+
# Base system
RUN apt-get update && apt-get install -y \
    wget git python3 python3-pip python3-venv \
    libgl1 libglib2.0-0 tini tmux

# Copy configurations
COPY docker/config/ /root/config/

# Install core
RUN git clone https://github.com/comfyanonymous/ComfyUI /app
WORKDIR /app

# Copy installation scripts
COPY docker/scripts/ /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh

# Run installations
RUN /tmp/scripts/install_deps.sh
RUN /tmp/scripts/install_nodes.sh
RUN /tmp/scripts/install_models.sh

# Services setup
RUN pip install jupyterlab ttyd
COPY start.sh /start.sh
RUN chmod +x /start.sh
# Add these under existing RUN instructions
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4
RUN apt-get install -y google-perftools
EXPOSE 8188 8888 7681

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
```

# README.md

```md
# BoringComfy
```

# scripts\install_deps.sh

```sh
#!/bin/bash

# System dependencies
apt-get install -y libgl1-mesa-glx libgomp1

# Python dependencies
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt
pip install insightface segment-anything-py==1.0 groundingdino-py==0.4.0 onnxruntime==1.16.0 controlnet-aux==0.0.6
```

# scripts\install_models.sh

```sh
#!/bin/bash

# Fooocus Inpaint
mkdir -p models/inpaint
wget -O models/inpaint/inpaint_v26.fooocus.patch \
    https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch
wget -O models/inpaint/fooocus_inpaint_head.pth \
    https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth

# InsightFace
mkdir -p /root/.insightface/models/buffalo_l
wget -O /root/.insightface/models/buffalo_l/1k3d68.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_1k3d68.onnx
wget -O /root/.insightface/models/buffalo_l/2d106det.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_2d106det.onnx

# Workflow-specific models
mkdir -p models/checkpoints && \
wget -O models/checkpoints/dreamshaperXL_v21TurboDPMSDE.safetensors \
    https://civitai.com/api/download/models/351306

mkdir -p models/loras && \
wget -O models/loras/HandFineTuning_XL.safetensors \
    https://huggingface.co/yesyeahvh/HandFineTuning_XL/resolve/main/HandFineTuning_XL.safetensors

mkdir -p models/controlnet && \
wget -O models/controlnet/ControlNetModel/diffusion_pytorch_model.safetensors \
    https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors
```

# scripts\install_nodes.sh

```sh
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
```

# start.sh

```sh
#!/bin/bash

# Start ComfyUI
python3 /app/main.py --listen --port 8188 &

# Start Jupyter Lab
jupyter lab --config=/root/config/jupyter_server_config.py &

# Start Web Terminal
ttyd -p 7681 bash &

# Keep container alive
tail -f /dev/null
```

