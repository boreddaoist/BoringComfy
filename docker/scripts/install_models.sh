#!/bin/bash

# InsightFace - Corrected path
mkdir -p models/insightface/models/buffalo_l
wget -O models/insightface/models/buffalo_l/1k3d68.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_1k3d68.onnx
wget -O models/insightface/models/buffalo_l/2d106det.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_2d106det.onnx

# Add error handling at the end
if [ ! -f models/insightface/models/buffalo_l/1k3d68.onnx ]; then
    echo "Error: InsightFace model download failed!"
    exit 1
fi