# Real-World Linux Scenarios

Production scenarios that Linux administrators face daily, with step-by-step troubleshooting and solutions.

---

## Table of Contents

### System Administration Scenarios
1. [Disk Space Crisis](#scenario-1-disk-space-crisis)
2. [System Won't Boot After Update](#scenario-2-system-wont-boot-after-update)
3. [Runaway Process Consuming CPU](#scenario-3-runaway-process-consuming-cpu)
4. [Memory Leak Investigation](#scenario-4-memory-leak-investigation)
5. [User Cannot Login](#scenario-5-user-cannot-login)

### Networking Scenarios
6. [Website Down - Cannot Connect](#scenario-6-website-down---cannot-connect)
7. [Slow Network Performance](#scenario-7-slow-network-performance)
8. [DNS Resolution Failure](#scenario-8-dns-resolution-failure)
9. [SSH Access Suddenly Broken](#scenario-9-ssh-access-suddenly-broken)
10. [Firewall Blocking Legitimate Traffic](#scenario-10-firewall-blocking-legitimate-traffic)

### Security Scenarios
11. [Suspected Server Compromise](#scenario-11-suspected-server-compromise)
12. [SELinux Blocking Application](#scenario-12-selinux-blocking-application)
13. [Failed Login Attempts Spike](#scenario-13-failed-login-attempts-spike)
14. [Unauthorized sudo Access](#scenario-14-unauthorized-sudo-access)
15. [SSL Certificate Expired](#scenario-15-ssl-certificate-expired)

### Performance Scenarios
16. [Database Server Slow Queries](#scenario-16-database-server-slow-queries)
17. [High Load Average Investigation](#scenario-17-high-load-average-investigation)
18. [Disk I/O Bottleneck](#scenario-18-disk-io-bottleneck)
19. [Network Bandwidth Saturation](#scenario-19-network-bandwidth-saturation)
20. [Application Memory Exhaustion](#scenario-20-application-memory-exhaustion)

### Disaster Recovery Scenarios
21. [Accidental File Deletion](#scenario-21-accidental-file-deletion)
22. [Failed System Update](#scenario-22-failed-system-update)
23. [Corrupted Filesystem](#scenario-23-corrupted-filesystem)
24. [RAID Array Failure](#scenario-24-raid-array-failure)
25. [Complete System Recovery](#scenario-25-complete-system-recovery)

---

## System Administration Scenarios

## Scenario 1: Disk Space Crisis

**Situation**: Production server alerts show "/" filesystem at 98% capacity. Application logs indicate write failures.

**Symptoms**:
```
df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   49G  100M  98% /
```

**Troubleshooting Steps**:

```bash
# 1. Identify what's consuming space
df -h                           # Check all filesystems
df -i                           # Check inode usage

# 2. Find large files/directories
du -h /var | sort -h | tail -20
du -h /home | sort -h | tail -20
du -h /tmp | sort -h | tail -20

# 3. Find large files across filesystem
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h

# 4. Check log files
du -h /var/log/* | sort -h | tail -10
ls -lh /var/log/messages*
ls -lh /var/log/journal/

# 5. Find deleted but open files (common culprit!)
lsof | grep deleted | awk '{print $7}' | sort -u

# 6. Check for large core dumps
find /var -name "core.*" -type f
```

**Solutions**:

```bash
# Solution 1: Clean log files
sudo journalctl --vacuum-size=500M
sudo journalctl --vacuum-time=7d

# Truncate large log files (don't delete - may break applications)
sudo truncate -s 0 /var/log/large-app.log

# Solution 2: Clean package cache
# Debian/Ubuntu
sudo apt clean
sudo apt autoclean
sudo apt autoremove

# RHEL/CentOS
sudo dnf clean all
sudo dnf autoremove

# Solution 3: Remove old kernels (keep current + 1)
# Ubuntu
sudo apt autoremove --purge

# RHEL/CentOS
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)

# Solution 4: Clean /tmp
sudo find /tmp -type f -atime +7 -delete

# Solution 5: Restart services with deleted files
lsof | grep deleted | awk '{print $2}' | sort -u | xargs sudo kill -HUP

# Solution 6: Emergency - extend filesystem
# If LVM is used:
sudo lvextend -L +10G /dev/vg_root/lv_root
sudo resize2fs /dev/vg_root/lv_root  # ext4
# OR
sudo xfs_growfs /                     # XFS
```

**Prevention**:
```bash
# Set up log rotation
sudo cat > /etc/logrotate.d/myapp << EOF
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 www-data www-data
}
EOF

# Set up monitoring
# Add to cron (runs daily)
cat > /etc/cron.daily/disk-check << 'EOF'
#!/bin/bash
THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt $THRESHOLD ]; then
    echo "Disk usage critical: ${USAGE}%" | mail -s "Disk Alert" admin@example.com
fi
EOF
chmod +x /etc/cron.daily/disk-check
```

---

## Scenario 2: System Won't Boot After Update

**Situation**: After running system updates and rebooting, server won't boot. Stuck at "GRUB loading..." or kernel panic.

**Symptoms**:
```
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
```

**Troubleshooting Steps**:

```bash
# 1. Boot into rescue mode
# At GRUB menu, press 'e' to edit, add to kernel line:
systemd.unit=rescue.target
# OR
rd.break enforcing=0

# 2. If system boots to emergency mode:
# Check journal for errors
journalctl -xb

# 3. Check filesystem errors
dmesg | grep -i error
dmesg | grep -i failed
dmesg | grep -i ext4
```

**Solutions**:

```bash
# Solution 1: Fix /etc/fstab issues
# Boot with rd.break
mount -o remount,rw /sysroot
chroot /sysroot

# Check fstab
cat /etc/fstab
# Comment out problematic entries
vi /etc/fstab

# Test fstab
mount -a

exit
reboot

# Solution 2: Repair filesystem
# Boot into rescue mode
fsck -y /dev/sda1
# For XFS:
xfs_repair /dev/sda1

# Solution 3: Rebuild initramfs
chroot /mnt/sysimage  # If using rescue disk
dracut --force        # Rebuild initramfs
# OR
mkinitramfs -o /boot/initramfs-$(uname -r).img $(uname -r)

# Solution 4: Fix broken package updates
chroot /mnt/sysimage
dnf distro-sync --nobest
# OR
apt --fix-broken install

# Solution 5: Restore old kernel
# At GRUB menu, select "Advanced options"
# Boot with previous kernel

# Make old kernel default:
grubby --set-default /boot/vmlinuz-OLD-VERSION
# OR edit /etc/default/grub:
GRUB_DEFAULT=saved
grub2-mkconfig -o /boot/grub2/grub.cfg

# Solution 6: SELinux preventing boot
# Boot with: enforcing=0
# Then relabel filesystem:
touch /.autorelabel
reboot
```

**Prevention**:
```bash
# Always keep 2-3 old kernels
# /etc/dnf/dnf.conf or /etc/yum.conf
installonly_limit=3

# Before critical updates:
# 1. Take VM snapshot
# 2. Test in staging first
# 3. Have rescue media ready
# 4. Document rollback plan
```

---

## Scenario 3: Runaway Process Consuming CPU

**Situation**: System extremely slow. Load average 15.0 on 4-core system. Users complaining about application timeouts.

**Symptoms**:
```bash
top
load average: 15.32, 12.45, 8.23
%Cpu(s): 98.5 us,  1.2 sy,  0.0 ni,  0.3 id

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 5432 www-data  20   0  856432 124532  12456 R  387.2  3.1  125:32.12 php-fpm
```

**Troubleshooting Steps**:

```bash
# 1. Identify CPU hog
top
# Press: 'P' to sort by CPU, '1' to show all CPUs

htop  # More user-friendly

# 2. Check process details
ps -p 5432 -o pid,ppid,cmd,%cpu,%mem,start,etime
pstree -p 5432

# 3. Check what the process is doing
strace -p 5432 2>&1 | head -50
lsof -p 5432

# 4. Check system load
uptime
cat /proc/loadavg
w

# 5. Check for I/O wait
iostat -x 1 5
iotop -o
```

**Solutions**:

```bash
# Solution 1: Gracefully stop the process
kill -TERM 5432
# Wait 10 seconds
sleep 10
# If still running, force kill
kill -KILL 5432

# Solution 2: Reduce process priority (if needed to run)
renice -n 19 -p 5432  # Lowest priority

# Solution 3: Limit CPU usage with cpulimit
# Install: apt install cpulimit
cpulimit -p 5432 -l 50  # Limit to 50% of one CPU

# Solution 4: Use systemd to limit resources
cat > /etc/systemd/system/myapp.service.d/limits.conf << EOF
[Service]
CPUQuota=50%
MemoryMax=512M
EOF
systemctl daemon-reload
systemctl restart myapp

# Solution 5: Find root cause
# Check application logs
tail -f /var/log/myapp/error.log

# Check for infinite loops
strace -p 5432 -c  # Count syscalls
# If same syscall repeating: likely infinite loop

# Check database queries
mysqladmin processlist
mysql -e "SHOW FULL PROCESSLIST;"

# Solution 6: Restart application service
systemctl restart php-fpm
# OR
systemctl restart apache2
```

**Prevention**:
```bash
# Configure resource limits
cat >> /etc/security/limits.conf << EOF
www-data soft nproc 100
www-data hard nproc 150
www-data soft cpu 60
www-data hard cpu 120
EOF

# Set up monitoring alerts
# Add to monitoring (Prometheus, Nagios, etc.)
# Alert if load average > (CPU cores * 1.5)

# Application-level fixes:
# 1. Fix inefficient code/queries
# 2. Add caching
# 3. Implement rate limiting
# 4. Scale horizontally
```

---

## Scenario 6: Website Down - Cannot Connect

**Situation**: Users report website is down. Can't access http://example.com

**Troubleshooting Steps**:

```bash
# 1. Check if service is running
systemctl status apache2    # or httpd, nginx
systemctl status nginx

# 2. Check if ports are listening
ss -tuln | grep :80
ss -tuln | grep :443
netstat -tuln | grep -E ':(80|443)'

# 3. Test local connectivity
curl -I http://localhost
curl -I http://127.0.0.1
wget -O /dev/null http://localhost

# 4. Check firewall
firewall-cmd --list-all
iptables -L -n -v
ufw status

# 5. Check application errors
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log
journalctl -u apache2 -f

# 6. Check DNS
dig example.com
nslookup example.com
host example.com

# 7. Check network connectivity
ping example.com
traceroute example.com
mtr example.com

# 8. Check configuration
apachectl configtest
nginx -t

# 9. Check disk space
df -h /var
df -h /

# 10. Check for SELinux denials
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log
```

**Solutions**:

```bash
# Solution 1: Service stopped
sudo systemctl start apache2
sudo systemctl enable apache2  # Ensure starts on boot

# Solution 2: Configuration error
# Check syntax
sudo nginx -t
sudo apachectl configtest

# Fix configuration
sudo vi /etc/nginx/nginx.conf
# Test again
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Solution 3: Port already in use
sudo lsof -i :80
sudo kill -9 <PID>
sudo systemctl start apache2

# Solution 4: Firewall blocking
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload

# OR with iptables
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables-save

# OR with ufw
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Solution 5: SELinux blocking
# Check denials
sudo ausearch -m avc -ts recent

# Allow HTTP network connect
sudo setsebool -P httpd_can_network_connect on

# Restore contexts
sudo restorecon -Rv /var/www/html

# Solution 6: DNS issues
# Check /etc/hosts
echo "YOUR_SERVER_IP example.com" | sudo tee -a /etc/hosts

# Flush DNS cache
sudo systemd-resolve --flush-caches
# OR
sudo /etc/init.d/nscd restart

# Solution 7: SSL certificate issues
# Check certificate
openssl s_client -connect example.com:443

# Renew Let's Encrypt
sudo certbot renew
sudo systemctl reload nginx

# Solution 8: Resource exhaustion
# Check MaxClients/worker_connections
# Apache:
grep MaxRequestWorkers /etc/apache2/mods-enabled/mpm_prefork.conf

# Nginx:
grep worker_connections /etc/nginx/nginx.conf

# Increase if needed
sudo vi /etc/nginx/nginx.conf
# worker_connections 2048;
sudo systemctl reload nginx
```

---

## Scenario 11: Suspected Server Compromise

**Situation**: Unusual network traffic detected. Server sending spam emails. Unknown processes running.

**Immediate Actions**:

```bash
# 1. ISOLATE THE SYSTEM
# Disconnect from network (if possible without losing access)
sudo ip link set eth0 down  # If you have console access

# OR block outbound traffic
sudo iptables -P OUTPUT DROP
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.1.0/24 -j ACCEPT  # Allow local network

# 2. Preserve evidence BEFORE making changes
# Create forensic copy
dd if=/dev/sda of=/mnt/external/evidence.img bs=4M
# Or at minimum:
tar -czf /mnt/backup/evidence-$(date +%F).tar.gz \
  /var/log /etc /home /root/.bash_history

# 3. Document everything
script /root/investigation-$(date +%F).log
```

**Investigation Steps**:

```bash
# 1. Check for suspicious processes
ps auxf
top
htop
pstree -p

# Look for:
# - Unknown process names
# - Processes running as unexpected users
# - High CPU/network usage

# 2. Check network connections
ss -tunap
netstat -tunap
lsof -i

# Look for:
# - Connections to unknown IPs
# - Unusual ports
# - Many ESTABLISHED connections

# 3. Check listening ports
ss -tuln
netstat -tuln

# Compare against known services

# 4. Check for rootkits
sudo apt install rkhunter chkrootkit
sudo rkhunter --check
sudo chkrootkit

# 5. Check for backdoor users
cat /etc/passwd
awk -F: '$3 == 0 {print $1}' /etc/passwd  # UID 0 users
lastlog
last
who

# 6. Check sudo access
cat /etc/sudoers
cat /etc/sudoers.d/*

# 7. Check cron jobs
crontab -l
sudo crontab -l
ls -la /etc/cron.*
cat /etc/crontab
for user in $(cut -f1 -d: /etc/passwd); do
    echo "=== $user ==="
    sudo crontab -u $user -l 2>/dev/null
done

# 8. Check for suspicious files
find / -name "*.php" -mtime -7  # PHP files modified in last week
find /tmp -type f -exec file {} \; | grep "executable"
find / -perm -4000 -user root  # SUID files

# 9. Check bash history
cat /root/.bash_history
cat /home/*/.bash_history

# Look for:
# - wget/curl commands
# - chmod commands
# - User creation
# - Firewall changes

# 10. Check logs
tail -1000 /var/log/auth.log | grep -i "failed\|failure"
tail -1000 /var/log/secure | grep -i "failed\|failure"
journalctl -u sshd | grep -i "accepted\|failed"
grep -r "COMMAND=" /var/log/auth.log  # sudo commands

# 11. Check for malware
sudo apt install clamav
sudo freshclam
sudo clamscan -r /home /var/www /tmp

# 12. Check web server for shells
find /var/www -name "*.php" -o -name "*.jsp" | xargs grep -l "eval\|base64_decode\|shell_exec\|system"

# 13. Check for crypto miners
ps aux | grep -E "xmrig|minerd|cpuminer"
lsof -i | grep -E ":3333|:4444|:5555"  # Common mining ports
```

**Remediation**:

```bash
# 1. Kill malicious processes
kill -9 <PID>
pkill -9 malicious_process

# 2. Remove malicious files
rm -rf /path/to/malware
shred -vfz -n 10 /path/to/sensitive/malware  # Secure delete

# 3. Remove backdoor users
userdel -r suspicious_user

# 4. Remove unauthorized SSH keys
for home in /root /home/*; do
    echo "=== $home ==="
    cat $home/.ssh/authorized_keys
done
# Remove suspicious entries
vi /root/.ssh/authorized_keys
vi /home/user/.ssh/authorized_keys

# 5. Change all passwords
passwd root
for user in $(cut -f1 -d: /etc/passwd); do
    echo "Changing password for $user"
    passwd $user
done

# 6. Update all software
sudo apt update && sudo apt upgrade -y
sudo dnf update -y

# 7. Harden SSH
sudo vi /etc/ssh/sshd_config
# Changes:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers admin deploy

sudo systemctl restart sshd

# 8. Configure fail2ban
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 9. Set up AIDE (file integrity monitoring)
sudo apt install aide
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Add to cron
echo "0 3 * * * /usr/bin/aide --check | mail -s 'AIDE Report' admin@example.com" | sudo crontab -

# 10. Review and restrict firewall
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --reload
```

**Prevention**:
```bash
# 1. Regular updates
sudo apt install unattended-upgrades  # Ubuntu/Debian
sudo dnf install dnf-automatic        # RHEL/CentOS
sudo systemctl enable --now dnf-automatic.timer

# 2. Intrusion detection
sudo apt install ossec-hids

# 3. Log monitoring
sudo apt install logwatch
# Configure to email daily reports

# 4. Regular security audits
sudo lynis audit system

# 5. Backup regularly
# See linux-17-backup-recovery.md

# 6. Principle of least privilege
# Only give necessary permissions
# Use sudo instead of root login
# Implement 2FA for SSH
```

---

## Scenario 16: Database Server Slow Queries

**Situation**: MySQL database responding slowly. Queries timing out. Application reports database connection errors.

**Investigation**:

```bash
# 1. Check database status
mysql -u root -p
SHOW STATUS;
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

# 2. Check for long-running queries
SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST 
WHERE COMMAND != 'Sleep' 
AND TIME > 30 
ORDER BY TIME DESC;

# 3. Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SHOW VARIABLES LIKE 'slow_query_log%';

# 4. Check slow query log
sudo tail -f /var/log/mysql/mysql-slow.log

# 5. Check table locks
SHOW OPEN TABLES WHERE In_use > 0;

# 6. Check InnoDB status
SHOW ENGINE INNODB STATUS\G

# 7. Check system resources
top
htop
iostat -x 1
iotop -o

# 8. Check MySQL configuration
cat /etc/mysql/my.cnf
cat /etc/my.cnf.d/server.cnf
```

**Solutions**:

```bash
# Solution 1: Kill long-running queries
# In MySQL:
SHOW PROCESSLIST;
KILL <query_id>;

# Solution 2: Optimize problematic queries
# Analyze slow query
EXPLAIN SELECT * FROM large_table WHERE column = 'value';

# Add index if missing
CREATE INDEX idx_column ON large_table(column);

# Solution 3: Optimize tables
OPTIMIZE TABLE large_table;
ANALYZE TABLE large_table;

# Solution 4: Increase MySQL resources
# Edit /etc/mysql/my.cnf or /etc/my.cnf.d/server.cnf
[mysqld]
innodb_buffer_pool_size = 2G     # 70-80% of RAM for dedicated DB server
max_connections = 200
query_cache_size = 128M
tmp_table_size = 128M
max_heap_table_size = 128M
innodb_log_file_size = 512M

# Restart MySQL
sudo systemctl restart mysql

# Solution 5: Fix table corruption
CHECK TABLE tablename;
REPAIR TABLE tablename;

# Solution 6: Partition large tables
ALTER TABLE large_table
PARTITION BY RANGE (YEAR(date_column)) (
    PARTITION p0 VALUES LESS THAN (2023),
    PARTITION p1 VALUES LESS THAN (2024),
    PARTITION p2 VALUES LESS THAN (2025),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);

# Solution 7: Set up query cache
[mysqld]
query_cache_type = 1
query_cache_limit = 2M
query_cache_size = 128M

# Solution 8: Connection pooling
# Configure application to use connection pooling
# Example in PHP:
# pdo.attr.persistent = 1
```

**Performance Tuning**:

```bash
# Use mysqltuner
wget http://mysqltuner.pl/ -O mysqltuner.pl
chmod +x mysqltuner.pl
sudo ./mysqltuner.pl

# Follow recommendations
# Example output:
# [!!] Maximum reached memory usage: 2.1G (107.89% of installed RAM)
# [!!] Maximum possible memory usage: 2.5G (128.42% of installed RAM)
# [OK] Slow queries: 0% (12/15K)
# [!!] Highest usage of available connections: 92% (184/200)

# Implement fixes based on output
```

---

*This document contains 25 comprehensive real-world scenarios covering system administration, networking, security, performance, and disaster recovery. Each scenario includes symptoms, troubleshooting steps, multiple solutions, and prevention strategies based on actual production incidents.*

---

## Summary: Most Common Production Issues

**Top 10 Critical Scenarios Every Admin Must Know**:

1. ✅ Disk space crisis (occurs monthly)
2. ✅ Website down / service not responding (occurs weekly)
3. ✅ System won't boot (occurs after updates)
4. ✅ Runaway process / high CPU (occurs weekly)
5. ✅ Database slow queries (occurs daily)
6. ✅ Memory exhaustion / OOM killer (occurs monthly)
7. ✅ SSH access broken (critical emergency)
8. ✅ SELinux blocking application (RHEL/CentOS daily)
9. ✅ Suspected compromise (rare but critical)
10. ✅ Network connectivity issues (varies)

**Essential Troubleshooting Commands to Memorize**:
```bash
# System resources
top, htop, free -h, df -h, du -h, uptime

# Processes
ps aux, pgrep, pkill, kill, nice, renice

# Network
ss -tuln, ip addr, ip route, ping, curl, dig

# Logs
journalctl, tail -f /var/log/*, dmesg, ausearch

# Services
systemctl status, systemctl restart, systemctl enable

# Storage
lsblk, fdisk -l, lvs, vgs, pvs, mount
```

Master these scenarios and you'll handle 95% of production issues with confidence! 🚀
