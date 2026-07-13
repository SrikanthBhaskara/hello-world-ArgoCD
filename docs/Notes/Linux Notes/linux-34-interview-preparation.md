# Linux Interview Preparation

**Comprehensive Q&A for all Linux roles - from beginner to expert level**

---

## Table of Contents

### By Role
1. [Linux System Administrator](#linux-system-administrator)
2. [DevOps Engineer](#devops-engineer)
3. [Site Reliability Engineer (SRE)](#site-reliability-engineer-sre)
4. [Database Administrator (DBA)](#database-administrator-dba)
5. [Security Engineer / PSIRT](#security-engineer--psirt)
6. [Cloud Engineer](#cloud-engineer)

### By Level
- **Beginner**: Fundamental concepts, basic commands
- **Intermediate**: Practical administration, troubleshooting
- **Advanced**: Architecture, performance tuning, complex scenarios
- **Expert**: Design decisions, best practices, leadership

---

## Linux System Administrator

### Beginner Level

**Q1: What is Linux and how is it different from Unix?**

**A:** Linux is a free, open-source operating system based on Unix principles. Key differences:
- **Cost**: Linux is free; Unix (Solaris, AIX, HP-UX) is proprietary and expensive
- **License**: Linux uses GPL; Unix has various commercial licenses
- **Hardware**: Linux runs on almost any hardware; Unix is vendor-specific
- **Kernel**: Linux kernel is monolithic; Unix kernels vary by implementation
- **Development**: Linux is community-driven; Unix is vendor-controlled
- **Distributions**: Linux has many flavors (Ubuntu, RHEL, Debian); Unix is unified per vendor

**Real-world relevance**: Understanding this helps explain why Linux dominates servers, cloud, containers, and embedded systems.

---

**Q2: Explain the Linux directory structure.**

**A:** Linux follows the Filesystem Hierarchy Standard (FHS):

- `/` - Root directory, top of the filesystem hierarchy
- `/bin` - Essential user commands (ls, cp, cat)
- `/boot` - Boot loader files, kernel, initramfs
- `/dev` - Device files (hard drives /dev/sda, terminals /dev/tty)
- `/etc` - System configuration files
- `/home` - User home directories (/home/username)
- `/lib` - Shared libraries needed by /bin and /sbin
- `/media` - Mount points for removable media
- `/mnt` - Temporary mount points
- `/opt` - Optional third-party software
- `/proc` - Virtual filesystem for process and kernel info
- `/root` - Root user's home directory
- `/run` - Runtime data (PIDs, sockets)
- `/sbin` - System administration binaries (fdisk, iptables)
- `/srv` - Service data (web server, FTP)
- `/sys` - Virtual filesystem for kernel/device info
- `/tmp` - Temporary files (cleared on reboot)
- `/usr` - User programs and data
  - `/usr/bin` - User commands
  - `/usr/local` - Locally installed software
  - `/usr/share` - Shared data
- `/var` - Variable data (logs, databases, web content)
  - `/var/log` - Log files
  - `/var/www` - Web server files

**Interview tip**: Demonstrate understanding by explaining why /etc holds configs, /var holds logs, and /tmp is temporary.

---

**Q3: What are file permissions in Linux? How do you change them?**

**A:** Linux uses a permission model with three levels:

**Permission Types**:
- **r** (read) = 4: View file contents or list directory
- **w** (write) = 2: Modify file or create/delete files in directory
- **x** (execute) = 1: Run file as program or enter directory

**Permission Levels**:
- **User (u)**: File owner
- **Group (g)**: Group members
- **Others (o)**: Everyone else

**Example**: `-rwxr-xr--`
- `-` = regular file (d=directory, l=symlink)
- `rwx` = owner can read, write, execute
- `r-x` = group can read and execute
- `r--` = others can only read

**Changing permissions**:
```bash
# Numeric method (most common)
chmod 755 file              # rwxr-xr-x
chmod 644 file              # rw-r--r--
chmod 600 file              # rw------- (private file)

# Symbolic method
chmod u+x file              # Add execute for owner
chmod g-w file              # Remove write for group
chmod o=r file              # Set read-only for others
chmod a+r file              # Add read for all

# Change ownership
chown user:group file       # Change owner and group
chown user file             # Change owner only
chgrp group file            # Change group only
```

**Special permissions**:
- **SUID (4)**: Run as file owner (`chmod 4755 file`)
- **SGID (2)**: Run as group owner, inherit directory group (`chmod 2755 dir`)
- **Sticky bit (1)**: Only owner can delete files in directory (`chmod 1777 /tmp`)

---

**Q4: How do you check disk space usage?**

**A:** Multiple commands depending on what you need:

```bash
# Overall disk space
df -h                       # Human-readable, shows filesystems
df -i                       # Inode usage (files count)
df -h /var                  # Specific mount point

# Directory sizes
du -sh /var/log             # Summary of directory
du -h --max-depth=1 /var    # One level deep
du -h /var | sort -h | tail -20  # Top 20 largest

# Find large files
find / -type f -size +100M -exec ls -lh {} \; | sort -k5 -h

# Interactive disk usage analyzer
ncdu /var                   # Navigate with arrows

# Check inode usage
df -i                       # May run out of inodes even with disk space
```

**Common issue**: Disk full but `df` shows space available → Check for deleted but open files:
```bash
lsof | grep deleted
# Restart service to release file handles
```

---

**Q5: How do you find a process that is consuming high CPU?**

**A:** Step-by-step approach:

```bash
# 1. Quick overview
top                         # Press 'P' to sort by CPU

# 2. Better visualization
htop                        # Color-coded, easier to read

# 3. List top CPU consumers
ps aux --sort=-%cpu | head -10

# 4. Continuous monitoring
watch -n 1 'ps aux --sort=-%cpu | head -10'

# 5. Get specific process details
ps -p <PID> -o pid,ppid,cmd,%cpu,%mem,start,etime

# 6. See what the process is doing
strace -p <PID>             # System calls
lsof -p <PID>               # Open files
pstree -p <PID>             # Process tree

# 7. Check for I/O wait (high CPU might be I/O bottleneck)
iostat -x 1
iotop -o
```

**Actions**:
```bash
# Lower priority
renice -n 19 -p <PID>

# Graceful stop
kill -TERM <PID>

# Force kill (last resort)
kill -9 <PID>

# Limit CPU usage
cpulimit -p <PID> -l 50     # Limit to 50% of one CPU
```

---

### Intermediate Level

**Q6: Explain the boot process in Linux.**

**A:** Modern Linux boot sequence (UEFI/systemd):

1. **UEFI/BIOS**:
   - Power-on self-test (POST)
   - Load bootloader from EFI System Partition (ESP) or MBR

2. **GRUB2 Bootloader**:
   - Display boot menu
   - Load selected kernel and initramfs
   - Pass kernel parameters

3. **Kernel Initialization**:
   - Decompress kernel
   - Initialize hardware drivers
   - Mount initramfs (temporary root filesystem)
   - Load necessary drivers from initramfs

4. **initramfs**:
   - Detect and load storage drivers
   - Find and mount real root filesystem
   - Switch to real root (pivot_root)

5. **systemd (PID 1)**:
   - First user-space process
   - Read `/etc/systemd/system/default.target`
   - Start services in parallel based on dependencies
   - Mount filesystems from `/etc/fstab`
   - Start login managers

6. **Target Reached**:
   - `multi-user.target` - Text mode (no GUI)
   - `graphical.target` - GUI login

**Troubleshooting**:
```bash
# View boot messages
dmesg
journalctl -b               # Current boot
journalctl -b -1            # Previous boot

# Boot into rescue mode
# At GRUB: press 'e', add to kernel line:
systemd.unit=rescue.target
# or
rd.break                    # Break at initramfs

# Check systemd boot time
systemd-analyze
systemd-analyze blame       # Service startup times
```

---

**Q7: What is the difference between hard link and soft link?**

**A:** 

**Hard Link**:
- Direct reference to inode
- Same inode number as original file
- Cannot cross filesystem boundaries
- Cannot link to directories (prevents loops)
- If original is deleted, hard link still works
- Deleting hard link doesn't affect original

```bash
ln /path/original /path/hardlink
ls -i                       # Show inode numbers (same for both)
```

**Soft Link (Symbolic Link)**:
- Pointer to filename (path)
- Different inode number
- Can cross filesystems
- Can link to directories
- If original is deleted, soft link becomes broken
- Acts like a shortcut

```bash
ln -s /path/original /path/symlink
ls -l                       # Shows: symlink -> /path/original
readlink symlink            # Show target
```

**Comparison table**:
| Feature | Hard Link | Soft Link |
|---------|-----------|-----------|
| Inode | Same as original | Different |
| Cross filesystem | No | Yes |
| Link directories | No | Yes |
| Original deleted | Link works | Link breaks |
| Relative path | N/A | Possible |
| Disk space | None (just dir entry) | Tiny (path string) |

**Real-world use**:
- Hard links: Backup systems (save space for unchanged files)
- Soft links: `/usr/bin/python -> python3.9` (version management)

---

**Q8: How do you troubleshoot a service that won't start?**

**A:** Systematic troubleshooting approach:

```bash
# 1. Check service status
systemctl status servicename
# Look for: error messages, exit codes

# 2. Check service logs
journalctl -u servicename -n 50
journalctl -u servicename --since "1 hour ago"
journalctl -u servicename -f      # Follow

# 3. Check configuration syntax
# Apache
apachectl configtest
# Nginx
nginx -t
# General
systemctl show servicename -p ExecStart

# 4. Check if port is already in use
ss -tuln | grep :80
lsof -i :80

# 5. Check file permissions
ls -l /path/to/service/files
# Ensure service user has access

# 6. Check SELinux (RHEL/CentOS)
getenforce
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# 7. Check dependencies
systemctl list-dependencies servicename
# Verify required services are running

# 8. Check disk space
df -h
df -i                       # Inode exhaustion

# 9. Check resource limits
systemctl show servicename | grep Limit
ulimit -a

# 10. Manually run service
# Find ExecStart command
systemctl cat servicename
# Run it manually to see errors
/usr/sbin/servicename -f    # Foreground mode

# 11. Enable debug logging
# Edit service file
sudo systemctl edit servicename
[Service]
Environment="DEBUG=1"

# 12. Check system logs
dmesg | tail
tail -f /var/log/messages
tail -f /var/log/syslog
```

**Common issues**:
- Port already in use → Kill conflicting process or change port
- Permission denied → Fix file ownership/permissions
- SELinux denial → Set correct context or create policy
- Missing dependency → Install required package
- Configuration error → Check syntax with specific tool

---

**Q9: How would you find which package installed a specific file?**

**A:** Depends on distribution:

**RHEL/CentOS/Fedora (RPM-based)**:
```bash
# Find which package owns a file
rpm -qf /usr/bin/ssh
# Output: openssh-clients-8.0p1-17.el8.x86_64

# Find all files installed by a package
rpm -ql openssh-clients

# Search for files matching pattern
dnf provides /usr/bin/ssh
dnf provides */ssh_config

# Query installed package info
rpm -qi openssh-clients
```

**Ubuntu/Debian (DEB-based)**:
```bash
# Find which package owns a file
dpkg -S /usr/bin/ssh
# Output: openssh-client: /usr/bin/ssh

# Find all files installed by package
dpkg -L openssh-client

# Search for files (including not installed)
apt-file search /usr/bin/ssh
# Need to install apt-file first
sudo apt install apt-file
sudo apt-file update

# Query package info
dpkg -l openssh-client
apt show openssh-client
```

**Find files that packages provide (even if not installed)**:
```bash
# RHEL/CentOS
dnf whatprovides */httpd.conf

# Ubuntu/Debian
apt-file search httpd.conf
```

---

**Q10: How do you set up a cron job?**

**A:** Multiple methods:

**Method 1: User crontab**
```bash
# Edit crontab
crontab -e

# Cron format:
# MIN HOUR DOM MON DOW COMMAND
# *   *    *   *   *   command to execute

# Examples:
# Daily at 2 AM
0 2 * * * /path/to/backup.sh

# Every 15 minutes
*/15 * * * * /path/to/check-status.sh

# Weekdays at 9 AM
0 9 * * 1-5 /path/to/work-task.sh

# First day of month at midnight
0 0 1 * * /path/to/monthly-report.sh

# Multiple times
0 8,12,18 * * * /path/to/script.sh

# List crontab
crontab -l

# Remove crontab
crontab -r

# Edit another user's crontab (as root)
sudo crontab -u username -e
```

**Method 2: System cron directories** (simpler, no cron syntax needed)
```bash
# Place scripts in:
/etc/cron.hourly/       # Runs hourly
/etc/cron.daily/        # Runs daily
/etc/cron.weekly/       # Runs weekly
/etc/cron.monthly/      # Runs monthly

# Make executable
sudo chmod +x /etc/cron.daily/my-backup

# Script must have no extension!
# ✅ Good: /etc/cron.daily/backup
# ❌ Bad: /etc/cron.daily/backup.sh
```

**Method 3: systemd timers** (modern, more control)
```bash
# Create service file: /etc/systemd/system/backup.service
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/path/to/backup.sh

# Create timer file: /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check timers
systemctl list-timers
```

**Cron environment gotchas**:
```bash
# Cron has minimal PATH
# ❌ Might fail:
0 2 * * * backup.sh

# ✅ Use full paths:
0 2 * * * /usr/local/bin/backup.sh

# ✅ Or set PATH:
PATH=/usr/local/bin:/usr/bin:/bin
0 2 * * * backup.sh

# Redirect output to log
0 2 * * * /path/backup.sh >> /var/log/backup.log 2>&1

# Email output (if mail configured)
MAILTO=admin@example.com
0 2 * * * /path/backup.sh
```

---

### Advanced Level

**Q11: Explain how LVM works and when you would use it.**

**A:** Logical Volume Manager (LVM) adds abstraction layer between physical storage and filesystems.

**Architecture**:
```
Physical Disks (/dev/sda, /dev/sdb)
        ↓
Physical Volumes (PV)  ← pvcreate
        ↓
Volume Groups (VG)     ← vgcreate (pool of PVs)
        ↓
Logical Volumes (LV)   ← lvcreate (carved from VG)
        ↓
Filesystems (ext4, XFS)
```

**Setup example**:
```bash
# 1. Create Physical Volumes
sudo pvcreate /dev/sdb /dev/sdc
sudo pvdisplay

# 2. Create Volume Group
sudo vgcreate vg_data /dev/sdb /dev/sdc
sudo vgdisplay

# 3. Create Logical Volumes
sudo lvcreate -L 10G -n lv_mysql vg_data
sudo lvcreate -L 20G -n lv_www vg_data
sudo lvcreate -l 100%FREE -n lv_backup vg_data
sudo lvdisplay

# 4. Create filesystems
sudo mkfs.ext4 /dev/vg_data/lv_mysql
sudo mkfs.xfs /dev/vg_data/lv_www

# 5. Mount
sudo mkdir -p /var/lib/mysql /var/www
sudo mount /dev/vg_data/lv_mysql /var/lib/mysql
sudo mount /dev/vg_data/lv_www /var/www

# 6. Add to /etc/fstab
/dev/vg_data/lv_mysql  /var/lib/mysql  ext4  defaults  0  2
/dev/vg_data/lv_www    /var/www        xfs   defaults  0  2
```

**Advantages**:
1. **Resize online**: Grow/shrink filesystems without downtime
   ```bash
   # Extend LV
   sudo lvextend -L +10G /dev/vg_data/lv_mysql
   sudo resize2fs /dev/vg_data/lv_mysql  # ext4
   # OR
   sudo xfs_growfs /var/www              # XFS
   ```

2. **Snapshots**: Point-in-time backups
   ```bash
   # Create snapshot (uses copy-on-write)
   sudo lvcreate -L 5G -s -n lv_mysql_snap /dev/vg_data/lv_mysql
   
   # Mount snapshot
   sudo mount /dev/vg_data/lv_mysql_snap /mnt/snapshot
   
   # Backup from snapshot
   sudo tar -czf mysql-backup.tar.gz /mnt/snapshot
   
   # Remove snapshot
   sudo umount /mnt/snapshot
   sudo lvremove /dev/vg_data/lv_mysql_snap
   ```

3. **Flexibility**: Move data between disks transparently
   ```bash
   # Add new disk to VG
   sudo pvcreate /dev/sdd
   sudo vgextend vg_data /dev/sdd
   
   # Move data from old disk to new
   sudo pvmove /dev/sdb /dev/sdd
   
   # Remove old disk
   sudo vgreduce vg_data /dev/sdb
   sudo pvremove /dev/sdb
   ```

4. **Thin provisioning**: Allocate space on demand
5. **Striping**: Performance across multiple disks

**When to use LVM**:
- ✅ Servers with changing storage needs
- ✅ Database servers (snapshots before upgrades)
- ✅ Virtual machines (flexible disk management)
- ✅ Multi-disk systems
- ❌ Single-disk desktops (overhead not worth it)
- ❌ Boot partition (complexity)

---

**Q12: A server is running slowly. How do you diagnose the bottleneck?**

**A:** Systematic performance analysis:

**Step 1: Check system load**
```bash
uptime
# load average: 5.32, 4.21, 3.15
# Rule: If load > CPU cores, system is overloaded
# 4-core system with load 5.32 = 132% utilized

w                           # Load + logged in users
```

**Step 2: Identify bottleneck type**
```bash
# CPU bottleneck?
top
# Look for: %Cpu(s): 98.5 us, high user/system CPU
mpstat -P ALL 1             # Per-CPU statistics

# Memory bottleneck?
free -h
# Look for: low available memory, high swap usage
vmstat 1 5
# Look for: si/so (swap in/out), high page faults

# Disk I/O bottleneck?
iostat -x 1 5
# Look for: %util close to 100%, high await (latency)
iotop -o                    # Which processes doing I/O
# Look for: %wa (I/O wait) in top

# Network bottleneck?
iftop -i eth0               # Network bandwidth usage
nethogs                     # Per-process network usage
ss -s                       # Socket statistics
```

**Step 3: Find culprit processes**
```bash
# Top CPU consumers
ps aux --sort=-%cpu | head -10

# Top memory consumers
ps aux --sort=-%mem | head -10

# Processes in uninterruptible sleep (I/O wait)
ps aux | awk '$8 ~ /D/ {print}'

# Check process details
ps -p <PID> -o pid,ppid,cmd,%cpu,%mem,etime,state
strace -p <PID> -c          # System call summary
lsof -p <PID>               # Open files
```

**Step 4: Analyze specific bottleneck**

**CPU Bottleneck**:
```bash
# Profile application
perf record -p <PID>
perf report

# Check for runaway processes
top -b -n 1 | head -20

# Solutions:
# - Kill unnecessary processes
# - Optimize code/queries
# - Add more CPU cores
# - Use nice/renice to prioritize
```

**Memory Bottleneck**:
```bash
# Check OOM killer activity
dmesg | grep -i "out of memory"
journalctl | grep -i "oom"

# Memory breakdown
cat /proc/meminfo
slabtop                     # Kernel memory usage

# Find memory leaks
valgrind --leak-check=full ./program

# Solutions:
# - Kill memory-hungry processes
# - Add more RAM
# - Reduce cache sizes
# - Fix application memory leaks
```

**Disk I/O Bottleneck**:
```bash
# Disk-specific I/O stats
iostat -dx 1
# %util near 100% = disk saturated
# await high = slow disk

# Per-process I/O
iotop -oPa

# Check RAID/LVM issues
cat /proc/mdstat            # RAID
lvs -o+devices              # LVM

# Solutions:
# - Move to faster disks (SSD/NVMe)
# - Optimize database queries
# - Add caching (Redis, Memcached)
# - Use RAID 10 instead of RAID 5
```

**Network Bottleneck**:
```bash
# Network errors
netstat -i
ifconfig eth0               # RX/TX errors, drops

# Bandwidth usage
iftop -i eth0

# Connections
ss -s                       # Summary
ss -tanp | wc -l            # Total connections

# Solutions:
# - Upgrade network (1Gbps → 10Gbps)
# - Load balancing
# - CDN for static content
# - Connection pooling
```

**Step 5: Long-term monitoring**
```bash
# Install SAR
sudo apt install sysstat    # Ubuntu
sudo dnf install sysstat    # RHEL

# Enable data collection
sudo systemctl enable sysstat
sudo systemctl start sysstat

# Review historical data
sar -u                      # CPU usage
sar -r                      # Memory
sar -b                      # I/O
sar -n DEV                  # Network
```

---

## DevOps Engineer

### Intermediate Level

**Q13: Explain CI/CD and how you would implement it for a web application.**

**A:** Continuous Integration / Continuous Deployment automates the software delivery pipeline.

**CI/CD Pipeline stages**:
1. **Code** → Push to Git (GitHub, GitLab, Bitbucket)
2. **Build** → Compile, run tests
3. **Test** → Unit, integration, security tests
4. **Package** → Create Docker image, build artifacts
5. **Deploy** → Staging, then production
6. **Monitor** → Logs, metrics, alerts

**Implementation example (GitLab CI)**:

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - package
  - deploy

variables:
  DOCKER_IMAGE: registry.example.com/myapp
  KUBE_NAMESPACE: production

# Build application
build-job:
  stage: build
  image: node:18
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
  only:
    - main
    - develop

# Run tests
test-unit:
  stage: test
  image: node:18
  script:
    - npm install
    - npm run test:unit
  coverage: '/Statements\s*:\s*(\d+\.\d+)%/'

test-integration:
  stage: test
  image: node:18
  services:
    - postgres:14
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test123
  script:
    - npm install
    - npm run test:integration

# Security scanning
security-scan:
  stage: test
  image: aquasec/trivy:latest
  script:
    - trivy fs --severity HIGH,CRITICAL .

# Build Docker image
build-docker:
  stage: package
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHA .
    - docker tag $DOCKER_IMAGE:$CI_COMMIT_SHA $DOCKER_IMAGE:latest
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHA
    - docker push $DOCKER_IMAGE:latest
  only:
    - main

# Deploy to staging
deploy-staging:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context staging
    - kubectl set image deployment/myapp myapp=$DOCKER_IMAGE:$CI_COMMIT_SHA -n staging
    - kubectl rollout status deployment/myapp -n staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

# Deploy to production
deploy-production:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context production
    - kubectl set image deployment/myapp myapp=$DOCKER_IMAGE:$CI_COMMIT_SHA -n $KUBE_NAMESPACE
    - kubectl rollout status deployment/myapp -n $KUBE_NAMESPACE
  environment:
    name: production
    url: https://example.com
  when: manual                # Require manual approval
  only:
    - main
```

**Key practices**:
1. **Automated testing**: Every commit triggers tests
2. **Fast feedback**: Developers know within minutes if code breaks
3. **Reproducible builds**: Docker ensures consistency
4. **Automated deployment**: Reduces human error
5. **Rollback capability**: Quick revert if issues found
6. **Blue-green deployment**: Zero-downtime updates

**Benefits**:
- Faster releases (daily vs monthly)
- Fewer bugs in production
- Consistent environments (dev = staging = prod)
- Reduced manual work
- Faster time to market

---

**Q14: How do you manage secrets in a DevOps environment?**

**A:** Never store secrets in code! Multiple approaches:

**1. Kubernetes Secrets** (for K8s deployments)
```bash
# Create secret
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=SuperSecret123

# Use in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```

**2. HashiCorp Vault** (enterprise-grade)
```bash
# Store secret
vault kv put secret/database/config \
  username=admin \
  password=SuperSecret123

# Retrieve in application
vault kv get -field=password secret/database/config

# Use in CI/CD
export VAULT_ADDR='https://vault.example.com'
export VAULT_TOKEN='s.xyz...'
DB_PASS=$(vault kv get -field=password secret/database/config)
```

**3. AWS Secrets Manager** (cloud-native)
```bash
# Store secret
aws secretsmanager create-secret \
  --name MyAppSecret \
  --secret-string '{"username":"admin","password":"SuperSecret123"}'

# Retrieve in application (Python example)
import boto3
import json

client = boto3.client('secretsmanager')
response = client.get_secret_value(SecretId='MyAppSecret')
secret = json.loads(response['SecretString'])
```

**4. Encrypted files** (Ansible Vault, git-crypt)
```bash
# Ansible Vault
ansible-vault encrypt vars/secrets.yml
ansible-vault edit vars/secrets.yml

# In playbook
- hosts: all
  vars_files:
    - vars/secrets.yml

# Run with vault password
ansible-playbook -i inventory playbook.yml --ask-vault-pass
```

**Best practices**:
- ✅ Rotate secrets regularly
- ✅ Use different secrets for dev/staging/prod
- ✅ Audit secret access
- ✅ Encrypt secrets at rest and in transit
- ✅ Principle of least privilege
- ❌ Never commit secrets to Git
- ❌ Never log secrets
- ❌ Never email secrets

**Secret rotation automation**:
```bash
# Example: Rotate database password
#!/bin/bash
NEW_PASS=$(openssl rand -base64 32)

# Update in Vault
vault kv put secret/database/config password="$NEW_PASS"

# Update database
mysql -u root -p"$OLD_PASS" -e "ALTER USER 'app'@'%' IDENTIFIED BY '$NEW_PASS';"

# Restart application (picks up new secret)
kubectl rollout restart deployment/myapp
```

---

## Security Engineer / PSIRT

### Advanced Level

**Q15: How do you investigate a potential security breach on a Linux server?**

**A:** Follow incident response methodology: **Prepare → Detect → Contain → Investigate → Remediate → Recover → Lessons Learned**

**Phase 1: Preparation (before incident)**
```bash
# Enable auditing
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure audit rules
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo auditctl -w /etc/shadow -p wa -k shadow_changes
sudo auditctl -w /etc/sudoers -p wa -k sudoers_changes

# Install security tools
sudo apt install rkhunter chkrootkit aide fail2ban

# Initialize AIDE (file integrity)
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

**Phase 2: Detection & Initial Assessment**
```bash
# Check for suspicious activity
last                        # Login history
lastlog                     # Last login per user
who                         # Currently logged in
w                           # What users are doing

# Check failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -50
sudo journalctl -u sshd | grep "Failed"

# Check sudo commands
sudo grep COMMAND /var/log/auth.log
```

**Phase 3: Containment (CRITICAL - Do this FAST)**
```bash
# 1. ISOLATE SYSTEM (but keep your access!)
# Block outbound traffic (prevent data exfiltration)
sudo iptables -P OUTPUT DROP
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.1.0/24 -j ACCEPT  # Allow local network

# 2. PRESERVE EVIDENCE
# Create forensic image
sudo dd if=/dev/sda of=/mnt/external/evidence-$(date +%F).img bs=4M

# Or minimum: backup critical logs and files
sudo tar -czf /mnt/backup/evidence-$(date +%F-%H%M).tar.gz \
  /var/log \
  /etc \
  /home \
  /root/.bash_history \
  /tmp \
  /var/tmp

# 3. START LOGGING EVERYTHING
script /root/investigation-$(date +%F-%H%M).log
```

**Phase 4: Investigation**
```bash
# Check for backdoor users
cat /etc/passwd
awk -F: '$3 == 0 {print $1}' /etc/passwd  # UID 0 users (should only be root!)
awk -F: '$3 >= 1000 {print $1}' /etc/passwd  # Regular users

# Check for unauthorized SSH keys
for home in /root /home/*; do
    echo "=== $home ==="
    cat $home/.ssh/authorized_keys 2>/dev/null
done

# Check for suspicious processes
ps aux --sort=-%cpu | head -20
ps aux | grep -v "\["            # Non-kernel processes
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head

# Check network connections
ss -tunap                        # All connections
ss -tunap | grep ESTABLISHED     # Active connections
lsof -i                          # Network files

# Check listening ports (compare against baseline)
ss -tuln

# Check for rootkits
sudo rkhunter --check
sudo chkrootkit

# Check file integrity
sudo aide --check

# Check for recently modified files
find / -mtime -7 -type f -ls     # Modified in last 7 days
find /tmp -type f -exec file {} \; | grep "executable"
find / -name "*.php" -mtime -7   # Recent PHP files (webshells?)

# Check cron jobs (common persistence method)
for user in $(cut -f1 -d: /etc/passwd); do
    echo "=== $user ==="
    sudo crontab -u $user -l 2>/dev/null
done
ls -la /etc/cron.*
cat /etc/crontab

# Check systemd timers
systemctl list-timers --all

# Check for SUID binaries (privilege escalation)
find / -perm -4000 -type f -ls 2>/dev/null

# Check bash history
cat /root/.bash_history
cat /home/*/.bash_history
# Look for: wget/curl downloads, user creation, permission changes

# Check audit logs
sudo ausearch -m avc -ts recent  # SELinux denials
sudo ausearch -m user_auth       # Authentication
sudo ausearch -k passwd_changes  # Password file changes

# Check for web shells
find /var/www -name "*.php" -o -name "*.jsp" | \
  xargs grep -l "eval\|base64_decode\|shell_exec\|system\|passthru"

# Check for crypto miners
ps aux | grep -E "xmrig|minerd|cpuminer|ethminer"
lsof -i | grep -E ":3333|:4444|:5555"  # Common mining ports

# Check iptables rules (attackers may modify)
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v    # NAT rules

# Check DNS changes
cat /etc/resolv.conf
cat /etc/hosts
```

**Phase 5: Forensic Analysis**
```bash
# Timeline of events
# Correlate: auth.log, audit.log, bash_history, file mtimes

# Example: Find when breach started
# 1. Find suspicious user creation
sudo grep useradd /var/log/auth.log

# 2. Find first suspicious login
sudo last -f /var/log/wtmp | grep suspicious_user

# 3. Check what they did
sudo ausearch -ua suspicious_user

# 4. Find all files they created/modified
sudo find / -user suspicious_user
```

**Phase 6: Remediation**
```bash
# Remove malicious accounts
sudo userdel -r attacker_account

# Remove unauthorized SSH keys
# (Done after verifying which are malicious)

# Remove malware/backdoors
sudo rm -f /tmp/malware
sudo shred -vfz -n 10 /path/to/sensitive/malware

# Kill malicious processes
sudo kill -9 <PID>
sudo pkill malicious_process

# Remove persistence mechanisms
# - Cron jobs
# - systemd services
# - rc.local
# - .bashrc/.bash_profile modifications

# Patch vulnerabilities
sudo apt update && sudo apt upgrade -y
sudo dnf update -y

# Change ALL passwords
sudo passwd root
for user in $(cut -f1 -d: /etc/passwd); do
    sudo passwd $user
done

# Revoke and rotate SSH keys
# Regenerate all API keys, database passwords

# Rebuild if necessary
# If rootkit or kernel compromised, only safe option is full rebuild
```

**Phase 7: Recovery**
```bash
# Restore from clean backup
# Verify backup predates breach

# Harden system
# - Disable root SSH login
# - Enable 2FA
# - Configure fail2ban
# - Update firewall rules
# - Enable SELinux/AppArmor
# - Implement IDS (AIDE, OSSEC)

# Monitor closely
# - Set up alerts
# - Review logs daily
# - Check file integrity
```

**Phase 8: Lessons Learned (Post-Incident Report)**
- Timeline of breach
- Root cause (how did they get in?)
- Impact assessment
- What worked / didn't work in response
- Improvements needed
- Documentation updates

**PSIRT-specific considerations**:
- Preserve chain of custody for evidence
- Legal/compliance notifications (GDPR, PCI-DSS, HIPAA)
- Coordinate with SOC, Legal, PR teams
- CVE tracking and vendor notifications
- Customer communication plan

---

## Summary: Interview Success Tips

**Technical Preparation**:
1. ✅ Practice commands hands-on (VM/container)
2. ✅ Understand *why*, not just *how*
3. ✅ Know troubleshooting methodology
4. ✅ Prepare real-world examples from your experience

**Communication**:
1. ✅ Think aloud (show problem-solving process)
2. ✅ Ask clarifying questions
3. ✅ Explain trade-offs (no perfect solutions)
4. ✅ Admit if you don't know, but explain how you'd find out

**Role-Specific Focus**:
- **SysAdmin**: Troubleshooting, service management, monitoring
- **DevOps**: CI/CD, containers, automation, IaC
- **SRE**: Monitoring, incident response, scalability, SLAs
- **DBA**: Storage, backups, performance tuning, replication
- **Security**: Hardening, auditing, compliance, incident response
- **Cloud**: AWS/Azure/GCP services, networking, cost optimization

**Common Weak Points** (prepare these!):
1. Networking (subnetting, routing, DNS)
2. Performance troubleshooting (methodical approach)
3. Security hardening (SELinux, firewalls, encryption)
4. Automation (scripting, Ansible, Terraform)
5. Containers/Kubernetes (architecture, troubleshooting)

**Red Flags to Avoid**:
- ❌ "I would Google it" (instead: explain general approach)
- ❌ Blaming users or systems
- ❌ Not admitting knowledge gaps
- ❌ Overconfidence without backing it up
- ❌ Not asking about the environment/constraints

**Interview Day**:
1. Prepare questions to ask interviewer
2. Have examples ready (STAR method: Situation, Task, Action, Result)
3. Practice explaining complex concepts simply
4. Test your mic/camera if remote interview

Good luck! 🚀 With the knowledge in these 35 files, you're ready for any Linux role from Junior SysAdmin to Senior PSIRT Security Engineer!
