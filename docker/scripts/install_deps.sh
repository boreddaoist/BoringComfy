# Python dependencies
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip3 install -r requirements.txt


# Cleanup
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
find /usr -name __pycache__ -exec rm -r {} +