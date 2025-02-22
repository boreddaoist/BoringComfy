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
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip3 install -r requirements.txt

# Cleanup should ONLY target Python caches
find /usr -name __pycache__ -exec rm -r {} +
python3 -m pip cache purge
```

# docker\scripts\install_models.sh

```sh
#!/bin/bash
set -e
set -x

# InsightFace models (updated to Hugging Face URLs)
mkdir -p models/insightface/models/buffalo_l
wget --tries=3 --retry-connrefused -O models/insightface/models/buffalo_l/1k3d68.onnx \
    https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/1k3d68.onnx

wget --tries=3 --retry-connrefused -O models/insightface/models/buffalo_l/2d106det.onnx \
    https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/2d106det.onnx

# Verify downloads
if [ ! -f models/insightface/models/buffalo_l/1k3d68.onnx ]; then
    echo "Error: InsightFace model download failed!"
    exit 1
fi
```

# docker\scripts\install_nodes.sh

```sh
#!/bin/bash
set -e  # Exit on error
set -x  # Print commands

# Main nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
git clone https://codeberg.org/Gourieff/comfyui-reactor-node.git custom_nodes/comfyui-reactor-node
git clone https://github.com/cubiq/ComfyUI_InstantID.git custom_nodes/ComfyUI_InstantID
git clone https://github.com/Acly/comfyui-inpaint-nodes.git custom_nodes/comfyui-inpaint-nodes

# Workflow-specific nodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes
git clone https://github.com/cubiq/ComfyUI_essentials.git custom_nodes/ComfyUI_essentials
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git custom_nodes/ComfyUI-Impact-Pack
git clone https://github.com/storyicon/comfyui_segment_anything.git custom_nodes/comfyui_segment_anything
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux

# Install requirements using pip3
find custom_nodes/ -name "requirements.txt" -exec pip3 install -r {} \;
```

# Dockerfile

```
FROM ubuntu:22.04

# Base system with layer optimization
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates libtcmalloc-minimal4 \
    build-essential python3-dev && \
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

# Combined installation layer with cleanup
RUN /tmp/scripts/install_deps.sh && \
    /tmp/scripts/install_nodes.sh && \
    /tmp/scripts/install_models.sh && \
    rm -rf /tmp/scripts/ && \
    find /usr -depth -name '__pycache__' -exec rm -rf {} + && \
    python3 -m pip cache purge

# Environment setup
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ttyd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir jupyterlab

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188 8888 7681

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
# Add to your Dockerfile
ENV JUPYTER_TOKEN="your_secure_token_here"
ENV JUPYTER_PASSWORD="your_secure_password_here"

# Update jupyter_server_config.py
RUN echo "c.ServerApp.token = '$JUPYTER_TOKEN'" >> /root/config/jupyter_server_config.py && \
    echo "c.ServerApp.password = '$JUPYTER_PASSWORD'" >> /root/config/jupyter_server_config.py
```

# README.md

```md
# BoringComfy
```

# start.sh

```sh
#!/bin/bash

# Generate credentials if not provided
if [ -z "$JUPYTER_TOKEN" ] || [ -z "$JUPYTER_PASSWORD" ]; then
  echo "Generating new Jupyter credentials..."
  JUPYTER_TOKEN=$(openssl rand -hex 32)
  JUPYTER_PASSWORD=$(python3 -c "from jupyter_server.auth.security import passwd; print(passwd())")
fi

# Configure Jupyter
cat > /root/config/jupyter_server_config.py << EOL
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = '$JUPYTER_TOKEN'
c.ServerApp.password = '$JUPYTER_PASSWORD'
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
EOL

# Start services with logging
python3 /app/main.py --listen --port 8188 > /var/log/comfyui.log 2>&1 &
jupyter lab --config=/root/config/jupyter_server_config.py > /var/log/jupyter.log 2>&1 &
ttyd -p 7681 bash > /var/log/ttyd.log 2>&1 &

# Display credentials
echo "========================================"
echo "Jupyter Lab Access:"
echo "URL: http://localhost:8888/?token=${JUPYTER_TOKEN}"
echo "========================================"

# Keep container alive (zombie-proof method)
while true; do
  sleep 86400  # 24-hour sleep to reduce CPU usage
done
```

