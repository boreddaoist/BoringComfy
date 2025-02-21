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
