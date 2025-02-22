# BoringComfy

A Docker-based environment for running ComfyUI with Jupyter Lab and terminal access.

## Features
- ComfyUI for AI image generation
- Jupyter Lab for interactive development
- Web-based terminal access
- CUDA support for GPU acceleration
- Supervisor-managed services

## Prerequisites
- Docker
- NVIDIA GPU with CUDA support
- NVIDIA Container Toolkit

## Environment Variables
- `JUPYTER_TOKEN`: Custom token for Jupyter access (optional)
- `JUPYTER_PASSWORD`: Custom password for Jupyter access (optional)
- `CUDA_VISIBLE_DEVICES`: GPU selection (default: all)

## Building and Running

```bash
# Build the image
docker build -t boringcomfy .

# Run with GPU support
docker run --gpus all \
    -p 8188:8188 \
    -p 8888:8888 \
    -p 7681:7681 \
    boringcomfy
```

## Service Access
- ComfyUI: http://localhost:8188
- Jupyter Lab: http://localhost:8888
- Terminal: http://localhost:7681

## Troubleshooting

### Common Issues
1. If ComfyUI fails to start:
   - Check GPU availability with `nvidia-smi`
   - Verify CUDA installation
2. For Jupyter access issues:
   - Check container logs: `docker logs <container_id>`
3. If services don't start:
   - Check supervisor logs in `/var/log/supervisor/`

### Logs
Service logs are available in the container at:
- ComfyUI: `/var/log/supervisor/comfyui.log`
- Jupyter: `/var/log/supervisor/jupyter.log`
- Terminal: `/var/log/supervisor/ttyd.log`

## License
MIT License