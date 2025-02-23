FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# Base system with layer optimization
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates libtcmalloc-minimal4 \
    build-essential python3-dev supervisor curl \
    nvidia-cuda-toolkit && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory structure and set permissions
RUN mkdir -p /root/config /app /tmp/scripts /var/log/supervisor /app/output && \
    chmod 755 /root/config /app /tmp/scripts /var/log/supervisor /app/output

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
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir wheel setuptools && \
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
ENV PYTHONPATH=/app
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Install system dependencies and Python packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ttyd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --no-cache-dir jupyterlab

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Container metadata
LABEL maintainer="BoredDaoist" \
      description="ComfyUI with Jupyter and Terminal access" \
      version="1.0"

# Copy healthcheck script
COPY docker/scripts/healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/healthcheck.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh


EXPOSE 8188 8888 7681

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]