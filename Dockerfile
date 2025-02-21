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

# Combined installation layer with cleanup
RUN /tmp/scripts/install_deps.sh && \
    /tmp/scripts/install_nodes.sh && \
    /tmp/scripts/install_models.sh && \
    # Ensure model directory structure
    mkdir -p /app/models/insightface && \
    mv models/insightface /app/models/ && \
    # Continue cleanup...
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