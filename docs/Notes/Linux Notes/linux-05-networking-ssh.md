# Linux 05 – Networking & SSH

## 0. Goal of This Note

- Understand basic network concepts and tools.  
- Configure and inspect IP, routes, DNS.  
- Use SSH for remote login and file transfer.

---

## 1. Basic Network Concepts

- **IP address** – numerical address of a host (e.g., `192.168.1.10`).  
- **Netmask/prefix** – which part is network vs host (e.g., `/24`).  
- **Gateway** – where traffic goes to reach other networks.  
- **DNS** – converts names (google.com) to IP addresses.  
- **Port** – identifies a service on a host (e.g., 22 = SSH, 80 = HTTP).

---

## 2. Inspecting Network Configuration

### 2.1 Addresses & Interfaces

Modern command: `ip` (replaces  `ifconfig`).

```bash
ip a             # all interfaces & addresses
ip link          # link-layer info (up/down, MAC)
```

Look for:

- Interface name (e.g., `eth0`, `enp0s3`, `wlan0`).  
- `inet` line for IPv4 address.

### 2.2 Routes

```bash
ip r             # routing table
```

You’ll see default route and local networks, e.g.:

```text
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.10
```

---

## 3. Testing Connectivity

```bash
ping 8.8.8.8              # test reachability to Google DNS
ping google.com           # also tests DNS
```

Stop `ping` with `Ctrl + C`.

Traceroute (path to host):

```bash
traceroute google.com     # may need install
```

DNS lookups:

```bash
nslookup example.com
# or
dig example.com           # more detailed (may need install)
```

---

## 4. Inspecting Connections & Ports

Old tool: `netstat`. Newer: `ss`.

```bash
ss -tulnp
```

Options:

- `-t` – TCP.  
- `-u` – UDP.  
- `-l` – listening sockets.  
- `-n` – numeric (no name resolution).  
- `-p` – show process using the port.

Look for services like:

- `:22` – sshd.  
- `:80`, `:443` – web servers.

---

## 5. SSH – Secure Shell

### 5.1 Basic Login

```bash
ssh user@host
ssh user@192.168.1.10
ssh -p 2222 user@host    # non-default port
```

First connection shows a fingerprint; accept if you trust the host.

### 5.2 Key-Based Authentication

Generate key pair (modern):

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Accept default file (`~/.ssh/id_ed25519`), use a passphrase for better security.

Copy key to server:

```bash
ssh-copy-id user@host
```

This appends your public key to `~/.ssh/authorized_keys` on the server.

Then login without typing password (or only key passphrase if used).

### 5.3 SSH Client Config (~/.ssh/config)

Create `~/.ssh/config` for shortcuts:

```text
Host myserver
    HostName 203.0.113.10
    User alice
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

Then simply:

```bash
ssh myserver
```

---

## 6. Secure File Transfers

### 6.1 scp

```bash
scp file.txt user@host:/path/
scp -r dir/ user@host:/path/
scp user@host:/path/file.txt .
```

### 6.2 rsync over SSH

```bash
rsync -av file user@host:/path/
rsync -av user@host:/path/ localdir/
```

`rsync` is more flexible (resume, only changed blocks, etc.).

---

## 7. Basic Network Troubleshooting Flow

1. Check interface: `ip a` – do you have an IP?  
2. Check gateway: `ip r` – is there a default route?  
3. Ping gateway: `ping <gateway-ip>`.  
4. Ping external IP: `ping 8.8.8.8`.  
5. Test DNS: `ping google.com`, `nslookup google.com`.  
6. Check firewall (e.g., `ufw status`, `firewall-cmd --state`).

---

## 8. Practice Tasks

1. Inspect your network:
   - Find your IP address and interface name.  
   - Identify your default gateway.  
   - Check which ports are listening on your machine.
2. SSH:
   - If you have another Linux machine or a VM, enable `sshd` and connect via SSH.  
   - Set up key-based auth and disable password auth (on a test machine only).
3. File transfer:
   - Use `scp` to copy a file to the remote machine and back.  
   - Repeat with `rsync -av` and observe the difference when transferring a changed file.

Next: **Linux 06 – Bash Scripting & Automation**.
