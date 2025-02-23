#!/bin/bash
set -eo pipefail

# Check if ComfyUI is responsive
if ! curl -sf http://localhost:8188/ > /dev/null; then
    echo "ERROR: ComfyUI is not responding!"
    exit 1
fi

# Check if Jupyter is responsive
if ! curl -sf http://localhost:8888/ > /dev/null; then
    echo "ERROR: Jupyter is not responding!"
    exit 1
fi

# Check if ttyd is responsive
if ! curl -sf http://localhost:7681/ > /dev/null; then
    echo "ERROR: Terminal is not responding!"
    exit 1
fi

# Check CUDA
if ! python3 -c "import torch; assert torch.cuda.is_available(), 'CUDA not available'"; then
    echo "ERROR: CUDA is not available!"
    exit 1
fi

echo "All services are healthy!"
exit 0