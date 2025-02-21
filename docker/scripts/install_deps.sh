#!/bin/bash

# System dependencies
apt-get install -y libgl1-mesa-glx libgomp1

# Python dependencies
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt
pip install insightface segment-anything-py==1.0 groundingdino-py==0.4.0 onnxruntime==1.16.0 controlnet-aux==0.0.6