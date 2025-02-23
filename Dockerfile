FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# Base system with layer optimization
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget git python3 python3-pip \
    libgl1 libglib2.0-0 tini tmux \
    ca-certificates libtcmalloc-minimal4 \
    build-essential python3-dev supervisor curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory structure with proper ownership
RUN mkdir -p /root/config /app /tmp/scripts /var/log/supervisor /app/output && \
    chown -R root:root /app && \
    chmod -R 755 /root/config /app /tmp/scripts /var/log/supervisor /app/output

# Set working directory and clone ComfyUI
WORKDIR /app
RUN git config --global --add safe.directory '*' && \
    git clone --depth 1 https://github.com/comfyanonymous/ComfyUI /tmp/comfyui && \
    cp -r /tmp/comfyui/. . && \
    rm -rf /tmp/comfyui && \
    chown -R root:root . && \
    chmod -R 755 .

# Copy configurations and set permissions
COPY docker/config/ /root/config/
COPY docker/scripts/ /tmp/scripts/
COPY docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 600 /root/config/jupyter_server_config.py && \
    chmod +x /tmp/scripts/*.sh

# Setup CUDA environment
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV PYTHONPATH=/app
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4

# Install PyTorch and verify installation
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir \
    torch==2.1.0+cu121 \
    torchvision==0.16.0+cu121 \
    torchaudio==2.1.0+cu121 \
    --index-url https://download.pytorch.org/whl/cu121

# Install core dependencies
COPY docker/config/requirements.txt /root/config/
RUN cd /app && \
    python3 -m pip install --no-cache-dir -r /root/config/requirements.txt && \
    python3 -m pip install --no-cache-dir \
    xformers==0.0.21 \
    aiohttp \
    einops \
    scipy \
    tqdm \
    psutil \
    requests \
    pyyaml \
    hjson \
    websockets && \
    python3 -c 'import torch; print(f"CUDA Available: {torch.cuda.is_available()}"); print(f"PyTorch Version: {torch.__version__}")' && \
    /tmp/scripts/install_deps.sh && \
    /tmp/scripts/install_nodes.sh && \
    /tmp/scripts/install_models.sh && \
    rm -rf /tmp/scripts/ && \
    find /usr -depth -name '__pycache__' -exec rm -rf {} + && \
    python3 -m pip cache purge

# Environment setup
ENV JUPYTER_TOKEN=""
ENV JUPYTER_PASSWORD=""
ENV TINI_SUBREAPER=true

# Install system dependencies and Python packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ttyd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --no-cache-dir jupyterlab

# Copy and setup scripts
COPY start.sh /start.sh
COPY docker/scripts/healthcheck.sh /usr/local/bin/
RUN chmod +x /start.sh /usr/local/bin/healthcheck.sh

# Container metadata
LABEL maintainer="BoredDaoist" \
      description="ComfyUI with Jupyter and Terminal access" \
      version="1.0"

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

EXPOSE 8188 8888 7681
EXPOSE 8189 8889 7682

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]