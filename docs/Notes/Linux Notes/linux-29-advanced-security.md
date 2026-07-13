# Linux 29 – Advanced Security (LUKS, VPN, Auditing & Vulnerability Scanning)

## 0. Goal of This Note

- Implement disk encryption with LUKS
- Set up secure VPNs (OpenVPN, WireGuard)
- Perform security auditing and compliance scanning
- Conduct vulnerability assessments
- Monitor and analyze security logs
- Implement intrusion detection systems
- **Perfect for PSIRT and security professionals**

---

## 1. LUKS Disk Encryption

### 1.1 LUKS Overview

**LUKS** (Linux Unified Key Setup) provides full disk encryption.

**Use cases:**
- Encrypt sensitive data at rest
- Protect laptop hard drives
- Secure cloud instance volumes
- Comply with data protection regulations
- Prevent unauthorized data access

**Features:**
- AES encryption
- Multiple key slots (up to 8 passwords)
- Header backup/restore
- Key derivation with PBKDF2

### 1.2 Creating Encrypted Partition

**Install cryptsetup:**
```bash
sudo apt install cryptsetup           # Ubuntu
sudo dnf install cryptsetup-luks      # RHEL
```

**Create encrypted partition:**
```bash
# WARNING: This will destroy all data on the partition!

# List partitions
lsblk
sudo fdisk -l

# Encrypt partition (e.g., /dev/sdb1)
sudo cryptsetup luksFormat /dev/sdb1

# Confirm with YES (uppercase)
# Enter passphrase (strong password)

# Verify LUKS header
sudo cryptsetup luksDump /dev/sdb1
```

**Open encrypted partition:**
```bash
# Open and map to /dev/mapper/encrypted
sudo cryptsetup luksOpen /dev/sdb1 encrypted

# Verify
ls -l /dev/mapper/encrypted

# Create filesystem
sudo mkfs.ext4 /dev/mapper/encrypted

# Mount
sudo mkdir /mnt/encrypted
sudo mount /dev/mapper/encrypted /mnt/encrypted

# Use normally
sudo touch /mnt/encrypted/secret.txt
```

**Close encrypted partition:**
```bash
# Unmount
sudo umount /mnt/encrypted

# Close LUKS device
sudo cryptsetup luksClose encrypted
```

### 1.3 Auto-mount Encrypted Partition

**Using /etc/crypttab and /etc/fstab:**

```bash
# Get UUID of encrypted partition
sudo blkid /dev/sdb1
# Note the UUID

# Edit crypttab
sudo nano /etc/crypttab
```

```
# name  device                           key      options
encrypted  UUID=YOUR-UUID-HERE            none     luks
```

```bash
# Edit fstab
sudo nano /etc/fstab
```

```
/dev/mapper/encrypted  /mnt/encrypted  ext4  defaults  0  2
```

**With key file (automatic unlock):**
```bash
# Generate key file
sudo dd if=/dev/urandom of=/root/luks-key bs=512 count=8
sudo chmod 400 /root/luks-key

# Add key to LUKS
sudo cryptsetup luksAddKey /dev/sdb1 /root/luks-key

# Update crypttab
sudo nano /etc/crypttab
```

```
encrypted  UUID=YOUR-UUID-HERE  /root/luks-key  luks
```

**Security note:** Key file on same disk reduces security. Better: USB key, TPM, or network key server.

### 1.4 LUKS Management

**Add additional passphrase:**
```bash
sudo cryptsetup luksAddKey /dev/sdb1
# Enter existing passphrase
# Enter new passphrase
```

**Remove passphrase:**
```bash
sudo cryptsetup luksRemoveKey /dev/sdb1
# Enter passphrase to remove
```

**Change passphrase:**
```bash
sudo cryptsetup luksChangeKey /dev/sdb1
# Enter old passphrase
# Enter new passphrase
```

**Backup LUKS header:**
```bash
# Backup header
sudo cryptsetup luksHeaderBackup /dev/sdb1 --header-backup-file /root/luks-header-backup

# Secure the backup
sudo chmod 400 /root/luks-header-backup

# Restore header (if corrupted)
sudo cryptsetup luksHeaderRestore /dev/sdb1 --header-backup-file /root/luks-header-backup
```

**View key slots:**
```bash
sudo cryptsetup luksDump /dev/sdb1
```

---

## 2. VPN Configuration

### 2.1 OpenVPN

**Install OpenVPN server (Ubuntu):**
```bash
# Download setup script
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh

# Run installer
sudo ./openvpn-install.sh

# Follow prompts:
# - IP address (auto-detected)
# - Protocol (UDP recommended)
# - Port (1194 default)
# - DNS (1.1.1.1 recommended)
# - Client name

# Script creates:
# - /etc/openvpn/server.conf
# - Client config (.ovpn file in ~/)
```

**Manual OpenVPN setup:**
```bash
# Install
sudo apt install openvpn easy-rsa

# Set up CA
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Edit vars
nano vars
```

```bash
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="SanFrancisco"
export KEY_ORG="MyCompany"
export KEY_EMAIL="admin@example.com"
export KEY_OU="IT"
```

```bash
# Source vars
source vars

# Clean and build CA
./clean-all
./build-ca

# Build server cert
./build-key-server server

# Generate DH params
./build-dh

# Generate HMAC key
openvpn --genkey --secret keys/ta.key

# Copy to OpenVPN directory
sudo cp keys/{ca.crt,server.crt,server.key,dh2048.pem,ta.key} /etc/openvpn/
```

**Server config (/etc/openvpn/server.conf):**
```ini
port 1194
proto udp
dev tun

ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
tls-auth ta.key 0

server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt

push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"

keepalive 10 120
cipher AES-256-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun

status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
```

**Enable IP forwarding:**
```bash
sudo nano /etc/sysctl.conf
```

```
net.ipv4.ip_forward=1
```

```bash
sudo sysctl -p
```

**Firewall rules:**
```bash
# UFW
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

# NAT
sudo nano /etc/ufw/before.rules
```

```
# Add before *filter
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
```

```bash
# Restart UFW
sudo ufw disable
sudo ufw enable
```

**Start OpenVPN:**
```bash
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

# Check status
sudo systemctl status openvpn@server
```

**Create client config:**
```bash
# Generate client cert
cd ~/openvpn-ca
source vars
./build-key client1

# Create client.ovpn
```

```
client
dev tun
proto udp
remote YOUR_SERVER_IP 1194
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
tls-auth ta.key 1
cipher AES-256-CBC
auth SHA256
verb 3
```

**Connect client (Linux):**
```bash
sudo apt install openvpn
sudo openvpn --config client.ovpn
```

### 2.2 WireGuard (Modern VPN)

**WireGuard** is faster, simpler, and more secure than OpenVPN.

**Install WireGuard:**
```bash
# Ubuntu 20.04+
sudo apt install wireguard

# RHEL 8+
sudo dnf install wireguard-tools
```

**Generate keys (server):**
```bash
# Generate private key
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod 600 /etc/wireguard/private.key

# Generate public key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

**Server config (/etc/wireguard/wg0.conf):**
```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

# IP forwarding
PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1
[Peer]
PublicKey = CLIENT1_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32

# Client 2
[Peer]
PublicKey = CLIENT2_PUBLIC_KEY
AllowedIPs = 10.0.0.3/32
```

**Start WireGuard:**
```bash
# Start
sudo wg-quick up wg0

# Enable on boot
sudo systemctl enable wg-quick@wg0

# Check status
sudo wg show

# Stop
sudo wg-quick down wg0
```

**Client setup:**
```bash
# Generate client keys
wg genkey | tee client-private.key | wg pubkey > client-public.key

# Client config
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0  # Route all traffic through VPN
# AllowedIPs = 10.0.0.0/24  # Only VPN subnet
PersistentKeepalive = 25
```

```bash
# Connect
sudo wg-quick up wg0

# Check
sudo wg show
ping 10.0.0.1
```

**Firewall:**
```bash
sudo ufw allow 51820/udp
```

---

## 3. Security Auditing & Compliance

### 3.1 Lynis (Security Auditing Tool)

**Lynis** scans system for security issues.

**Install Lynis:**
```bash
# Ubuntu
sudo apt install lynis

# Or latest version
cd /opt
sudo git clone https://github.com/CISOfy/lynis
cd lynis

# Run audit
sudo ./lynis audit system
```

**Run Lynis audit:**
```bash
sudo lynis audit system

# Full report
sudo lynis audit system --verbose

# Specific tests
sudo lynis audit system --tests-from-group security

# Generate report
sudo lynis audit system --report-file /var/log/lynis-report.txt
```

**Lynis output sections:**
- System tools
- Boot and services
- Kernel
- Memory and processes
- Users, groups, authentication
- Shells
- File systems
- Storage
- NFS
- Software
- Ports and packages
- Networking
- Printers and spoolers
- Software: e-mail and messaging
- Software: firewalls
- Software: webserver
- SSH
- SNMP
- Databases
- LDAP
- Software: PHP
- Squid
- Logging and files
- Insecure services
- Banners and identification
- Scheduled tasks
- Accounting
- Time and synchronization
- Cryptography
- Virtualization
- Security frameworks
- Software: file integrity
- Software: malware scanners
- File permissions
- Home directories
- Kernel hardening
- Hardening

**Common recommendations:**
- Update packages
- Configure firewall
- Disable unnecessary services
- Harden SSH
- Enable SELinux/AppArmor
- Configure logging
- Set up file integrity monitoring

### 3.2 OpenSCAP (Compliance Scanning)

**OpenSCAP** automates compliance checking.

**Install OpenSCAP:**
```bash
# Ubuntu
sudo apt install libopenscap8 openscap-utils scap-security-guide

# RHEL
sudo dnf install openscap-scanner scap-security-guide
```

**Run compliance scan:**
```bash
# List available profiles
oscap info /usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml

# Run scan (Ubuntu)
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis \
    --results scan-results.xml \
    --report scan-report.html \
    /usr/share/xml/scap/ssg/content/ssg-ubuntu2004-ds.xml

# View HTML report
firefox scan-report.html

# RHEL scan
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_pci-dss \
    --results rhel-scan.xml \
    --report rhel-report.html \
    /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

**Common compliance profiles:**
- CIS Benchmarks
- PCI-DSS
- HIPAA
- DISA STIG
- NIST 800-53

### 3.3 AIDE (File Integrity Monitoring)

**AIDE** detects unauthorized file changes.

**Install AIDE:**
```bash
sudo apt install aide aide-common
```

**Initialize database:**
```bash
# Create baseline
sudo aideinit

# Move database
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

**Check for changes:**
```bash
# Run check
sudo aide --check

# Update database (after authorized changes)
sudo aide --update
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

**Configure AIDE:**
```bash
sudo nano /etc/aide/aide.conf
```

```
# Directories to monitor
/etc p+i+n+u+g+s+b+m+c+md5+sha1
/bin p+i+n+u+g+s+b+m+c+md5+sha1
/sbin p+i+n+u+g+s+b+m+c+md5+sha1
/usr/bin p+i+n+u+g+s+b+m+c+md5+sha1
/usr/sbin p+i+n+u+g+s+b+m+c+md5+sha1

# Exclude
!/var/log
!/tmp
!/proc
```

**Automate with cron:**
```bash
# Daily check
echo "0 5 * * * root /usr/bin/aide --check | mail -s 'AIDE Report' admin@example.com" | sudo tee -a /etc/crontab
```

---

## 4. Vulnerability Scanning

### 4.1 Nmap (Network Scanner)

**Advanced Nmap scans:**
```bash
# Vulnerability scan
sudo nmap -sV --script vuln 192.168.1.100

# Check for SMB vulnerabilities (EternalBlue, etc.)
sudo nmap --script smb-vuln* -p 445 192.168.1.100

# SSL/TLS vulnerabilities
sudo nmap --script ssl-enum-ciphers -p 443 192.168.1.100
sudo nmap --script ssl-heartbleed -p 443 192.168.1.100

# HTTP vulnerabilities
sudo nmap --script http-vuln* -p 80,443 192.168.1.100

# Brute force detection
sudo nmap --script ssh-brute -p 22 192.168.1.100
```

### 4.2 OpenVAS (Vulnerability Scanner)

**Install OpenVAS (now GVM - Greenbone Vulnerability Manager):**
```bash
# Ubuntu
sudo apt install openvas

# Initialize
sudo gvm-setup
sudo gvm-check-setup

# Start services
sudo gvm-start

# Get admin password
sudo runuser -u _gvm -- gvmd --user=admin --new-password=StrongPassword123!

# Access web interface
# https://localhost:9392
```

**Run vulnerability scan:**
1. Login to web interface
2. Configuration → Targets → New Target
3. Scans → Tasks → New Task
4. Select target and scan config
5. Start scan
6. View results when complete

### 4.3 Nikto (Web Scanner)

**Install Nikto:**
```bash
sudo apt install nikto
```

**Scan web server:**
```bash
# Basic scan
nikto -h http://example.com

# SSL scan
nikto -h https://example.com

# Scan specific port
nikto -h http://example.com -p 8080

# Save output
nikto -h http://example.com -o nikto-report.html -Format html

# Tuning options
nikto -h http://example.com -Tuning 1234
# 1: Interesting files
# 2: Misconfiguration
# 3: Information disclosure
# 4: Injection
```

---

## 5. Intrusion Detection

### 5.1 OSSEC (Host-based IDS)

**Install OSSEC:**
```bash
wget https://github.com/ossec/ossec-hids/archive/3.7.0.tar.gz
tar -xzf 3.7.0.tar.gz
cd ossec-hids-3.7.0

# Install
sudo ./install.sh

# Follow prompts:
# - Server/Agent/Local
# - Email notifications
# - Integrity check
# - Rootkit detection
# - Active response

# Start OSSEC
sudo /var/ossec/bin/ossec-control start

# Check status
sudo /var/ossec/bin/ossec-control status
```

**View alerts:**
```bash
sudo tail -f /var/ossec/logs/alerts/alerts.log
```

### 5.2 Fail2Ban (Brute Force Protection)

**Already covered in linux-07, advanced config:**

```bash
# Custom jail for application logs
sudo nano /etc/fail2ban/jail.local
```

```ini
[apache-auth]
enabled = true
port = http,https
logpath = /var/log/apache2/*error.log
maxretry = 3
bantime = 3600

[custom-app]
enabled = true
port = 8080
logpath = /var/log/app/error.log
maxretry = 5
findtime = 600
bantime = 7200
```

---

## 6. Log Analysis for Security

### 6.1 Centralized Logging

**rsyslog remote logging:**
```bash
# On log server
sudo nano /etc/rsyslog.conf
```

```
# Uncomment to enable UDP
$ModLoad imudp
$UDPServerRun 514

# Or TCP (more reliable)
$ModLoad imtcp
$InputTCPServerRun 514

# Store logs by hostname
$template RemoteLogs,"/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& stop
```

```bash
# On client
sudo nano /etc/rsyslog.conf
```

```
# Send to log server
*.* @@log-server:514   # TCP
# *.* @log-server:514  # UDP
```

### 6.2 Security Log Monitoring

**Monitor auth logs:**
```bash
# Failed logins
sudo grep "Failed password" /var/log/auth.log

# Successful logins
sudo grep "Accepted password" /var/log/auth.log

# sudo usage
sudo grep "sudo:" /var/log/auth.log

# New user additions
sudo grep "useradd" /var/log/auth.log
```

**Automated alert script:**
```bash
#!/bin/bash
# /usr/local/bin/security-monitor.sh

LOG="/var/log/auth.log"
ALERT_EMAIL="security@example.com"

# Check for failed logins
FAILED=$(grep "Failed password" $LOG | tail -n 100 | wc -l)

if [ $FAILED -gt 10 ]; then
    echo "WARNING: $FAILED failed login attempts detected" | \
        mail -s "Security Alert: Failed Logins" $ALERT_EMAIL
fi

# Check for new users
grep "useradd" $LOG | tail -n 10 | \
    mail -s "Security Alert: New User Account" $ALERT_EMAIL
```

---

## 7. Practice Exercises

1. **LUKS Encryption:**
   - Create encrypted partition
   - Set up auto-mount with key file
   - Test backup/restore of LUKS header
   - Implement encrypted backups

2. **VPN Setup:**
   - Deploy OpenVPN server
   - Create client configs
   - Test connectivity
   - Set up WireGuard for comparison

3. **Security Audit:**
   - Run Lynis audit
   - Fix top 10 recommendations
   - Run OpenSCAP compliance scan
   - Document findings

4. **Vulnerability Assessment:**
   - Scan network with Nmap
   - Run OpenVAS scan
   - Scan web apps with Nikto
   - Prioritize and remediate findings

5. **Intrusion Detection:**
   - Set up OSSEC
   - Configure custom rules
   - Test alert mechanisms
   - Integrate with SIEM

---

## 8. Security Best Practices for PSIRT Professionals

### 8.1 Security Hardening Checklist

```yaml
✓ Keep systems updated
✓ Minimize installed software
✓ Disable unnecessary services
✓ Configure strong firewalls
✓ Implement SELinux/AppArmor
✓ Use strong authentication (SSH keys, 2FA)
✓ Encrypt sensitive data (LUKS, SSL/TLS)
✓ Regular backups (encrypted, offsite)
✓ Monitor logs continuously
✓ Conduct regular vulnerability scans
✓ Implement intrusion detection
✓ Use security baselines (CIS, STIG)
✓ Practice principle of least privilege
✓ Document security configurations
✓ Conduct security audits
✓ Have incident response plan
```

### 8.2 Incident Response

**Basic IR workflow:**
1. **Preparation**: Tools ready, processes documented
2. **Identification**: Detect and verify incident
3. **Containment**: Isolate affected systems
4. **Eradication**: Remove threat
5. **Recovery**: Restore systems
6. **Lessons Learned**: Document and improve

**Forensic data collection:**
```bash
# Memory dump
sudo dd if=/dev/mem of=/forensics/memory.dump

# Network connections
sudo netstat -anp > /forensics/netstat.txt

# Running processes
sudo ps auxf > /forensics/processes.txt

# Open files
sudo lsof > /forensics/open-files.txt

# Login history
sudo last > /forensics/login-history.txt

# Create timeline
sudo find / -type f -mtime -1 > /forensics/modified-files.txt
```

---

**Congratulations!** You now have **complete expert-level Linux knowledge** covering fundamentals through advanced security topics relevant to your PSIRT career! 🎓🐧🔒
