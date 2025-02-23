FROM nvidia/cuda:12.1.0-base-ubuntu22.04

# Base system with layer optimization
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates libtcmalloc-minimal4 \
    build-essential python3-dev supervisor curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory structure and set permissions
RUN mkdir -p /root/config /app /tmp/scripts /var/log/supervisor && \
    chmod 755 /root/config /app /tmp/scripts /var/log/supervisor

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

# Install dependencies and cleanup
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    /tmp/scripts/install_deps.sh && \
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

# Install system dependencies and Python packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ttyd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --upgrade pip && \
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