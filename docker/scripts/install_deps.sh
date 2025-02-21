# Python dependencies
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip3 install -r requirements.txt

# Cleanup should ONLY target Python caches
find /usr -name __pycache__ -exec rm -r {} +
python3 -m pip cache purge