#!/bin/bash

# Install additional penetration testing tools
echo "Installing additional tools..."

# Install Go (for some tools)
wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Install additional Go-based tools
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Install Burp Suite Community (headless)
wget -q "https://portswigger.net/burp/releases/download?product=community&type=Linux" -O burpsuite_community.sh
chmod +x burpsuite_community.sh

echo "Additional tools installation complete!"
