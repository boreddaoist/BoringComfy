#!/bin/bash

# Fooocus Inpaint
mkdir -p models/inpaint
wget -O models/inpaint/inpaint_v26.fooocus.patch \
    https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch
wget -O models/inpaint/fooocus_inpaint_head.pth \
    https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth

# InsightFace
mkdir -p /root/.insightface/models/buffalo_l
wget -O /root/.insightface/models/buffalo_l/1k3d68.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_1k3d68.onnx
wget -O /root/.insightface/models/buffalo_l/2d106det.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_2d106det.onnx

# Workflow-specific models
mkdir -p models/checkpoints && \
wget -O models/checkpoints/dreamshaperXL_v21TurboDPMSDE.safetensors \
    https://civitai.com/api/download/models/351306

mkdir -p models/loras && \
wget -O models/loras/HandFineTuning_XL.safetensors \
    https://huggingface.co/yesyeahvh/HandFineTuning_XL/resolve/main/HandFineTuning_XL.safetensors

mkdir -p models/controlnet && \
wget -O models/controlnet/ControlNetModel/diffusion_pytorch_model.safetensors \
    https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors