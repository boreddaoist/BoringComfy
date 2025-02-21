# .github\workflows\docker-build.yml

```yml
name: Build and Push to GHCR

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

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
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            ghcr.io/boreddaoist/boringcomfy:latest
            ghcr.io/boreddaoist/boringcomfy:${{ github.sha }}
          labels: |
            org.opencontainers.image.source=https://github.com/boreddaoist/BoringComfy
          build-args: |
            CIVITAI_TOKEN=${{ secrets.CIVITAI_TOKEN }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
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

# docker\scripts\install_deps.sh

```sh
# Python dependencies
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Cleanup
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
find /usr -name __pycache__ -exec rm -r {} +
```

# docker\scripts\install_models.sh

```sh
#!/bin/bash

# InsightFace - Corrected path
mkdir -p models/insightface/models/buffalo_l
wget -O models/insightface/models/buffalo_l/1k3d68.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_1k3d68.onnx
wget -O models/insightface/models/buffalo_l/2d106det.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_2d106det.onnx

# Add error handling at the end
if [ ! -f models/insightface/models/buffalo_l/1k3d68.onnx ]; then
    echo "Error: InsightFace model download failed!"
    exit 1
fi
```

# docker\scripts\install_nodes.sh

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

# Dockerfile

```
FROM ubuntu:22.04

# Base system with layer optimization
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates google-perftools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory structure
RUN mkdir -p /root/config /app /tmp/scripts

# Copy configurations
COPY docker/config/ /root/config/

# Install core
RUN git clone https://github.com/comfyanonymous/ComfyUI /app
WORKDIR /app

# Copy installation scripts
COPY docker/scripts/ /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh

# In the combined installation layer:
    RUN /tmp/scripts/install_deps.sh && \
    /tmp/scripts/install_nodes.sh && \
    /tmp/scripts/install_models.sh && \
    mkdir -p /app/models && \
    mv models/* /app/models/ && \  # Changed this line
    rm -rf /tmp/scripts/ && \
    find /usr -depth -name '__pycache__' -exec rm -rf {} + && \
    python3 -m pip cache purge

# Environment setup
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4

# Install services
RUN python3 -m pip install --no-cache-dir jupyterlab ttyd

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188 8888 7681

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
```

# README.md

```md
# BoringComfy
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
wait -n  # Properly handle process exits
```

