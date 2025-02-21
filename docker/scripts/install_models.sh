#!/bin/bash

# InsightFace
mkdir -p models/insightface/models/buffalo_l
wget -O /root/.insightface/models/buffalo_l/1k3d68.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_1k3d68.onnx
wget -O /root/.insightface/models/buffalo_l/2d106det.onnx \
    https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l_2d106det.onnx


