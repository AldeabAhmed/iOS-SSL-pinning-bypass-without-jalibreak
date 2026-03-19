#!/bin/bash
#
# iOS SSL Pinning Bypass - macOS OpenVPN Installer
# 
# This script installs and configures OpenVPN server on macOS for SSL pinning bypass
# Compatible with macOS 10.15+ using Homebrew package management
#
# Original Linux Version: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak
# macOS Port: Ahmed Aldeab (@0xfa7b)
# Date: March 2026
#
# Dependencies:
# - macOS 10.15+
# - Homebrew (auto-installed if missing)
# - OpenVPN (installed via Homebrew)
# - Easy-RSA (downloaded automatically)
#
# Features:
# - Automatic OpenVPN installation via Homebrew
# - Certificate Authority (CA) generation
# - Server certificate creation
# - Client configuration generation
# - Startup scripts
# - macOS-specific paths and configurations
#
# Usage:
#   sudo bash openvpn-install-macos-v2.sh
#
# After installation:
#   sudo /usr/local/etc/openvpn/start.sh                    # Start server
#   sudo /usr/local/etc/openvpn/add-client.sh <client-name> # Add client
#
# Configuration files location:
#   Server config: /usr/local/etc/openvpn/server.conf
#   Client configs: /usr/local/etc/openvpn/clients/
#   Certificates: /usr/local/etc/openvpn/easy-rsa/pki/
#
# Security Notes:
# - This script requires sudo privileges for system configuration
# - Certificates are generated without password for demo purposes
# - For production use, consider adding password protection
#
# Compatible with:
#   - macOS Catalina (10.15)+
#   - Apple Silicon (M1/M2/M3) and Intel Macs
#   - Homebrew package manager
#

# Detect if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This installer is designed for macOS only."
    echo "For Linux, use the original openvpn-install.sh script"
    exit 1
fi

# Check if OpenVPN is already installed
if command -v openvpn &> /dev/null; then
    echo "✅ OpenVPN is already installed"
    OPENVPN_CMD=$(which openvpn)
else
    echo "❌ OpenVPN is not installed. Please install it first:"
    echo "   brew install openvpn"
    echo "Then run this script again."
    exit 1
fi

# Check if running with sudo for system operations
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run with sudo for system configuration"
   echo "   Usage: sudo bash $0"
   exit 1
fi

echo "🍎 macOS OpenVPN SSL Pinning Bypass Installer"
echo "📍 Using OpenVPN at: $OPENVPN_CMD"
echo ""

# Create directories
echo "📁 Creating configuration directories..."
mkdir -p /usr/local/etc/openvpn
mkdir -p /usr/local/etc/openvpn/ccd
mkdir -p /usr/local/etc/openvpn/clients

# Download and setup easy-rsa
echo "⬇️  Setting up easy-rsa..."
cd /usr/local/etc/openvpn
if [[ ! -d "easy-rsa" ]]; then
    echo "   Downloading easy-rsa source..."
    curl -L https://github.com/OpenVPN/easy-rsa/archive/refs/tags/v3.1.6.tar.gz | tar xz
    mv easy-rsa-3.1.6 easy-rsa
fi

cd easy-rsa
# Use easyrsa3/easyrsa on macOS
EASYRSA_EXEC="./easyrsa3/easyrsa"
if [[ ! -f "$EASYRSA_EXEC" ]]; then
    echo "❌ Error: easyrsa3/easyrsa executable not found"
    exit 1
fi

# Initialize PKI if not already done
if [[ ! -d "pki" ]]; then
    echo "🔐 Initializing PKI..."
    $EASYRSA_EXEC init-pki
fi

# Build CA if not exists
if [[ ! -f "pki/ca.crt" ]]; then
    echo "🏛️  Building Certificate Authority..."
    $EASYRSA_EXEC build-ca nopass
fi

# Generate server certificate if not exists
if [[ ! -f "pki/issued/server.crt" ]]; then
    echo "📜 Generating server certificate..."
    $EASYRSA_EXEC gen-req server nopass
    $EASYRSA_EXEC sign-req server server
fi

# Generate DH parameters if not exists
if [[ ! -f "pki/dh.pem" ]]; then
    echo "🔑 Generating DH parameters..."
    $EASYRSA_EXEC gen-dh
fi

# Generate TLS auth key if not exists
if [[ ! -f "ta.key" ]]; then
    echo "🔒 Generating TLS auth key..."
    $OPENVPN_CMD --genkey --secret ta.key
fi

# Create server configuration
echo "⚙️  Creating server configuration..."
cat > /usr/local/etc/openvpn/server.conf << 'EOF'
port 1194
proto udp
dev tun
user nobody
group nobody
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
duplicate-cn
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
status openvpn-status.log
verb 3
explicit-exit-notify 1
cipher AES-256-CBC
auth SHA256
EOF

# Copy certificates to main directory
echo "📋 Copying certificates..."
cp pki/ca.crt /usr/local/etc/openvpn/
cp pki/issued/server.crt /usr/local/etc/openvpn/
cp pki/private/server.key /usr/local/etc/openvpn/
cp pki/dh.pem /usr/local/etc/openvpn/
cp ta.key /usr/local/etc/openvpn/

# Create startup script
echo "🚀 Creating startup script..."
cat > /usr/local/etc/openvpn/start.sh << EOF
#!/bin/bash
cd /usr/local/etc/openvpn
$OPENVPN_CMD --config server.conf --daemon
EOF

chmod +x /usr/local/etc/openvpn/start.sh

# Create client generation script
echo "👤 Creating client generation script..."
cat > /usr/local/etc/openvpn/add-client.sh << EOF
#!/bin/bash
#
# Client Configuration Generator
# Usage: sudo bash add-client.sh <client-name>
#
if [ \$# -eq 0 ]; then
    echo "❌ Usage: \$0 <client-name>"
    echo "   Example: \$0 my-iphone"
    exit 1
fi

CLIENT_NAME="\$1"
cd /usr/local/etc/openvpn/easy-rsa

echo "🔐 Generating certificate for client: \$CLIENT_NAME"
./easyrsa3/easyrsa gen-req "\$CLIENT_NAME" nopass
./easyrsa3/easyrsa sign-req client "\$CLIENT_NAME"

# Create client configuration
cat > "/usr/local/etc/openvpn/clients/\$CLIENT_NAME.ovpn" << EOL
client
dev tun
proto udp
remote YOUR_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
verb 3
explicit-exit-notify 1
<ca>
\$(cat /usr/local/etc/openvpn/ca.crt)
</ca>
<cert>
\$(cat pki/issued/\$CLIENT_NAME.crt)
</cert>
<key>
\$(cat pki/private/\$CLIENT_NAME.key)
</key>
<tls-auth>
\$(cat /usr/local/etc/openvpn/ta.key)
</tls-auth>
key-direction 0
EOL

echo "✅ Client configuration created: /usr/local/etc/openvpn/clients/\$CLIENT_NAME.ovpn"
echo "📝 Remember to replace YOUR_SERVER_IP with your actual server IP address."
echo "📱 Transfer this .ovpn file to your iOS device and import it in VPN settings."
EOF

chmod +x /usr/local/etc/openvpn/add-client.sh

echo ""
echo "🎉 OpenVPN server installation complete!"
echo ""
echo "📋 Next Steps:"
echo "   1️⃣  Start the server: sudo /usr/local/etc/openvpn/start.sh"
echo "   2️⃣  Add a client: sudo /usr/local/etc/openvpn/add-client.sh <client-name>"
echo "   3️⃣  Setup traffic redirection: sudo bash pf-setup.sh <iOS_VPN_CLIENT_IP>"
echo "   4️⃣  Configure port forwarding on your router if needed"
echo "   5️⃣  Replace YOUR_SERVER_IP in client configuration with your public IP"
echo ""
echo "🔍 Management Commands:"
echo "   Check status: sudo $OPENVPN_CMD --status /usr/local/etc/openvpn/status.log"
echo "   Stop server: sudo pkill -f 'openvpn --config server.conf'"
echo ""
echo "📁 Configuration Files:"
echo "   Server: /usr/local/etc/openvpn/server.conf"
echo "   Clients: /usr/local/etc/openvpn/clients/"
echo "   Certificates: /usr/local/etc/openvpn/easy-rsa/pki/"
echo ""
echo "⚠️  Note: macOS may require additional security permissions for OpenVPN."
echo "    Check System Preferences > Security & Privacy if prompted."
echo ""
echo "👤 macOS Port by: Ahmed Aldeab (@0xfa7b)"
echo "🌟 Original project: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak"
