FROM ubuntu:22.04

# Base system with layer optimization
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates libtcmalloc-minimal4 \
    build-essential python3-dev supervisor curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# CUDA Environment setup
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Create directory structure
RUN mkdir -p /root/config /app /tmp/scripts /var/log/supervisor

# Copy configurations
COPY docker/config/ /root/config/
RUN chmod 600 /root/config/jupyter_server_config.py

# Install core
RUN git clone https://github.com/comfyanonymous/ComfyUI /app
WORKDIR /app

# Copy installation scripts and supervisor config
COPY docker/scripts/ /tmp/scripts/
COPY docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
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
ENV JUPYTER_TOKEN=""
ENV JUPYTER_PASSWORD=""
ENV TINI_SUBREAPER=true

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

# Container metadata
LABEL maintainer="BoredDaoist" \
      description="ComfyUI with Jupyter and Terminal access" \
      version="1.0"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8188/ || exit 1

EXPOSE 8188 8888 7681

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]