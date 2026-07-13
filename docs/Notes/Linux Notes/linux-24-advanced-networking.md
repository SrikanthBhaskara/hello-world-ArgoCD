# Linux 24 – Advanced Networking (Bonding, Bridging, Routing, Load Balancing)

## 0. Goal of This Note

- Configure network bonding for redundancy and load balancing.
- Set up network bridges for virtual machines and containers.
- Master static routing and advanced routing scenarios.
- Implement reverse proxies and load balancers with HAProxy and Nginx.
- Deep dive into NAT, port forwarding, and IPv6.

---

## 1. Network Bonding (Link Aggregation)

### 1.1 What is Network Bonding?

**Bonding** (also called **Link Aggregation** or **NIC Teaming**):
- Combine multiple network interfaces into single logical interface
- **Benefits**:
  - Redundancy: If one NIC fails, traffic uses another
  - Increased bandwidth: Combine throughput
  - Load balancing: Distribute traffic across NICs

**Linux bonding module**: `bonding.ko`

### 1.2 Bonding Modes

| Mode | Name | Description | Use Case |
|------|------|-------------|----------|
| **0** | balance-rr (round-robin) | Transmits packets in sequential order | Load balancing, requires switch support |
| **1** | active-backup | One NIC active, others standby | Redundancy, works with any switch |
| **2** | balance-xor | XOR hash for load balancing | Load balancing |
| **3** | broadcast | Transmits on all interfaces | Redundancy (rarely used) |
| **4** | 802.3ad (LACP) | IEEE standard, dynamic aggregation | High performance, requires switch config |
| **5** | balance-tlb | Adaptive transmit load balancing | Outbound load balancing |
| **6** | balance-alb | Adaptive load balancing | Inbound/outbound load balancing |

**Most common modes**:
- **Mode 1 (active-backup)**: Simple redundancy, works everywhere
- **Mode 4 (802.3ad)**: Best performance, requires LACP-capable switch

### 1.3 Configure Bonding (Manual Method)

**Step 1: Load bonding module**:
```bash
sudo modprobe bonding
lsmod | grep bonding

# Make permanent
echo "bonding" | sudo tee -a /etc/modules
```

**Step 2: Create bond interface**:
```bash
# Using ip command (temporary)
sudo ip link add bond0 type bond mode 802.3ad
sudo ip link set bond0 up

# Add slave interfaces
sudo ip link set eth0 master bond0
sudo ip link set eth1 master bond0

# Assign IP
sudo ip addr add 192.168.1.100/24 dev bond0
sudo ip route add default via 192.168.1.1
```

**Step 3: Verify**:
```bash
cat /proc/net/bonding/bond0
# Shows bonding mode, slave status

ip link show bond0
```

### 1.4 Configure Bonding (NetworkManager)

**Using nmcli** (recommended on modern systems):
```bash
# Create bond interface
sudo nmcli con add type bond ifname bond0 mode active-backup

# Add IP configuration
sudo nmcli con mod bond-bond0 ipv4.addresses 192.168.1.100/24
sudo nmcli con mod bond-bond0 ipv4.gateway 192.168.1.1
sudo nmcli con mod bond-bond0 ipv4.method manual

# Add slave interfaces
sudo nmcli con add type ethernet ifname eth0 master bond0
sudo nmcli con add type ethernet ifname eth1 master bond0

# Activate
sudo nmcli con up bond-bond0
sudo nmcli con up bond-slave-eth0
sudo nmcli con up bond-slave-eth1
```

**Verify**:
```bash
nmcli device status
nmcli con show
cat /proc/net/bonding/bond0
```

### 1.5 Configure Bonding (Netplan - Ubuntu)

**Config**: `/etc/netplan/01-netcfg.yaml`
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
    eth1:
      dhcp4: no
  bonds:
    bond0:
      dhcp4: no
      interfaces:
        - eth0
        - eth1
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
      parameters:
        mode: active-backup         # or 802.3ad
        mii-monitor-interval: 100   # Link monitoring (ms)
```

**Apply**:
```bash
sudo netplan try                # Test (auto-revert in 120s)
sudo netplan apply              # Permanent
```

### 1.6 Configure LACP on Switch

**For mode 4 (802.3ad)**:

**Cisco switch example**:
```
interface Port-channel1
 switchport mode trunk
 switchport trunk allowed vlan all

interface GigabitEthernet1/0/1
 switchport mode trunk
 channel-group 1 mode active

interface GigabitEthernet1/0/2
 switchport mode trunk
 channel-group 1 mode active
```

**HPE/Aruba**:
```
trunk 1 trk1 lacp
```

---

## 2. Network Bridging

### 2.1 What is a Network Bridge?

**Bridge**:
- Layer 2 (Ethernet) virtual switch
- Connects multiple network segments
- Common for VMs and containers
- VM traffic passes through bridge to physical network

**Use cases**:
- **KVM/libvirt**: VMs on same network as host
- **Docker**: Container networking
- **LXC**: Linux containers

### 2.2 Create Bridge (Manual)

**Using ip and brctl**:
```bash
# Install bridge-utils
sudo apt install bridge-utils

# Create bridge
sudo ip link add name br0 type bridge

# Add physical interface to bridge
sudo ip link set eth0 master br0

# Bring up
sudo ip link set br0 up
sudo ip link set eth0 up

# Assign IP to bridge (NOT eth0)
sudo ip addr add 192.168.1.100/24 dev br0
sudo ip route add default via 192.168.1.1
```

**Verify**:
```bash
bridge link show                    # Show bridge ports
ip link show br0
brctl show                          # Legacy command
```

### 2.3 Create Bridge (NetworkManager)

```bash
# Create bridge
sudo nmcli con add type bridge ifname br0

# Configure IP
sudo nmcli con mod bridge-br0 ipv4.addresses 192.168.1.100/24
sudo nmcli con mod bridge-br0 ipv4.gateway 192.168.1.1
sudo nmcli con mod bridge-br0 ipv4.method manual

# Add slave interface
sudo nmcli con add type ethernet ifname eth0 master br0

# Activate
sudo nmcli con up bridge-br0
```

### 2.4 Create Bridge (Netplan - Ubuntu)

**/etc/netplan/01-netcfg.yaml**:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
  bridges:
    br0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
      interfaces:
        - eth0
      parameters:
        stp: true                   # Spanning Tree Protocol
        forward-delay: 4            # STP forward delay
```

**Apply**:
```bash
sudo netplan apply
```

### 2.5 Bridge for KVM/libvirt

**Scenario**: VMs need direct access to LAN

**Create bridge with virsh**:
```bash
# Define bridge network XML
cat > /tmp/bridge.xml << EOF
<network>
  <name>br0</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

# Define and start
sudo virsh net-define /tmp/bridge.xml
sudo virsh net-start br0
sudo virsh net-autostart br0
```

**Use in VM**:
```bash
# Create VM with bridge network
virt-install \
  --name myvm \
  --network bridge=br0 \
  ...
```

**libvirt default bridge** (`virbr0`):
- Created automatically by libvirt
- NAT mode (VMs can access internet, not visible to LAN)
- Subnet: 192.168.122.0/24

---

## 3. Static Routing

### 3.1 Basic Routing Concepts

**Routing table**: Determines where to send packets

**View routing table**:
```bash
ip route show                       # Modern
route -n                            # Legacy

# Example output:
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
10.0.0.0/24 via 192.168.1.254 dev eth0
```

**Route types**:
- **Default route**: Catch-all (0.0.0.0/0)
- **Network route**: Specific subnet
- **Host route**: Single IP (/32)

### 3.2 Add Static Routes

**Temporary** (lost on reboot):
```bash
# Add route to 10.0.0.0/24 via gateway 192.168.1.254
sudo ip route add 10.0.0.0/24 via 192.168.1.254 dev eth0

# Add default route
sudo ip route add default via 192.168.1.1 dev eth0

# Delete route
sudo ip route del 10.0.0.0/24 via 192.168.1.254
```

**Persistent routes** – depends on distro:

**Method 1: NetworkManager** (RHEL/CentOS/Fedora):
```bash
sudo nmcli con mod eth0 +ipv4.routes "10.0.0.0/24 192.168.1.254"
sudo nmcli con up eth0
```

**Method 2: Debian/Ubuntu traditional**:

Create `/etc/network/interfaces.d/routes`:
```bash
up ip route add 10.0.0.0/24 via 192.168.1.254 dev eth0
down ip route del 10.0.0.0/24 via 192.168.1.254 dev eth0
```

**Method 3: Netplan (Ubuntu 18.04+)**:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: 10.0.0.0/24
          via: 192.168.1.254
        - to: 0.0.0.0/0              # Default route
          via: 192.168.1.1
```

**Method 4: RHEL/CentOS (legacy)**:

Create `/etc/sysconfig/network-scripts/route-eth0`:
```bash
10.0.0.0/24 via 192.168.1.254
```

### 3.3 Multi-Path Routing

**Load balancing across multiple gateways**:
```bash
# Two gateways with equal weight
sudo ip route add default \
  nexthop via 192.168.1.1 dev eth0 weight 1 \
  nexthop via 192.168.2.1 dev eth1 weight 1

# Unequal load balancing (2:1 ratio)
sudo ip route add default \
  nexthop via 192.168.1.1 weight 2 \
  nexthop via 192.168.2.1 weight 1
```

### 3.4 Policy-Based Routing

**Route based on source IP**:

**Example**: Traffic from 10.10.10.0/24 uses different gateway

```bash
# Create routing table
echo "200 custom" | sudo tee -a /etc/iproute2/rt_tables

# Add rule
sudo ip rule add from 10.10.10.0/24 table custom

# Add route to custom table
sudo ip route add default via 192.168.2.1 dev eth1 table custom

# Verify
ip rule show
ip route show table custom
```

### 3.5 Enable IP Forwarding

**Required** if Linux box acts as router:

**Temporary**:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

**Permanent** `/etc/sysctl.conf`:
```bash
net.ipv4.ip_forward = 1

# Apply
sudo sysctl -p
```

**Verify**:
```bash
cat /proc/sys/net/ipv4/ip_forward
# Output: 1 (enabled)
```

---

## 4. NAT and Port Forwarding

### 4.1 NAT Overview

**NAT (Network Address Translation)**:
- Translates private IPs to public IP
- Allows multiple devices to share one public IP
- Types:
  - **SNAT**: Source NAT (outbound traffic)
  - **DNAT**: Destination NAT (inbound traffic / port forwarding)
  - **Masquerade**: Dynamic SNAT for DHCP interfaces

### 4.2 SNAT/Masquerade (Internet Sharing)

**Scenario**: Share internet from eth0 (internet) to eth1 (LAN)

**Step 1: Enable IP forwarding** (see above)

**Step 2: Configure iptables**:
```bash
# Masquerade (for DHCP/dynamic IP)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Or SNAT (for static public IP)
sudo iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 203.0.113.5
```

**Step 3: Allow forwarding**:
```bash
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

**Save rules** (Debian/Ubuntu):
```bash
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

### 4.3 DNAT (Port Forwarding)

**Scenario**: Forward external port 8080 to internal server 192.168.1.10:80

```bash
# DNAT rule (translate destination)
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 \
  -j DNAT --to-destination 192.168.1.10:80

# Allow forwarding
sudo iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 80 \
  -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
```

**Port forwarding multiple ports**:
```bash
# Forward range 8000-8100
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8000:8100 \
  -j DNAT --to-destination 192.168.1.10

# Forward SSH (22) to different port
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2222 \
  -j DNAT --to-destination 192.168.1.10:22
```

### 4.4 NAT with nftables

**Modern alternative**:
```bash
# Enable forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# nftables config
sudo nft add table nat
sudo nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
sudo nft add chain nat prerouting { type nat hook prerouting priority -100 \; }

# Masquerade
sudo nft add rule nat postrouting oifname "eth0" masquerade

# Port forwarding
sudo nft add rule nat prerouting iifname "eth0" tcp dport 8080 \
  dnat to 192.168.1.10:80
```

---

## 5. IPv6 Configuration

### 5.1 IPv6 Basics

**Address types**:
- **Link-local**: `fe80::/10` (auto-configured, local segment only)
- **Unique local**: `fc00::/7` (private, like 192.168.x.x)
- **Global unicast**: `2000::/3` (public internet)
- **Loopback**: `::1` (like 127.0.0.1)

**Notation**:
- Full: `2001:0db8:0000:0000:0000:ff00:0042:8329`
- Compressed: `2001:db8::ff00:42:8329`

### 5.2 Configure IPv6

**View IPv6 addresses**:
```bash
ip -6 addr show
```

**Add IPv6 address**:
```bash
sudo ip -6 addr add 2001:db8::100/64 dev eth0
```

**IPv6 routing**:
```bash
# View routes
ip -6 route show

# Add route
sudo ip -6 route add 2001:db8:1::/64 via 2001:db8::1 dev eth0

# Default route
sudo ip -6 route add default via fe80::1 dev eth0
```

**Netplan IPv6**:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 2001:db8::100/64
        - 192.168.1.100/24
      gateway6: fe80::1
      gateway4: 192.168.1.1
```

### 5.3 IPv6 Firewall

**ip6tables** (separate from iptables):
```bash
# Allow ICMPv6 (required for IPv6)
sudo ip6tables -A INPUT -p ipv6-icmp -j ACCEPT

# Allow SSH
sudo ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

# Drop everything else
sudo ip6tables -P INPUT DROP
```

**Save IPv6 rules**:
```bash
sudo ip6tables-save > /etc/iptables/rules.v6
```

### 5.4 Disable IPv6 (if needed)

**Temporary**:
```bash
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
```

**Permanent** `/etc/sysctl.conf`:
```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

---

## 6. Reverse Proxy and Load Balancing

### 6.1 Nginx as Reverse Proxy

**Reverse proxy**: Frontend server forwards requests to backend servers

**Basic reverse proxy config**:
```nginx
# /etc/nginx/sites-available/myapp
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Enable and test**:
```bash
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 6.2 Nginx Load Balancing

**Upstream backend servers**:
```nginx
upstream backend {
    server 192.168.1.10:8000;
    server 192.168.1.11:8000;
    server 192.168.1.12:8000;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
    }
}
```

**Load balancing methods**:
```nginx
# Round-robin (default)
upstream backend {
    server 192.168.1.10:8000;
    server 192.168.1.11:8000;
}

# Least connections
upstream backend {
    least_conn;
    server 192.168.1.10:8000;
    server 192.168.1.11:8000;
}

# IP hash (sticky sessions)
upstream backend {
    ip_hash;
    server 192.168.1.10:8000;
    server 192.168.1.11:8000;
}

# Weighted
upstream backend {
    server 192.168.1.10:8000 weight=3;
    server 192.168.1.11:8000 weight=1;  # Gets 1/4 of traffic
}
```

**Health checks**:
```nginx
upstream backend {
    server 192.168.1.10:8000 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:8000 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:8000 backup;    # Only used if others fail
}
```

### 6.3 HAProxy Load Balancer

**HAProxy**: Dedicated high-performance load balancer

**Installation**:
```bash
sudo apt install haproxy
```

**Basic config** `/etc/haproxy/haproxy.cfg`:
```haproxy
global
    log /dev/log local0
    maxconn 4096

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms

frontend http-in
    bind *:80
    default_backend servers

backend servers
    balance roundrobin
    option httpchk GET /health
    server web1 192.168.1.10:8000 check
    server web2 192.168.1.11:8000 check
    server web3 192.168.1.12:8000 check
```

**Enable and start**:
```bash
sudo systemctl enable haproxy
sudo systemctl start haproxy
```

**HAProxy statistics**:
```haproxy
# Add to haproxy.cfg
frontend stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE

# Access at http://server:8404/stats
```

**Load balancing algorithms**:
```haproxy
# Round-robin
balance roundrobin

# Least connections
balance leastconn

# Source IP (sticky)
balance source

# URI hashing
balance uri
```

**SSL termination**:
```haproxy
frontend https-in
    bind *:443 ssl crt /etc/ssl/certs/mycert.pem
    default_backend servers

backend servers
    balance roundrobin
    server web1 192.168.1.10:80 check
```

---

## 7. Practice Exercises

1. **Network Bonding**:
   - Create bond0 with mode 1 (active-backup)
   - Add two network interfaces
   - Test failover by unplugging one cable

2. **Bridging**:
   - Create br0 and add eth0
   - Create KVM VM using bridge
   - Verify VM has LAN connectivity

3. **Static Routing**:
   - Add route to 10.0.0.0/24 via specific gateway
   - Make persistent across reboots
   - Test with ping/traceroute

4. **NAT**:
   - Configure masquerading for internet sharing
   - Set up port forwarding for SSH (2222→22)
   - Test from external network

5. **Nginx Reverse Proxy**:
   - Set up Nginx to proxy to local app on port 3000
   - Configure load balancing to 2 backend servers
   - Test with curl

6. **HAProxy**:
   - Install HAProxy
   - Configure backend pool with 3 web servers
   - Enable statistics page
   - Test health checks by stopping one backend

---

## 8. Key Takeaways

✅ **Bonding** provides redundancy (mode 1) or load balancing (mode 4/LACP)  
✅ **Bridges** connect VMs/containers to physical network (layer 2)  
✅ **Static routes** direct traffic to specific networks via gateways  
✅ **NAT/Masquerade** allows internet sharing with private networks  
✅ **DNAT** enables port forwarding from external to internal hosts  
✅ **IPv6** uses 128-bit addresses with different notation and routing  
✅ **Nginx upstream** provides simple HTTP load balancing  
✅ **HAProxy** offers advanced load balancing with health checks and stats  
✅ **Reverse proxy** hides backend servers and provides SSL termination  

---

**Next**: You've completed all advanced networking topics! Return to [linux-index.md](linux-index.md) to review other topics.

**Previous**: [linux-23-advanced-sysadmin.md](linux-23-advanced-sysadmin.md) for autofs, LDAP, time sync, and SSL.
