# Linux 23 – Advanced System Administration (Autofs, LDAP, Time Sync, SSL)

## 0. Goal of This Note

- Master automatic filesystem mounting with autofs.
- Configure centralized authentication with LDAP (sssd).
- Synchronize system time with NTP/chrony.
- Manage SSL/TLS certificates with openssl and Let's Encrypt.
- Compare systemd timers vs traditional cron.

---

## 1. Autofs – Automatic Filesystem Mounting

### 1.1 Why Autofs?

**Traditional /etc/fstab mounting**:
- Mounts filesystems at boot
- Always mounted, consuming resources
- Failures at boot can prevent system startup
- No dynamic mounting/unmounting

**Autofs benefits**:
- **On-demand mounting**: Only when accessed
- **Automatic unmounting**: After idle timeout
- **No boot failures**: If remote server down, system still boots
- **Resource efficient**: Unmounts unused filesystems
- **User-friendly**: Transparent to users

**Common use cases**:
- NFS home directories
- Network file shares
- USB/removable media auto-mounting
- CD/DVD auto-mounting

### 1.2 Autofs Installation

```bash
# Debian/Ubuntu
sudo apt install autofs

# RHEL/CentOS/Fedora
sudo dnf install autofs

# Enable and start
sudo systemctl enable autofs
sudo systemctl start autofs
sudo systemctl status autofs
```

### 1.3 Autofs Configuration Files

**Main config**: `/etc/auto.master`
- Defines master mount points and map files

**Map files**: `/etc/auto.<name>`
- Define individual mounts under each master mount point

**Direct vs Indirect maps**:
- **Indirect**: Multiple mounts under one parent directory
- **Direct**: Mounts at absolute paths

### 1.4 Basic Autofs Setup – Indirect Map

**Scenario**: Auto-mount NFS shares under `/mnt/nfs`

**Step 1: Edit master map**
```bash
sudo vi /etc/auto.master

# Add line:
/mnt/nfs    /etc/auto.nfs    --timeout=60
#  │          │                └─ Unmount after 60s idle
#  │          └──────────────────── Map file
#  └─────────────────────────────── Base mount point
```

**Step 2: Create map file**
```bash
sudo vi /etc/auto.nfs

# Format: <mount-dir>  <options>  <server:/export/path>
data      -rw,soft,intr  nfsserver.example.com:/export/data
backups   -ro             nfsserver.example.com:/export/backups
home      -rw,soft       nfsserver.example.com:/export/home
```

**Step 3: Reload autofs**
```bash
sudo systemctl reload autofs
```

**Step 4: Access the mounts**
```bash
# Initially not mounted
df -h | grep /mnt/nfs
# (no output)

# Access triggers mount
cd /mnt/nfs/data
# Now mounted

df -h | grep /mnt/nfs
# nfsserver.example.com:/export/data  /mnt/nfs/data

# After 60s idle, auto-unmounts
```

### 1.5 Direct Map

**Use case**: Mount at absolute paths, not under common parent

**Edit /etc/auto.master**:
```bash
sudo vi /etc/auto.master

# Direct map indicator: /-
/-    /etc/auto.direct
```

**Create /etc/auto.direct**:
```bash
sudo vi /etc/auto.direct

# Absolute paths
/backups      -ro    nfsserver:/export/backups
/home/shared  -rw    nfsserver:/export/shared
/mnt/archive  -ro    192.168.1.100:/archives
```

**Reload and test**:
```bash
sudo systemctl reload autofs
ls /backups                         # Triggers mount at /backups
```

### 1.6 Wildcards and Substitution

**Scenario**: Auto-mount user home directories

**/etc/auto.master**:
```bash
/home    /etc/auto.home
```

**/etc/auto.home**:
```bash
# Wildcard substitution with &
*    -rw,soft    nfsserver:/export/home/&

# Example:
# User accesses /home/john
# Autofs mounts nfsserver:/export/home/john to /home/john
```

### 1.7 Advanced Autofs Options

**Common mount options**:
```bash
# In map file:
share   -rw,soft,intr,rsize=8192,wsize=8192   nfsserver:/share
#        │   │    │    │           └─ Write buffer size
#        │   │    │    └───────────── Read buffer size
#        │   │    └────────────────── Allow interruption
#        │   └─────────────────────── Soft timeout (return error)
#        └─────────────────────────── Read-write
```

**Multiple servers (failover)**:
```bash
# Try server1, fallback to server2
data   -ro   server1:/export/data,server2:/export/data
```

**Replicated mounts** (load balancing):
```bash
data   -ro   server1:/data server2:/data server3:/data
# Autofs picks closest/fastest server
```

### 1.8 Troubleshooting Autofs

**Check autofs status**:
```bash
sudo systemctl status autofs
```

**Test configuration**:
```bash
# Check for syntax errors
sudo automount -f -v
```

**View active mounts**:
```bash
# Before accessing
ls /mnt/nfs/
# (shows subdirs but not mounted)

# After accessing
mount | grep autofs
df -h | grep nfs
```

**Debug mode**:
```bash
# Stop autofs
sudo systemctl stop autofs

# Run in foreground with debug
sudo automount -f -v -d

# In another terminal, trigger mount
cd /mnt/nfs/data

# Watch debug output in first terminal
```

**Common issues**:

1. **Mount not triggering**:
```bash
# Check master map syntax
sudo cat /etc/auto.master
# Reload
sudo systemctl reload autofs
```

2. **Permission denied**:
```bash
# Check NFS server exports
showmount -e nfsserver
# Check firewall
sudo firewall-cmd --list-all
```

3. **Stale mounts**:
```bash
# Force unmount
sudo umount -l /mnt/nfs/data
# Restart autofs
sudo systemctl restart autofs
```

---

## 2. LDAP Authentication (Centralized User Management)

### 2.1 LDAP Overview

**LDAP (Lightweight Directory Access Protocol)**:
- Centralized user/group database
- Single sign-on across multiple Linux systems
- Common in enterprise environments
- Alternative to local `/etc/passwd`

**Components**:
- **LDAP server**: OpenLDAP, Active Directory, FreeIPA
- **LDAP client**: Linux system authenticating against LDAP
- **SSSD**: System Security Services Daemon (modern, recommended)
- **PAM**: Pluggable Authentication Modules (authentication layer)
- **NSS**: Name Service Switch (user/group lookups)

### 2.2 SSSD (Recommended Method)

**Why SSSD?**:
- Caching (works offline)
- Supports multiple backends (LDAP, AD, Kerberos)
- Better performance
- Modern and actively maintained

**Installation**:
```bash
# Debian/Ubuntu
sudo apt install sssd-ldap ldap-utils

# RHEL/CentOS/Fedora
sudo dnf install sssd sssd-ldap oddjob-mkhomedir
```

### 2.3 Configure SSSD for LDAP

**Example SSSD config**: `/etc/sssd/sssd.conf`
```bash
[sssd]
config_file_version = 2
services = nss, pam
domains = example.com

[domain/example.com]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap

ldap_uri = ldap://ldap.example.com
ldap_search_base = dc=example,dc=com
ldap_default_bind_dn = cn=admin,dc=example,dc=com
ldap_default_authtok = AdminPassword

# Cache credentials for offline auth
cache_credentials = true

# Create home directories on first login
auto_create_homedir = true
```

**Set permissions** (critical):
```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
```

**Enable and start SSSD**:
```bash
sudo systemctl enable sssd
sudo systemctl start sssd
sudo systemctl status sssd
```

### 2.4 Configure PAM and NSS

**NSS (Name Service Switch)** – `/etc/nsswitch.conf`:
```bash
# Tell system to check SSSD for users/groups
passwd:     files sss
group:      files sss
shadow:     files sss
```

**PAM (Authentication)** – usually auto-configured by sssd, but verify:
```bash
# /etc/pam.d/common-auth (Debian/Ubuntu)
# or /etc/pam.d/system-auth (RHEL)

auth    sufficient    pam_sss.so
account sufficient    pam_sss.so
password sufficient   pam_sss.so
session  sufficient   pam_sss.so
```

### 2.5 Test LDAP Authentication

**Check user lookup**:
```bash
# Query LDAP user
id ldapuser
# Should show UID, GID from LDAP

getent passwd ldapuser
# Should display user info

getent group ldapgroup
# Should display group info
```

**Test SSH login**:
```bash
# From another machine
ssh ldapuser@linuxserver

# Home directory auto-created (if configured)
```

**Debug SSSD**:
```bash
# Enable debug logging
sudo vi /etc/sssd/sssd.conf

# Add to [domain] section:
debug_level = 9

# Restart
sudo systemctl restart sssd

# Check logs
sudo tail -f /var/log/sssd/sssd_example.com.log
```

### 2.6 Automatic Home Directory Creation

**Method 1: SSSD auto_create_homedir** (already in config above)

**Method 2: PAM mkhomedir**:
```bash
# Enable in PAM
sudo vi /etc/pam.d/common-session

# Add line:
session required    pam_mkhomedir.so skel=/etc/skel umask=0077

# Or use authconfig (RHEL):
sudo authconfig --enablemkhomedir --update
```

### 2.7 LDAP Query Tools

**ldapsearch** – Query LDAP directly:
```bash
# Search for user
ldapsearch -x -H ldap://ldap.example.com \
  -b "dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -W \
  "(uid=jdoe)"

# List all users
ldapsearch -x -H ldap://ldap.example.com \
  -b "dc=example,dc=com" \
  "(objectClass=posixAccount)"
```

**ldapwhoami** – Test bind:
```bash
ldapwhoami -x -H ldap://ldap.example.com \
  -D "cn=admin,dc=example,dc=com" \
  -W
# Output: dn:cn=admin,dc=example,dc=com
```

---

## 3. Time Synchronization (NTP/Chrony)

### 3.1 Importance of Time Sync

**Why accurate time matters**:
- **Logs**: Correlation across servers
- **Kerberos**: Auth fails if time drift > 5 min
- **SSL/TLS**: Certificates have validity periods
- **Cron jobs**: Scheduled tasks
- **Distributed systems**: Databases, clusters
- **Compliance**: Audit trails require accurate timestamps

### 3.2 Chrony (Modern, Recommended)

**Chrony** vs **ntpd**:
- Chrony: Faster sync, better for laptops, default on RHEL 8+
- ntpd: Traditional, still widely used

**Installation**:
```bash
# Debian/Ubuntu
sudo apt install chrony

# RHEL/CentOS/Fedora
sudo dnf install chrony

# Enable
sudo systemctl enable chronyd
sudo systemctl start chronyd
```

### 3.3 Chrony Configuration

**Config file**: `/etc/chrony/chrony.conf` (Debian) or `/etc/chrony.conf` (RHEL)

```bash
# NTP servers to sync with
pool 0.pool.ntp.org iburst
pool 1.pool.ntp.org iburst
pool 2.pool.ntp.org iburst

# Allow clients on local network to sync with this server
allow 192.168.1.0/24

# Log directory
logdir /var/log/chrony

# Step (jump) clock if offset > 1 second on startup
makestep 1.0 3
```

**Reload config**:
```bash
sudo systemctl restart chronyd
```

### 3.4 Chrony Commands

**Check sync status**:
```bash
chronyc tracking
# Output shows offset, stratum, reference time
```

**List time sources**:
```bash
chronyc sources
# Shows NTP servers and their stats
# * = current best source
# + = combined for sync
```

**Verbose source info**:
```bash
chronyc sourcestats
```

**Force immediate sync**:
```bash
sudo chronyc makestep
# Jumps clock to correct time (use carefully)
```

**Manual time adjustment**:
```bash
sudo chronyc
chronyc> manual on
chronyc> manual list
chronyc> exit
```

### 3.5 Timedatectl (Systemd)

**Check system time**:
```bash
timedatectl
# Shows local time, UTC, timezone, NTP status
```

**Output example**:
```
               Local time: Sun 2026-02-09 10:30:00 EST
           Universal time: Sun 2026-02-09 15:30:00 UTC
                 RTC time: Sun 2026-02-09 15:30:00
                Time zone: America/New_York (EST, -0500)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

**Set timezone**:
```bash
# List timezones
timedatectl list-timezones

# Set timezone
sudo timedatectl set-timezone America/New_York
```

**Enable/disable NTP**:
```bash
sudo timedatectl set-ntp true      # Enable
sudo timedatectl set-ntp false     # Disable
```

**Manually set time** (NTP must be disabled):
```bash
sudo timedatectl set-ntp false
sudo timedatectl set-time '2026-02-09 10:30:00'
```

### 3.6 Legacy NTP (ntpd)

**Still common on older systems**:

**Installation**:
```bash
sudo apt install ntp             # Debian/Ubuntu
sudo dnf install ntp             # RHEL/CentOS 7
```

**Config**: `/etc/ntp.conf`
```bash
# NTP servers
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst

# Allow local network clients
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
```

**Commands**:
```bash
sudo systemctl restart ntp

# Check sync
ntpq -p

# Force sync
sudo ntpd -gq
```

### 3.7 Time Sync Best Practices

1. **Use at least 3 NTP servers** (stratum diversity)
2. **Monitor drift** with chronyc tracking
3. **Use iburst** for faster initial sync
4. **Firewall rules**: Allow UDP port 123
5. **Stratum hierarchy**: Lower is better (1-2 for servers)
6. **Local time server**: In large networks, run local NTP server

---

## 4. SSL/TLS Certificate Management

### 4.1 Certificate Basics

**SSL/TLS** (Secure Sockets Layer / Transport Layer Security):
- Encrypts traffic (HTTPS, SMTP, IMAP, etc.)
- Authenticates server identity
- Prevents man-in-the-middle attacks

**Certificate components**:
- **Public key**: Shared with clients
- **Private key**: Kept secret on server (never share!)
- **Certificate**: Public key + identity info, signed by CA
- **CA (Certificate Authority)**: Trusted entity that signs certs

**Certificate types**:
- **Self-signed**: Free, not trusted by browsers, good for testing
- **CA-signed**: Trusted by browsers, costs money (or free with Let's Encrypt)

### 4.2 OpenSSL – Create Self-Signed Certificate

**Generate private key and certificate**:
```bash
# 1. Generate private key (2048-bit RSA)
sudo openssl genrsa -out /etc/ssl/private/server.key 2048

# 2. Generate self-signed certificate (valid 365 days)
sudo openssl req -new -x509 -key /etc/ssl/private/server.key \
  -out /etc/ssl/certs/server.crt -days 365

# Interactive prompts:
Country Name (2 letter code) [AU]: US
State or Province Name [Some-State]: New York
Locality Name []: New York City
Organization Name []: My Company
Organizational Unit Name []: IT Department
Common Name []: server.example.com     # IMPORTANT: Your domain/hostname
Email Address []: admin@example.com
```

**Set permissions**:
```bash
sudo chmod 600 /etc/ssl/private/server.key
sudo chmod 644 /etc/ssl/certs/server.crt
```

**Use in Apache**:
```bash
# /etc/apache2/sites-available/default-ssl.conf
SSLEngine on
SSLCertificateFile    /etc/ssl/certs/server.crt
SSLCertificateKeyFile /etc/ssl/private/server.key
```

### 4.3 Certificate Signing Request (CSR)

**For CA-signed certificates**:

**Step 1: Generate private key and CSR**:
```bash
# Generate key
sudo openssl genrsa -out /etc/ssl/private/server.key 2048

# Generate CSR (Certificate Signing Request)
sudo openssl req -new -key /etc/ssl/private/server.key \
  -out /etc/ssl/certs/server.csr

# Same prompts as before (Common Name = your domain)
```

**Step 2: Submit CSR to CA**:
- Send `server.csr` to your CA (DigiCert, Comodo, etc.)
- CA verifies your identity
- CA sends back signed certificate (`server.crt`)

**Step 3: Install signed certificate**:
```bash
# Place signed cert
sudo mv signed-cert.crt /etc/ssl/certs/server.crt

# Configure Apache/Nginx with paths
```

### 4.4 Let's Encrypt (Free Automated Certificates)

**Certbot** – Official Let's Encrypt client:

**Installation**:
```bash
# Debian/Ubuntu
sudo apt install certbot python3-certbot-apache

# RHEL/CentOS
sudo dnf install certbot python3-certbot-apache
```

**Obtain certificate for Apache**:
```bash
# Automated Apache configuration
sudo certbot --apache -d example.com -d www.example.com

# Interactive:
# - Email for notifications
# - Agree to ToS
# - Redirect HTTP to HTTPS? (recommended: yes)

# Certificate files stored in:
# /etc/letsencrypt/live/example.com/
#   - fullchain.pem  (certificate + chain)
#   - privkey.pem    (private key)
```

**Manual certificate** (no web server auto-config):
```bash
sudo certbot certonly --standalone -d example.com

# Standalone mode: Certbot runs temp web server on port 80
# (requires port 80 to be free)
```

**Nginx**:
```bash
sudo apt install python3-certbot-nginx
sudo certbot --nginx -d example.com
```

**Renewal**:
```bash
# Dry run (test renewal)
sudo certbot renew --dry-run

# Actual renewal (auto-runs via cron/systemd timer)
sudo certbot renew

# Check expiration
sudo certbot certificates
```

**Automatic renewal** (already configured):
```bash
# Systemd timer (Ubuntu 18.04+)
sudo systemctl status certbot.timer

# Cron (older systems)
sudo crontab -l | grep certbot
# 0 3 * * * certbot renew --quiet
```

### 4.5 View Certificate Details

**Using openssl**:
```bash
# View certificate file
openssl x509 -in /etc/ssl/certs/server.crt -text -noout

# Key details:
# - Issuer: Who signed it
# - Validity: Not Before / Not After dates
# - Subject: Domain name (Common Name)
# - Public Key: Algorithm and size
```

**Check remote server certificate**:
```bash
# HTTPS
openssl s_client -connect example.com:443 < /dev/null

# SMTP with STARTTLS
openssl s_client -connect mail.example.com:587 -starttls smtp

# View expiration date
echo | openssl s_client -connect example.com:443 2>/dev/null | \
  openssl x509 -noout -dates
```

**Using browser**:
- Click padlock in address bar
- View certificate details

### 4.6 Certificate Troubleshooting

**Common issues**:

1. **Certificate expired**:
```bash
# Check expiration
openssl x509 -in cert.crt -noout -enddate

# Renew Let's Encrypt
sudo certbot renew
```

2. **Common Name mismatch**:
```bash
# Certificate CN must match domain
# Check CN:
openssl x509 -in cert.crt -noout -subject
```

3. **Untrusted certificate** (self-signed):
- Browser warning normal for self-signed
- Add exception in browser, or use CA-signed cert

4. **Mixed content** (HTTPS page loading HTTP resources):
- All resources (CSS, JS, images) must be HTTPS
- Check browser console for mixed content warnings

**Test SSL configuration**:
- https://www.ssllabs.com/ssltest/ (Qualys SSL Labs)
- https://observatory.mozilla.org/ (Mozilla Observatory)

---

## 5. Systemd Timers vs Cron

### 5.1 Traditional Cron

**Cron** – time-based job scheduler:

**User crontab**:
```bash
# Edit crontab
crontab -e

# Format: minute hour day month weekday command
# Example: Run backup at 2:30 AM daily
30 2 * * * /usr/local/bin/backup.sh

# Shortcuts:
@reboot   /usr/local/bin/startup.sh      # At boot
@daily    /usr/local/bin/daily.sh        # Midnight
@hourly   /usr/local/bin/hourly.sh       # Top of hour
@weekly   /usr/local/bin/weekly.sh       # Sunday midnight
@monthly  /usr/local/bin/monthly.sh      # 1st of month
```

**System crontab** `/etc/crontab`:
```bash
# Includes user field
# minute hour day month weekday user command
30 2 * * * root /usr/local/bin/backup.sh
```

**Cron directories**:
```bash
/etc/cron.hourly/        # Scripts run hourly
/etc/cron.daily/         # Scripts run daily
/etc/cron.weekly/        # Scripts run weekly
/etc/cron.monthly/       # Scripts run monthly
```

### 5.2 Systemd Timers (Modern Alternative)

**Advantages**:
- Better logging (journalctl)
- Run missed jobs (if system was off)
- Dependencies on other services
- Environment control
- More precise timing

**Anatomy**: Two files needed:
1. **Service file** (`.service`): What to run
2. **Timer file** (`.timer`): When to run it

### 5.3 Create Systemd Timer

**Example**: Run backup daily

**Step 1: Create service** `/etc/systemd/system/backup.service`:
```ini
[Unit]
Description=Daily Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
User=root
```

**Step 2: Create timer** `/etc/systemd/system/backup.timer`:
```ini
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
OnCalendar=02:30           # or use this for specific time
Persistent=true            # Run missed jobs after boot
RandomizedDelaySec=10m     # Add random delay to avoid load spikes

[Install]
WantedBy=timers.target
```

**Step 3: Enable and start timer**:
```bash
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

**Check timer status**:
```bash
# List all timers
systemctl list-timers

# Check specific timer
systemctl status backup.timer

# View logs
journalctl -u backup.service
```

### 5.4 Systemd Timer OnCalendar Syntax

**Formats**:
```bash
# Daily at midnight
OnCalendar=daily

# Specific time
OnCalendar=*-*-* 02:30:00           # Daily at 2:30 AM

# Every Monday
OnCalendar=Mon *-*-* 00:00:00

# Hourly
OnCalendar=hourly

# Every 15 minutes
OnCalendar=*:0/15                   # 00, 15, 30, 45

# Weekdays at 9 AM
OnCalendar=Mon..Fri *-*-* 09:00:00

# First day of month
OnCalendar=*-*-01 03:00:00
```

**Test calendar expression**:
```bash
systemd-analyze calendar "Mon..Fri *-*-* 09:00:00"
# Shows next occurrence
```

### 5.5 Cron vs Systemd Timers Comparison

| Feature | Cron | Systemd Timers |
|---------|------|----------------|
| **Syntax** | Simple, classic | More verbose |
| **Logging** | Separate logs | Integrated journalctl |
| **Missed jobs** | Skipped | Can run if Persistent=true |
| **Dependencies** | None | Full systemd integration |
| **Isolation** | Minimal | Full service isolation |
| **Email output** | Built-in | Manual setup |
| **Seconds precision** | No | Yes |
| **Random delay** | Manual | Built-in RandomizedDelaySec |

**When to use**:
- **Cron**: Simple tasks, legacy systems, familiarity
- **Systemd timers**: Complex workflows, dependency management, modern systems

---

## 6. Practice Exercises

1. **Autofs**:
   - Set up autofs to auto-mount a local USB drive
   - Configure indirect map for multiple NFS shares
   - Test timeout and auto-unmount behavior

2. **LDAP/SSSD**:
   - Install and configure SSSD (use public LDAP test server if needed)
   - Test user lookup with `id` and `getent`
   - Configure automatic home directory creation

3. **Time Synchronization**:
   - Install chrony and configure with pool.ntp.org
   - Check sync status with `chronyc tracking`
   - Set timezone with `timedatectl`

4. **SSL Certificates**:
   - Generate self-signed certificate for Apache
   - Install and view certificate details with openssl
   - Set up Let's Encrypt on test domain

5. **Systemd Timers**:
   - Convert a cron job to systemd timer
   - Create timer that runs every 30 minutes
   - Check execution logs with `journalctl`

---

## 7. Key Takeaways

✅ **Autofs** auto-mounts filesystems on-demand, saves resources  
✅ **LDAP + SSSD** provides centralized authentication across Linux systems  
✅ **Chrony** is modern NTP client for accurate time sync  
✅ **Let's Encrypt** offers free automated SSL certificates  
✅ **Systemd timers** are modern alternative to cron with better logging  
✅ **timedatectl** manages system time and timezone  
✅ **openssl** creates and manages SSL certificates  
✅ **Persistent timers** run missed jobs after system downtime  

---

**Next**: Continue to [linux-24-advanced-networking-topics.md](linux-24-advanced-networking.md) for network bonding, bridging, and load balancing.

**Previous**: [linux-22-selinux-mac.md](linux-22-selinux-mac.md) for SELinux and mandatory access control.

