# SSL Pinning Bypass for iOS — iptables

A collection of bash scripts for setting up an OpenVPN server with iptables rules to intercept and redirect iOS traffic for SSL pinning bypass during security research and penetration testing.

## 📁 Scripts

### 1. `openvpn-install.sh`
Automated OpenVPN server installer based on [Nyr/openvpn-install](https://github.com/Nyr/openvpn-install).

**Supports:** Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+, Fedora

**Features:**
- Full OpenVPN server setup with PKI (via easy-rsa)
- Supports UDP and TCP
- Configurable DNS (Google, Cloudflare, OpenDNS, Quad9, AdGuard, custom)
- Manages iptables/firewalld rules automatically
- Add/revoke clients without reinstalling

**Usage:**
```bash
chmod +x openvpn-install.sh
sudo bash openvpn-install.sh
```

---

### 2. `iptables-setup.sh`
Sets up iptables NAT rules to redirect HTTP/HTTPS traffic from the VPN tunnel (`tun0`) to a local proxy (port `8080`) — useful for tools like Burp Suite or mitmproxy.

**What it does:**
- Redirects port `80` → `8080` on `tun0`
- Redirects port `443` → `8080` on `tun0`
- Adds MASQUERADE rule for the given subnet on `eth0`

**Usage:**
```bash
chmod +x iptables-setup.sh
sudo bash iptables-setup.sh <VPN_SERVER_IP>

# Example:
sudo bash iptables-setup.sh 10.8.0.1
```

---

## 🔧 Typical Setup Flow

1. Run `openvpn-install.sh` to set up your VPN server
2. Configure your proxy tool (e.g., Burp Suite) to listen on port `8080` with your VPN interface IP (e.g., `10.x.x.1`)
   - In Burp Suite: **Proxy → Options → Interface IP → Request Handling → Enable Support for Invisible Proxying**
3. Connect your iOS device to the VPN
4. Run `iptables-setup.sh` with your iOS device's VPN client IP to redirect traffic to your proxy
   ```
   sudo bash iptables-setup.sh <iOS_VPN_CLIENT_IP>
   # Example: sudo bash iptables-setup.sh 10.8.0.2
   ```
5. Install your proxy's CA certificate on the iOS device
   - Export CA from Burp Suite → transfer to device → **Settings → General → VPN & Device Management → Install**

---

## 📋 Requirements

- Linux server (root access)
- `iptables`
- OpenVPN (installed via `openvpn-install.sh`)
- A proxy tool (Burp Suite, mitmproxy, etc.) listening on port `8080`

---
