# Linux 28 – Samba & File Sharing Services

## 0. Goal of This Note

- Install and configure Samba for Windows file sharing
- Set up secure file sharing with proper permissions
- Configure advanced NFS (Network File System)
- Implement FTP/SFTP file transfer services
- Manage cross-platform file sharing
- Troubleshoot common file sharing issues

---

## 1. Samba (SMB/CIFS File Sharing)

### 1.1 What is Samba?

**Samba** implements SMB/CIFS protocol to share files between Linux and Windows systems.

**Use cases:**
- Share Linux directories with Windows clients
- Linux workstations accessing Windows shares
- Print sharing between Linux and Windows
- Active Directory integration
- Home directory sharing

**Protocol versions:**
- **SMB1**: Legacy, insecure (avoid)
- **SMB2**: Windows Vista+
- **SMB3**: Windows 8+, encrypted, recommended

### 1.2 Samba Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install samba samba-common-bin smbclient cifs-utils

# Check Samba version
smbd --version

# Check service status
sudo systemctl status smbd
sudo systemctl status nmbd
```

**RHEL/CentOS/Rocky:**
```bash
sudo dnf install samba samba-common samba-client cifs-utils

sudo systemctl start smb
sudo systemctl start nmb
sudo systemctl enable smb
sudo systemctl enable nmb

# Firewall rules
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload
```

### 1.3 Basic Samba Configuration

**Main config file:** `/etc/samba/smb.conf`

```bash
# Backup original
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Edit config
sudo nano /etc/samba/smb.conf
```

**Basic smb.conf:**
```ini
# /etc/samba/smb.conf

[global]
   workgroup = WORKGROUP
   server string = Samba Server %v
   netbios name = FILESERVER
   security = user
   map to guest = bad user
   dns proxy = no
   # Disable SMB1 (security)
   min protocol = SMB2
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   log level = 1

# Public share (no authentication)
[Public]
   comment = Public shared folder
   path = /srv/samba/public
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
   create mask = 0775
   directory mask = 0775

# Private share (authenticated users)
[Private]
   comment = Private shared folder
   path = /srv/samba/private
   valid users = @smbgroup
   browseable = yes
   writable = yes
   read only = no
   create mask = 0770
   directory mask = 0770
```

**Create shared directories:**
```bash
# Create directories
sudo mkdir -p /srv/samba/public
sudo mkdir -p /srv/samba/private

# Set permissions
sudo chmod 777 /srv/samba/public
sudo chown -R root:smbgroup /srv/samba/private
sudo chmod 770 /srv/samba/private

# SELinux context (if applicable)
sudo semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"
sudo restorecon -Rv /srv/samba
```

**Verify configuration:**
```bash
# Test configuration syntax
testparm

# Test with verbose output
testparm -v
```

**Restart Samba:**
```bash
sudo systemctl restart smbd
sudo systemctl restart nmbd

# Or on RHEL
sudo systemctl restart smb
sudo systemctl restart nmb
```

### 1.4 Samba Users

**Samba uses separate password database from Linux.**

```bash
# Create Linux user first
sudo useradd -M -s /sbin/nologin smbuser

# Create Samba password for user
sudo smbpasswd -a smbuser
# Enter password

# Enable Samba user
sudo smbpasswd -e smbuser

# Disable Samba user
sudo smbpasswd -d smbuser

# Delete Samba user
sudo smbpasswd -x smbuser

# List Samba users
sudo pdbedit -L
sudo pdbedit -L -v          # verbose

# Create group for Samba users
sudo groupadd smbgroup
sudo usermod -aG smbgroup smbuser
```

### 1.5 Advanced Share Examples

**Home directories:**
```ini
[homes]
   comment = Home Directories
   browseable = no
   valid users = %S
   writable = yes
   create mask = 0700
   directory mask = 0700
```

**Read-only share:**
```ini
[Documents]
   comment = Document Library
   path = /srv/samba/docs
   valid users = @docusers
   browseable = yes
   writable = no
   read only = yes
```

**User-specific share:**
```ini
[JohnShare]
   comment = John's private share
   path = /home/john/share
   valid users = john
   writable = yes
   browseable = no
   create mask = 0600
   directory mask = 0700
```

**Group share:**
```ini
[TeamShare]
   comment = Team collaboration folder
   path = /srv/samba/team
   valid users = @teamgroup
   write list = @teamgroup
   read list = @teamgroup
   force group = teamgroup
   create mask = 0660
   directory mask = 0770
   browseable = yes
```

**Hide dot files (Unix hidden files):**
```ini
[Share]
   path = /srv/samba/share
   hide dot files = yes
   veto files = /.*/Thumbs.db/.DS_Store/
```

### 1.6 Accessing Samba Shares

**From Linux (command line):**
```bash
# List shares
smbclient -L //server -U username

# Connect to share
smbclient //server/sharename -U username

# Inside smbclient
smb: \> ls
smb: \> get filename
smb: \> put filename
smb: \> cd directory
smb: \> quit
```

**Mount Samba share (Linux):**
```bash
# Install cifs-utils
sudo apt install cifs-utils

# Mount temporarily
sudo mount -t cifs //server/sharename /mnt/share -o username=user,password=pass

# Better: use credentials file
echo "username=myuser" > ~/.smbcredentials
echo "password=mypass" >> ~/.smbcredentials
chmod 600 ~/.smbcredentials

sudo mount -t cifs //server/sharename /mnt/share -o credentials=/home/user/.smbcredentials

# Mount permanently (fstab)
sudo nano /etc/fstab
```

```
//server/sharename /mnt/share cifs credentials=/home/user/.smbcredentials,uid=1000,gid=1000 0 0
```

**From Windows:**
```
1. Open File Explorer
2. Right-click "This PC" → "Map network drive"
3. Enter: \\server\sharename
4. Enter credentials
```

**From macOS:**
```
1. Finder → Go → Connect to Server
2. Enter: smb://server/sharename
3. Enter credentials
```

### 1.7 Samba Security

**Authentication modes:**
```ini
[global]
   # User-level security (recommended)
   security = user
   
   # Active Directory integration
   # security = ads
   # realm = EXAMPLE.COM
```

**Restrict by IP:**
```ini
[Share]
   path = /srv/samba/share
   hosts allow = 192.168.1. 192.168.2.0/24
   hosts deny = ALL
```

**Encrypt connections (SMB3):**
```ini
[global]
   server min protocol = SMB3
   smb encrypt = required
```

**Audit logging:**
```ini
[global]
   full_audit:prefix = %u|%I|%m|%S
   full_audit:success = open opendir
   full_audit:failure = all
   full_audit:facility = local5
   full_audit:priority = notice
   
[Share]
   vfs objects = full_audit
```

### 1.8 Troubleshooting Samba

```bash
# Check Samba status
sudo systemctl status smbd nmbd

# Test configuration
testparm

# View Samba logs
sudo tail -f /var/log/samba/log.smbd
sudo tail -f /var/log/samba/log.nmbd

# List active connections
sudo smbstatus

# List shares
smbclient -L localhost -N

# Test connectivity from client
smbclient //server/share -U username

# Check firewall
sudo ufw status
sudo firewall-cmd --list-services

# Netstat check
sudo netstat -tlnp | grep -E '139|445'

# SELinux issues (RHEL)
sudo getsebool -a | grep samba
sudo setsebool -P samba_enable_home_dirs on
sudo setsebool -P samba_export_all_rw on
```

---

## 2. NFS (Network File System)

### 2.1 NFS Overview

**NFS** is native Linux/Unix network file system protocol.

**NFS versions:**
- **NFSv3**: Traditional, UDP/TCP
- **NFSv4**: Modern, TCP only, better security, recommended

**Use cases:**
- Share files between Linux servers
- Centralized storage
- Home directories over network
- Shared application data

### 2.2 NFS Server Setup

**Install NFS server:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nfs-kernel-server

# RHEL/CentOS
sudo dnf install nfs-utils

# Start NFS
sudo systemctl start nfs-server
sudo systemctl enable nfs-server

# Check status
sudo systemctl status nfs-server
```

**Configure exports:**
```bash
# Edit exports file
sudo nano /etc/exports
```

**Basic /etc/exports:**
```bash
# Syntax: directory client(options)

# Share with specific host
/srv/nfs/data 192.168.1.100(rw,sync,no_subtree_check)

# Share with subnet
/srv/nfs/public 192.168.1.0/24(ro,sync,no_subtree_check)

# Share with multiple clients
/srv/nfs/share 192.168.1.100(rw) 192.168.1.101(rw)

# Share with wildcard
/srv/nfs/backup *.example.com(rw,sync,no_subtree_check)

# Public share (read-only)
/srv/nfs/public *(ro,sync,no_subtree_check)
```

**Common export options:**
```bash
rw              # read-write
ro              # read-only
sync            # synchronous writes (safer, slower)
async           # asynchronous writes (faster, data loss risk)
no_subtree_check # disable subtree checking (faster)
no_root_squash  # root on client = root on server (dangerous!)
root_squash     # root on client = nobody on server (default, safer)
all_squash      # all users mapped to anonymous
anonuid=1000    # map anonymous to specific UID
anongid=1000    # map anonymous to specific GID
```

**Create and prepare directories:**
```bash
# Create NFS share directories
sudo mkdir -p /srv/nfs/data
sudo mkdir -p /srv/nfs/public

# Set permissions
sudo chown nobody:nogroup /srv/nfs/data
sudo chmod 755 /srv/nfs/data

# Apply exports
sudo exportfs -arv

# List active exports
sudo exportfs -v

# Restart NFS
sudo systemctl restart nfs-server
```

**Firewall configuration:**
```bash
# Ubuntu (ufw)
sudo ufw allow from 192.168.1.0/24 to any port nfs

# RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload
```

### 2.3 NFS Client Setup

**Install NFS client:**
```bash
# Ubuntu/Debian
sudo apt install nfs-common

# RHEL/CentOS
sudo dnf install nfs-utils
```

**Mount NFS share:**
```bash
# Show available exports from server
showmount -e 192.168.1.10

# Create mount point
sudo mkdir -p /mnt/nfs-data

# Mount temporarily
sudo mount -t nfs 192.168.1.10:/srv/nfs/data /mnt/nfs-data

# Verify
df -h | grep nfs
mount | grep nfs

# Mount with options
sudo mount -t nfs -o rw,soft,intr 192.168.1.10:/srv/nfs/data /mnt/nfs-data
```

**Mount permanently (fstab):**
```bash
sudo nano /etc/fstab
```

```
# NFS mounts
192.168.1.10:/srv/nfs/data /mnt/nfs-data nfs defaults,_netdev 0 0
192.168.1.10:/srv/nfs/public /mnt/nfs-public nfs ro,_netdev 0 0

# With options
192.168.1.10:/srv/nfs/data /mnt/nfs-data nfs rw,soft,intr,rsize=8192,wsize=8192,timeo=14,_netdev 0 0
```

**Mount options:**
```bash
rw/ro           # read-write / read-only
soft            # return error on timeout (vs hard = retry forever)
hard            # retry forever on timeout (default)
intr            # allow interrupting operations
timeo=14        # timeout in deciseconds
retrans=3       # number of retries
rsize=8192      # read buffer size
wsize=8192      # write buffer size
_netdev         # wait for network before mounting
```

**Auto-mount with autofs:**
```bash
# Install autofs
sudo apt install autofs

# Configure master map
sudo nano /etc/auto.master
```

```
/mnt/nfs /etc/auto.nfs --timeout=60
```

```bash
# Configure NFS map
sudo nano /etc/auto.nfs
```

```
data -rw,soft,intr 192.168.1.10:/srv/nfs/data
public -ro 192.168.1.10:/srv/nfs/public
```

```bash
# Restart autofs
sudo systemctl restart autofs

# Access will auto-mount
cd /mnt/nfs/data
ls /mnt/nfs/public
```

### 2.4 NFS Security

**NFSv4 with Kerberos:**
```bash
# On server
sudo apt install nfs-kernel-server krb5-user

# Configure /etc/exports with sec=krb5
/srv/nfs/secure 192.168.1.0/24(rw,sync,sec=krb5)

# Security flavors:
# sec=sys      - standard Unix (default, least secure)
# sec=krb5     - Kerberos authentication only
# sec=krb5i    - Kerberos + integrity checking
# sec=krb5p    - Kerberos + privacy (encryption)
```

**IP restrictions:**
```bash
# Allow specific hosts only
/srv/nfs/data 192.168.1.100(rw) 192.168.1.101(rw)

# Deny all others (default)
```

**Read-only exports:**
```bash
# Prevent writes
/srv/nfs/public *(ro,sync,no_subtree_check)
```

### 2.5 NFS Troubleshooting

```bash
# Check NFS service
sudo systemctl status nfs-server

# Check what's exported
sudo exportfs -v

# Show mounted NFS shares (client)
mount | grep nfs
df -h | grep nfs

# Check server availability (client)
showmount -e server-ip

# Check NFS ports
sudo netstat -tlnp | grep -E 'nfs|mountd|rpc'

# Test mount manually
sudo mount -t nfs -v server:/export /mnt/test

# Check RPC services
rpcinfo -p localhost

# NFS logs
sudo journalctl -u nfs-server
sudo tail -f /var/log/syslog | grep nfs

# Unmount stuck NFS mount
sudo umount -f /mnt/nfs-data
sudo umount -l /mnt/nfs-data      # lazy unmount
```

---

## 3. FTP/SFTP Services

### 3.1 SFTP (Secure FTP)

**SFTP is built into OpenSSH** (no extra software needed).

**Configure SFTP chroot (jail users):**
```bash
sudo nano /etc/ssh/sshd_config
```

```
# SFTP subsystem (already exists)
Subsystem sftp /usr/lib/openssh/sftp-server

# Chroot SFTP users
Match Group sftpusers
    ChrootDirectory /srv/sftp/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

```bash
# Create SFTP group and user
sudo groupadd sftpusers
sudo useradd -m -G sftpusers -s /sbin/nologin sftpuser

# Create chroot directory structure
sudo mkdir -p /srv/sftp/sftpuser/upload
sudo chown root:root /srv/sftp/sftpuser
sudo chmod 755 /srv/sftp/sftpuser
sudo chown sftpuser:sftpusers /srv/sftp/sftpuser/upload

# Set password
sudo passwd sftpuser

# Restart SSH
sudo systemctl restart sshd
```

**Connect with SFTP:**
```bash
# Command line
sftp sftpuser@server

# Inside sftp
sftp> ls
sftp> cd upload
sftp> put localfile
sftp> get remotefile
sftp> quit

# With FileZilla or WinSCP (GUI)
# Protocol: SFTP
# Host: server IP
# Port: 22
# Username: sftpuser
# Password: ***
```

### 3.2 vsftpd (FTP Server)

**Install vsftpd:**
```bash
sudo apt install vsftpd

sudo systemctl start vsftpd
sudo systemctl enable vsftpd
```

**Configure vsftpd:**
```bash
sudo nano /etc/vsftpd.conf
```

```ini
# Basic settings
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES

# Security
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd

# SSL/TLS
ssl_enable=YES
rsa_cert_file=/etc/ssl/certs/vsftpd.crt
rsa_private_key_file=/etc/ssl/private/vsftpd.key
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

# Passive mode
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=YOUR_PUBLIC_IP
```

```bash
# Restart vsftpd
sudo systemctl restart vsftpd

# Firewall
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp
```

---

## 4. Practice Exercises

1. **Samba Setup:**
   - Install Samba
   - Create public and private shares
   - Add Samba users
   - Test from Windows client

2. **NFS Configuration:**
   - Set up NFS server
   - Export multiple directories
   - Mount from NFS client
   - Configure autofs

3. **Cross-platform Sharing:**
   - Share same directory via Samba and NFS
   - Configure appropriate permissions
   - Test from both Windows and Linux

4. **SFTP Jail:**
   - Create chrooted SFTP users
   - Test file upload/download
   - Verify users cannot escape jail

5. **Secure File Sharing:**
   - Configure Samba with encryption
   - Set up NFS with Kerberos
   - Implement access controls
   - Audit file access

---

Next: **Linux 29 – Advanced Security** (LUKS, VPN, security auditing) - the final file!
