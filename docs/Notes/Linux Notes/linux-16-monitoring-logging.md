# Linux 16 – System Monitoring, Logging & Observability

## 0. Goal of This Note

- Monitor system resources (CPU, memory, disk, network).  
- Master logging with systemd journal and rsyslog.  
- Set up monitoring tools (Prometheus, Grafana).  
- Analyze logs effectively.  
- Implement alerting and log rotation.

---

## 1. Real-Time System Monitoring

### 1.1 Essential Monitoring Commands

**top – Interactive process viewer:**
```bash
top                              # basic view

# Inside top:
# 1 - show individual CPUs
# M - sort by memory
# P - sort by CPU
# k - kill process
# r - renice process
# h - help
# q - quit

# Run with options
top -u username                  # filter by user
top -p 1234                      # specific PID
top -b -n 1 > output.txt         # batch mode (for scripts)
```

**htop – Better interactive viewer:**
```bash
sudo apt install htop
htop

# Inside htop:
# F2 - setup
# F3 - search
# F4 - filter
# F5 - tree view
# F6 - sort by column
# F9 - kill
# F10 - quit
```

**vmstat – Virtual memory statistics:**
```bash
vmstat                           # one snapshot
vmstat 2                         # update every 2 seconds
vmstat 2 5                       # 5 samples, 2 seconds apart

# Output columns:
# r = processes waiting for CPU
# b = processes in uninterruptible sleep
# swpd = virtual memory used
# free = idle memory
# si/so = swap in/out (should be ~0)
# bi/bo = blocks in/out
# us = user CPU time
# sy = system CPU time
# id = idle time
# wa = wait for I/O
```

**iostat – I/O statistics:**
```bash
sudo apt install sysstat
iostat                           # basic
iostat -x                        # extended
iostat -x 2                      # update every 2 seconds

# Key metrics:
# %util - device utilization (>80% = bottleneck)
# await - average wait time
# r/s, w/s - reads/writes per second
```

**iotop – I/O by process:**
```bash
sudo apt install iotop
sudo iotop                       # interactive
sudo iotop -o                    # only active processes
sudo iotop -b -n 3               # batch mode, 3 iterations
```

**mpstat – CPU statistics:**
```bash
mpstat                           # all CPUs
mpstat -P ALL                    # per-CPU breakdown
mpstat 2 5                       # 5 samples, 2 seconds
```

### 1.2 Memory Monitoring

**free – Memory usage:**
```bash
free                             # default (KB)
free -h                          # human-readable
free -m                          # MB
free -s 2                        # update every 2 seconds

# Understanding output:
# - total: installed RAM
# - used: memory in use
# - free: unused memory
# - available: memory available for new apps (includes cache)
# - buff/cache: used for buffers and cache (can be freed)
```

**/proc/meminfo – Detailed memory:**
```bash
cat /proc/meminfo
grep -E 'MemTotal|MemFree|MemAvailable|Cached|SwapTotal|SwapFree' /proc/meminfo
```

**smem – Memory by process:**
```bash
sudo apt install smem
smem -tk                         # totals in KB
smem -r                          # reverse sort (highest first)
smem -u                          # by user
```

### 1.3 Disk Monitoring

**df – Disk free space:**
```bash
df                               # all filesystems
df -h                            # human-readable
df -h /home                      # specific filesystem
df -i                            # inode usage
df -T                            # show filesystem type
```

**du – Disk usage:**
```bash
du -sh /var                      # summary
du -h /var                       # detailed
du -h --max-depth=1 /var         # one level deep
du -ah /var | sort -rh | head -20  # top 20 largest

# Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

**ncdu – Interactive disk usage:**
```bash
sudo apt install ncdu
ncdu /var                        # analyze /var
# Navigate with arrows, d to delete
```

### 1.4 Network Monitoring

**iftop – Network bandwidth by connection:**
```bash
sudo apt install iftop
sudo iftop
sudo iftop -i eth0               # specific interface
```

**nethogs – Bandwidth by process:**
```bash
sudo apt install nethogs
sudo nethogs
sudo nethogs eth0
```

**nload – Total bandwidth:**
```bash
sudo apt install nload
nload
nload eth0
```

**ss – Socket statistics (modern netstat):**
```bash
ss -tuln                         # TCP/UDP listening
ss -tulpn                        # with process names
ss -s                            # summary statistics
ss -o state established          # established connections
```

**iftop, iptraf, bmon – More options:**
```bash
sudo apt install iptraf-ng bmon
sudo iptraf-ng
bmon
```

---

## 2. System Logging

### 2.1 systemd Journal (journalctl)

**View logs:**
```bash
# Recent logs
journalctl

# Follow (tail -f style)
journalctl -f

# Since boot
journalctl -b
journalctl -b -1                 # previous boot

# Time range
journalctl --since "2023-01-01"
journalctl --since "1 hour ago"
journalctl --since "2023-01-01 10:00" --until "2023-01-01 12:00"
journalctl --since today
journalctl --since yesterday

# Specific service
journalctl -u nginx.service
journalctl -u nginx -f           # follow nginx logs

# Priority levels
journalctl -p err                # errors only
journalctl -p warning            # warnings and above

# By PID or UID
journalctl _PID=1234
journalctl _UID=1000

# Kernel messages
journalctl -k
journalctl -k -b                 # kernel messages this boot

# Reverse order (newest first)
journalctl -r

# Output formats
journalctl -o json               # JSON
journalctl -o json-pretty
journalctl -o verbose

# Disk usage
journalctl --disk-usage

# Verify integrity
journalctl --verify
```

**Manage journal size:**
```bash
# Rotate logs
sudo journalctl --rotate

# Vacuum by size
sudo journalctl --vacuum-size=500M

# Vacuum by time
sudo journalctl --vacuum-time=30d

# Configure limits (/etc/systemd/journald.conf)
sudo vim /etc/systemd/journald.conf

# Uncomment and set:
SystemMaxUse=500M
SystemMaxFileSize=100M
SystemMaxFiles=10
MaxRetentionSec=1month

# Restart journald
sudo systemctl restart systemd-journald
```

### 2.2 Traditional Syslog (rsyslog)

**Log files:**
```bash
/var/log/syslog                  # general system (Debian/Ubuntu)
/var/log/messages                # general system (RHEL/Fedora)
/var/log/auth.log                # authentication
/var/log/kern.log                # kernel
/var/log/apache2/                # Apache logs
/var/log/nginx/                  # Nginx logs
```

**rsyslog configuration:**
```bash
# Main config
/etc/rsyslog.conf

# Additional configs
/etc/rsyslog.d/*.conf

# Example rule:
# facility.priority  action
mail.*              /var/log/mail.log
*.emerg             :omusrmsg:*
cron.*              /var/log/cron.log

# Facilities: auth, cron, daemon, kern, mail, user, local0-7
# Priorities: emerg, alert, crit, err, warning, notice, info, debug
```

**Remote logging:**
```bash
# Send to remote syslog server
# In /etc/rsyslog.conf:
*.* @remote-server:514           # UDP
*.* @@remote-server:514          # TCP

# Restart rsyslog
sudo systemctl restart rsyslog
```

### 2.3 Log Rotation

**logrotate configuration:**
```bash
# Main config
/etc/logrotate.conf

# Service-specific configs
/etc/logrotate.d/

# Example: /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily                        # rotate daily
    missingok                    # don't error if missing
    rotate 14                    # keep 14 old logs
    compress                     # gzip old logs
    delaycompress                # compress on next rotation
    notifempty                   # don't rotate if empty
    create 0640 www-data adm     # permissions for new log
    sharedscripts                # run scripts once for all logs
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}

# Test logrotate
sudo logrotate -d /etc/logrotate.conf  # dry run
sudo logrotate -f /etc/logrotate.conf  # force rotation
```

---

## 3. Performance Analysis Tools

### 3.1 strace – System call tracer

```bash
# Trace process
strace ls                        # trace ls command
strace -p 1234                   # attach to PID
strace -c ls                     # summary statistics
strace -e open ls                # trace specific syscalls
strace -e trace=network curl example.com  # network calls only
strace -o output.txt command     # save to file
```

### 3.2 lsof – List open files

```bash
# List all open files
sudo lsof

# Files opened by process
lsof -p 1234

# Processes using file
lsof /var/log/syslog

# Network connections
lsof -i                          # all network
lsof -i :80                      # port 80
lsof -i tcp                      # TCP only
lsof -i @192.168.1.10            # connections to IP

# Files opened by user
lsof -u username

# Files in directory
lsof +D /var/www
```

### 3.3 perf – Performance analysis

```bash
# Install
sudo apt install linux-tools-generic

# Record system activity
sudo perf record -a -g sleep 10  # 10 seconds, all CPUs

# View report
sudo perf report

# Top functions
sudo perf top

# Specific command
sudo perf record -g -- command
sudo perf report
```

### 3.4 sar – System Activity Report

```bash
# Collect data (runs via cron)
sudo apt install sysstat
sudo systemctl enable sysstat

# View CPU usage
sar                              # today's data
sar -u                           # CPU utilization
sar -u 2 5                       # 5 samples, 2 seconds

# Memory
sar -r                           # memory usage
sar -r ALL                       # all memory stats

# I/O
sar -b                           # I/O stats
sar -d                           # disk stats

# Network
sar -n DEV                       # network devices
sar -n EDEV                      # errors

# Historical data
sar -u -f /var/log/sysstat/sa10  # specific day
sar -u -s 10:00:00 -e 12:00:00   # time range
```

---

## 4. Modern Monitoring Stack

### 4.1 Prometheus (Time-Series DB)

**Installation (Docker):**
```yaml
# docker-compose.yml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"

volumes:
  prometheus-data:
```

**Prometheus config (prometheus.yml):**
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

### 4.2 Grafana (Visualization)

```yaml
# Add to docker-compose.yml
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
```

**Setup:**
1. Access: http://localhost:3000 (admin/admin)
2. Add Prometheus data source: http://prometheus:9090
3. Import dashboard: ID 1860 (Node Exporter Full)

---

## 5. Log Analysis

### 5.1 Analyzing Logs with grep/awk/sed

```bash
# Find errors
grep -i error /var/log/syslog
grep -E 'error|warning|critical' /var/log/syslog

# Count occurrences
grep -c "Failed password" /var/log/auth.log

# Extract IPs from failed logins
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Top 10 HTTP status codes
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# Requests per hour
awk '{print $4}' /var/log/nginx/access.log | cut -d: -f1-2 | sort | uniq -c

# Slow queries (>1 second response)
awk '$NF > 1.0 {print $0}' /var/log/nginx/access.log
```

### 5.2 Log Management Tools

**lnav – Log file navigator:**
```bash
sudo apt install lnav
lnav /var/log/syslog /var/log/auth.log
# Interactive viewer with syntax highlighting
```

**multitail – Multiple logs:**
```bash
sudo apt install multitail
multitail /var/log/syslog /var/log/auth.log
```

**goaccess – Web log analyzer:**
```bash
sudo apt install goaccess
goaccess /var/log/nginx/access.log -o report.html --log-format=COMBINED
```

---

## 6. Alerting

### 6.1 Simple Email Alerts

```bash
# Install mail utilities
sudo apt install mailutils

# Monitor disk space
#!/bin/bash
# /usr/local/bin/check_disk.sh
THRESHOLD=90
USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "Disk usage is at ${USAGE}%" | mail -s "Disk Alert" admin@example.com
fi

# Cron job (every hour)
0 * * * * /usr/local/bin/check_disk.sh
```

### 6.2 Prometheus Alertmanager

**alertmanager.yml:**
```yaml
route:
  receiver: 'email'

receivers:
  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
        from: 'alerts@example.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'your@gmail.com'
        auth_password: 'app_password'
```

---

## 7. Practice Exercises

1. **Monitoring:**
   - Use `htop` to find highest CPU/memory process
   - Monitor disk I/O with `iostat`
   - Find network hogs with `nethogs`
   - Analyze with `sar`

2. **Logging:**
   - View nginx errors from last hour with `journalctl`
   - Set up log rotation for custom application
   - Configure remote logging to central server
   - Extract top IPs from access logs

3. **Performance:**
   - Use `strace` to debug slow command
   - Find open files with `lsof`
   - Monitor specific port connections
   - Analyze with `perf`

4. **Monitoring Stack:**
   - Deploy Prometheus + Grafana with Docker
   - Add node exporter
   - Create custom dashboard
   - Set up disk space alert

Next: **Linux 17 – Backup, Recovery & Disaster Planning** for data protection.
