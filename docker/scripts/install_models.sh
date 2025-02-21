#!/bin/bash
set -e
set -x

# InsightFace models (updated to Hugging Face URLs)
mkdir -p models/insightface/models/buffalo_l
wget --tries=3 --retry-connrefused -O models/insightface/models/buffalo_l/1k3d68.onnx \
    https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/1k3d68.onnx

wget --tries=3 --retry-connrefused -O models/insightface/models/buffalo_l/2d106det.onnx \
    https://huggingface.co/lithiumice/insightface/resolve/1141cd22e2bff0d4036d10ba4151903605a8902d/models/buffalo_l/2d106det.onnx

# Verify downloads
if [ ! -f models/insightface/models/buffalo_l/1k3d68.onnx ]; then
    echo "Error: InsightFace model download failed!"
    exit 1
fi