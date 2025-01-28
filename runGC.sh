#!/bin/bash
echo "Checking AMD SEV Availability"
sudo dmesg | grep SEV | head

echo "Updating package lists and installing required software..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y python3 python3-pip

echo "Verifying pip installation..."
pip3 --version

echo "Displaying system information..."
lsb_release -a

echo "Cloning the repository..."
git clone https://github.com/oguzhan-baser/confidential-compute

echo "Installing required Python libraries..."
pip install torch torchvision argparse

cd confidential-compute || { echo "Repository not found! Exiting..."; exit 1; }
mkdir -p inputs outputs

TARGET_DIR="$HOME/.local/bin"
CONFIG_FILE=""

if [[ "$SHELL" == */bash ]]; then
    CONFIG_FILE="$HOME/.bashrc"
elif [[ "$SHELL" == */zsh ]]; then
    CONFIG_FILE="$HOME/.zshrc"
else
    echo "Unsupported shell. Please use Bash or Zsh."
    exit 1
fi

if echo "$PATH" | grep -q "$TARGET_DIR"; then
    echo "$TARGET_DIR is already in PATH."
else
    echo "Adding $TARGET_DIR to PATH in $CONFIG_FILE..."
    echo "export PATH=\"\$PATH:$TARGET_DIR\"" >> "$CONFIG_FILE"

    echo "Reloading $CONFIG_FILE..."
    source "$CONFIG_FILE"

    echo "Successfully added $TARGET_DIR to PATH."
fi

echo "Obtaining the dataset..."
gsutil cp -r gs://confcomputeminst/* ~/confidential-compute/inputs/

echo "Running the MNIST training script..."
python3 mnist_train.py


echo "Moving the model file..."
gsutil cp -r mnist_cnn.pt gs://confcomputeminst/outputs/
