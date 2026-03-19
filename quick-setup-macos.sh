#!/bin/bash
#
# iOS SSL Pinning Bypass - macOS Quick Setup Script
#
# This script provides a quick setup for macOS SSL pinning bypass
# It combines all necessary steps in one script
#
# Original Linux Version: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak
# macOS Port: Ahmed Aldeab (@0xfa7b)
# Date: March 2026
#
# Usage:
#   sudo bash quick-setup-macos.sh <iOS_VPN_CLIENT_IP>
#
# Example:
#   sudo bash quick-setup-macos.sh 10.8.0.2
#
# This script will:
#   1. Check dependencies
#   2. Install OpenVPN server
#   3. Generate client configuration
#   4. Setup pf firewall rules
#   5. Start all services
#

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is designed for macOS only."
    exit 1
fi

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run with sudo"
   echo "🔓 Try: sudo bash $0 <IP_ADDRESS>"
   exit 1
fi

# Check if IP address argument is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide an IP address"
    echo "📖 Usage: $0 <IP_ADDRESS>"
    echo "💡 Example: $0 10.8.0.2"
    exit 1
fi

IP_ADDRESS="$1"

# Validate IP address format
if ! [[ $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Invalid IP address format"
    echo "📍 Please use format: xxx.xxx.xxx.xxx"
    exit 1
fi

echo "🍎 iOS SSL Pinning Bypass - macOS Quick Setup"
echo "👤 macOS Port by: Ahmed Aldeab (@0xfa7b)"
echo "🌟 Original project: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak"
echo ""
echo "🎯 Target iOS Client IP: $IP_ADDRESS"
echo ""

# Step 1: Check dependencies
echo "📋 Step 1: Checking dependencies..."
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install it first:"
    echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

if ! command -v openvpn &> /dev/null; then
    echo "📦 Installing OpenVPN..."
    brew install openvpn
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to install OpenVPN"
        exit 1
    fi
else
    echo "✅ OpenVPN is already installed"
fi

# Step 2: Install OpenVPN server
echo ""
echo "📋 Step 2: Installing OpenVPN server..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/openvpn-install-macos-v2.sh" ]]; then
    echo "❌ openvpn-install-macos-v2.sh not found in current directory"
    exit 1
fi

bash "$SCRIPT_DIR/openvpn-install-macos-v2.sh"
if [[ $? -ne 0 ]]; then
    echo "❌ OpenVPN installation failed"
    exit 1
fi

# Step 3: Start OpenVPN server
echo ""
echo "📋 Step 3: Starting OpenVPN server..."
/usr/local/etc/openvpn/start.sh
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to start OpenVPN server"
    exit 1
fi

# Wait a moment for server to start
sleep 2

# Check if OpenVPN is running
if ! pgrep -f "openvpn --config server.conf" > /dev/null; then
    echo "❌ OpenVPN server is not running"
    exit 1
fi

echo "✅ OpenVPN server is running"

# Step 4: Generate client configuration
echo ""
echo "📋 Step 4: Generating client configuration..."
CLIENT_NAME="ios-client"

/usr/local/etc/openvpn/add-client.sh "$CLIENT_NAME"
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to generate client configuration"
    exit 1
fi

CLIENT_CONFIG="/usr/local/etc/openvpn/clients/$CLIENT_NAME.ovpn"
if [[ ! -f "$CLIENT_CONFIG" ]]; then
    echo "❌ Client configuration file not found"
    exit 1
fi

echo "✅ Client configuration created: $CLIENT_CONFIG"

# Step 5: Setup pf firewall
echo ""
echo "📋 Step 5: Setting up pf firewall..."

if [[ ! -f "$SCRIPT_DIR/pf-setup.sh" ]]; then
    echo "❌ pf-setup.sh not found in current directory"
    exit 1
fi

bash "$SCRIPT_DIR/pf-setup.sh" "$IP_ADDRESS"
if [[ $? -ne 0 ]]; then
    echo "❌ pf setup failed"
    exit 1
fi

# Step 6: Final verification
echo ""
echo "📋 Step 6: Final verification..."

# Check OpenVPN status
if pgrep -f "openvpn --config server.conf" > /dev/null; then
    echo "✅ OpenVPN server: RUNNING"
else
    echo "❌ OpenVPN server: NOT RUNNING"
fi

# Check pf status
if pfctl -s info 2>/dev/null | grep -q "Status: Enabled"; then
    echo "✅ pf firewall: ENABLED"
else
    echo "❌ pf firewall: NOT ENABLED"
fi

# Check client config
if [[ -f "$CLIENT_CONFIG" ]]; then
    echo "✅ Client config: CREATED"
else
    echo "❌ Client config: NOT FOUND"
fi

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "   1️⃣  Transfer client config to your iOS device:"
echo "       📁 $CLIENT_CONFIG"
echo ""
echo "   2️⃣  Replace YOUR_SERVER_IP in the .ovpn file with your actual server IP"
echo ""
echo "   3️⃣  Configure your proxy tool (Burp Suite/mitmproxy) to listen on port 8080"
echo "       🎯 Make sure it accepts connections from VPN interface (utun0)"
echo ""
echo "   4️⃣  Import the .ovpn file on your iOS device and connect to VPN"
echo ""
echo "   5️⃣  Install your proxy's CA certificate on the iOS device"
echo ""
echo "🔧 Management Commands:"
echo "   🔄 Restart OpenVPN: sudo /usr/local/etc/openvpn/start.sh"
echo "   🔴 Stop OpenVPN: sudo pkill -f 'openvpn --config server.conf'"
echo "   🔄 Reload pf rules: sudo pfctl -f /etc/pf.conf"
echo "   🔴 Disable pf: sudo pfctl -d"
echo ""
echo "📁 Important Files:"
echo "   📄 Client config: $CLIENT_CONFIG"
echo "   ⚙️  Server config: /usr/local/etc/openvpn/server.conf"
echo "   🔥 pf config: /etc/pf.conf"
echo ""
echo "⚠️  Security Notice:"
echo "   🔒 This tool is for authorized security testing only"
echo "   📱 Ensure you have permission to test the target iOS application"
echo ""
echo "👤 macOS Port by: Ahmed Aldeab (@0xfa7b)"
echo "🌟 Original project: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak"
echo "🍎 Enjoy your macOS SSL pinning bypass setup!"
