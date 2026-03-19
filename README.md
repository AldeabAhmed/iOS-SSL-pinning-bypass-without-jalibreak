# iOS SSL Pinning Bypass - macOS Support

This folder contains macOS-compatible scripts for SSL pinning bypass on iOS devices.

## 🍎 macOS Support

### Scripts Overview

#### 1. `openvpn-install-macos-v2.sh`
- **Purpose**: Automated OpenVPN server installation for macOS
- **Compatibility**: macOS 10.15+
- **Dependencies**: Homebrew, OpenVPN
- **Features**:
  - Automatic Homebrew detection
  - Easy-RSA certificate management
  - Client configuration generation
  - Startup scripts included

#### 2. `pf-setup.sh`
- **Purpose**: Packet Filter (pf) configuration for traffic redirection
- **Compatibility**: macOS native firewall
- **Features**:
  - HTTP/HTTPS traffic redirection to port 8080
  - NAT configuration for VPN subnet
  - Automatic pf.conf backup
  - Anchor rules for easy management

## 🚀 Quick Start

### Prerequisites
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install OpenVPN
brew install openvpn
```

### Installation & Setup
```bash
# 1. Make scripts executable
chmod +x openvpn-install-macos-v2.sh pf-setup.sh

# 2. Install OpenVPN server
sudo bash openvpn-install-macos-v2.sh

# 3. Start OpenVPN server
sudo /usr/local/etc/openvpn/start.sh

# 4. Create client configuration
sudo /usr/local/etc/openvpn/add-client.sh your-client-name

# 5. Setup traffic redirection
sudo bash pf-setup.sh <iOS_VPN_CLIENT_IP>

# 6. Configure your proxy tool (Burp Suite, mitmproxy) to listen on port 8080
```

### Usage Flow
1. **Server Setup**: Install and configure OpenVPN server
2. **Client Creation**: Generate .ovpn configuration file
3. **Traffic Redirection**: Configure pf to redirect HTTP/HTTPS to your proxy
4. **Proxy Configuration**: Set up Burp Suite/mitmproxy on port 8080
5. **iOS Connection**: Connect iOS device to VPN and install proxy CA certificate

## 🛠️ Configuration Files

### OpenVPN Configuration: `/usr/local/etc/openvpn/server.conf`
```bash
port 1194
proto udp
dev tun
server 10.8.0.0 255.255.255.0
# ... additional settings
```

### PF Configuration: `/etc/pf.conf`
```bash
# Traffic redirection rules
rdr on utun0 inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
rdr on utun0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 8080
```

## 🔧 Commands Reference

### OpenVPN Management
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

### PF Firewall Management
```bash
# Enable pf with rules
sudo pfctl -f /etc/pf.conf && sudo pfctl -e

# Disable pf
sudo pfctl -d

# Check pf status
sudo pfctl -s info

# View NAT rules
sudo pfctl -s nat

# Reload rules
sudo pfctl -f /etc/pf.conf
```

## 📱 iOS Device Setup

1. **Install Client Configuration**:
   - Transfer `.ovpn` file from `/usr/local/etc/openvpn/clients/` to iOS device
   - Replace `YOUR_SERVER_IP` with your actual server IP

2. **Configure VPN**:
   - Settings → General → VPN & Device Management → Add VPN Configuration
   - Import the .ovpn file

3. **Install Proxy Certificate**:
   - Export CA certificate from your proxy tool
   - Transfer to iOS device and install via Settings

4. **Connect and Test**:
   - Connect to the VPN
   - Browse to HTTPS sites to verify interception

## 🔍 Troubleshooting

### Common Issues

#### OpenVPN Issues
```bash
# Check if OpenVPN is running
ps aux | grep openvpn

# Check OpenVPN logs
tail -f /usr/local/etc/openvpn/openvpn-status.log

# Verify configuration
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

## ⚠️ Important Notes

- **Security**: This tool is for authorized security testing only
- **Permissions**: Some operations require sudo/admin privileges
- **Firewall**: pf replaces iptables on macOS - they are not compatible
- **Interface Names**: macOS uses `utun0` instead of `tun0` for VPN interfaces
- **Certificate Management**: Always backup your CA certificates

## 📚 Additional Resources

- [OpenVPN macOS Documentation](https://openvpn.net/community-resources/how-to/)
- [macOS PF Firewall Guide](https://www.openbsd.org/faq/pf/)
- [Burp Suite Proxy Configuration](https://portswigger.net/burp/documentation/desktop/getting-started)

## 🤝 Contributing

For issues, improvements, or macOS-specific enhancements:
1. Test thoroughly on macOS versions 10.15+
2. Verify pf rule syntax
3. Check Homebrew compatibility
4. Document any macOS-specific requirements

---

## 📋 Credits

### Original Project
**Author**: Sahil H4ck4you  
**GitHub**: https://github.com/SahilH4ck4you/iOS-SSL-pinning-bypass-without-jalibreak  
**Original License**: MIT License

### macOS Port
**Modified by**: Ahmed Aldeab  
**Twitter**: @0xfa7b  
**Contribution**: macOS compatibility, pf firewall support, Homebrew integration  
**Date**: March 2026

### Acknowledgments
- Original OpenVPN installer: [Nyr/openvpn-install](https://github.com/Nyr/openvpn-install)
- Easy-RSA: [OpenVPN/easy-rsa](https://github.com/OpenVPN/easy-rsa)
- macOS pf documentation and community contributors

---

**Disclaimer**: This tool is intended for authorized security research and penetration testing only. Users are responsible for ensuring compliance with applicable laws and regulations.
