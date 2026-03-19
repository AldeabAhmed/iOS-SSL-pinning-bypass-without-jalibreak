# 🍎 macOS Support for iOS SSL Pinning Bypass

This folder contains macOS-compatible scripts for SSL pinning bypass on iOS devices.

## 📁 Files Overview

### 🔧 Installation Scripts
- **`openvpn-install-macos-v2.sh`** - OpenVPN server installer for macOS
- **`pf-setup.sh`** - Packet Filter (pf) configuration for traffic redirection  
- **`quick-setup-macos.sh`** - All-in-one setup script

### 📚 Documentation
- **`README.md`** - Comprehensive macOS documentation and usage guide

---

## 🚀 Quick Start

### Prerequisites
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### One-Command Setup
```bash
# Run everything with a single command
sudo bash quick-setup-macos.sh <iOS_VPN_CLIENT_IP>

# Example:
sudo bash quick-setup-macos.sh 10.8.0.2
```

### Manual Setup (Step-by-Step)
```bash
# 1. Install OpenVPN server
sudo bash openvpn-install-macos-v2.sh

# 2. Start OpenVPN server  
sudo /usr/local/etc/openvpn/start.sh

# 3. Create client configuration
sudo /usr/local/etc/openvpn/add-client.sh my-iphone

# 4. Setup traffic redirection
sudo bash pf-setup.sh <iOS_VPN_CLIENT_IP>

# 5. Configure your proxy tool (Burp Suite/mitmproxy) on port 8080
```

---

## 🎯 Usage Flow

1. **🔧 Setup**: Install and configure OpenVPN + pf
2. **👤 Client**: Generate .ovpn configuration file  
3. **📱 Transfer**: Move .ovpn file to iOS device
4. **🔌 Proxy**: Configure Burp Suite/mitmproxy on port 8080
5. **🌐 Connect**: Connect iOS device to VPN
6. **🔍 Test**: Browse and intercept SSL traffic

---

## 📋 Management Commands

### OpenVPN Server
```bash
# Start server
sudo /usr/local/etc/openvpn/start.sh

# Check status  
sudo /opt/homebrew/sbin/openvpn --status /usr/local/etc/openvpn/status.log

# Stop server
sudo pkill -f 'openvpn --config server.conf'

# Add new client
sudo /usr/local/etc/openvpn/add-client.sh <client-name>
```

### PF Firewall
```bash
# Enable pf
sudo pfctl -e

# Disable pf
sudo pfctl -d

# Reload rules
sudo pfctl -f /etc/pf.conf

# Check status
sudo pfctl -s info

# View rules
sudo pfctl -s rules
```

---

## 📁 File Locations

### Configuration Files
- **Server Config**: `/usr/local/etc/openvpn/server.conf`
- **Client Configs**: `/usr/local/etc/openvpn/clients/`
- **Certificates**: `/usr/local/etc/openvpn/easy-rsa/pki/`
- **PF Rules**: `/etc/pf.conf`
- **PF Anchor**: `/etc/pf.anchors/ssl-bypass`

### Generated Files
- **Client .ovpn**: `/usr/local/etc/openvpn/clients/<client-name>.ovpn`
- **CA Certificate**: `/usr/local/etc/openvpn/ca.crt`
- **Server Certificate**: `/usr/local/etc/openvpn/server.crt`

---

## 🔧 iOS Device Setup

### 1. Import VPN Configuration
```bash
# Transfer the .ovpn file to your iOS device
# Location: /usr/local/etc/openvpn/clients/<client-name>.ovpn

# On iOS: Settings → General → VPN & Device Management → Add VPN Configuration
```

### 2. Install Proxy Certificate
```bash
# Export CA certificate from your proxy tool (Burp Suite/mitmproxy)
# Transfer to iOS device and install via Settings
```

### 3. Connect and Test
```bash
# Connect to the VPN on your iOS device
# Browse to HTTPS sites to verify interception
# Check your proxy tool for intercepted traffic
```

---

## 🛠️ Troubleshooting

### Common Issues

#### OpenVPN Issues
```bash
# Check if running
ps aux | grep openvpn

# Check logs
tail -f /usr/local/etc/openvpn/openvpn-status.log

# Test configuration
sudo /opt/homebrew/sbin/openvpn --config /usr/local/etc/openvpn/server.conf --test
```

#### PF Issues  
```bash
# Check pf status
sudo pfctl -s info

# View loaded rules
sudo pfctl -s rules

# Check for syntax errors
sudo pfctl -nf /etc/pf.conf
```

#### Permission Issues
```bash
# Fix directory permissions
sudo chown -R root:wheel /usr/local/etc/openvpn
sudo chmod 755 /usr/local/etc/openvpn

# Fix script permissions
sudo chmod +x /usr/local/etc/openvpn/*.sh
```

---

## ⚠️ Important Notes

### Security
- 🔒 This tool is for **authorized security testing only**
- 📱 Ensure you have permission to test the target application
- 🛡️ Use only on networks and applications you own or have permission to test

### macOS Specific
- 🍎 Uses **pf** instead of iptables (macOS native firewall)
- 🌐 Uses **utun0** instead of tun0 (macOS VPN interface)
- 📦 Uses **Homebrew** for package management
- 🔑 Requires **sudo/admin privileges** for system configuration

### Compatibility
- ✅ macOS Catalina (10.15+)
- ✅ Apple Silicon (M1/M2/M3) and Intel Macs
- ✅ iOS devices with VPN support
- ✅ Burp Suite, mitmproxy, and other SSL proxy tools

---

## 📋 Credits

### 🌟 Original Project
**Author**: Sahil H4ck4you  
**GitHub**: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak  
**License**: MIT License  
**Platform**: Linux (iptables + OpenVPN)

### 🍎 macOS Port
**Modified by**: Ahmed Aldeab  
**Twitter**: @0xfa7b  
**Date**: March 2026  
**Contributions**: 
- ✅ macOS compatibility
- ✅ pf firewall support (replaces iptables)
- ✅ Homebrew integration
- ✅ Apple Silicon support
- ✅ Enhanced documentation
- ✅ Quick setup script

### 🙏 Acknowledgments
- **OpenVPN**: https://openvpn.net/
- **Easy-RSA**: https://github.com/OpenVPN/easy-rsa
- **Homebrew**: https://brew.sh/
- **macOS PF Documentation**: Apple Developer Resources
- **Burp Suite**: https://portswigger.net/burp
- **Security Community**: All contributors and testers

---

## 📞 Support & Contributing

### Getting Help
- 📖 Check the comprehensive README.md in this folder
- 🔍 Review troubleshooting section above
- 🐛 Report issues on the original GitHub repository

### Contributing
- 🍏 Test thoroughly on macOS versions 10.15+
- 🔧 Verify pf rule syntax and functionality
- 📦 Check Homebrew compatibility
- 📝 Document any macOS-specific requirements or issues

---

**Disclaimer**: This tool is intended for authorized security research and penetration testing only. Users are responsible for ensuring compliance with applicable laws and regulations.
