# Hands-On Lab Exercises

Practical lab exercises to build real-world Linux skills. Each lab includes objectives, prerequisites, step-by-step instructions, verification, and solutions.

---

## Lab Structure

Each lab follows this format:
- **Objective**: What you'll learn
- **Difficulty**: Beginner / Intermediate / Advanced / Expert
- **Time**: Estimated completion time
- **Prerequisites**: Required knowledge/setup
- **Scenario**: Real-world context
- **Tasks**: Step-by-step exercises
- **Verification**: How to check your work
- **Solution**: Detailed solution with explanations
- **Troubleshooting**: Common issues and fixes

---

## Table of Contents

### **Beginner Labs (1-10)**
1. [System Setup and Navigation](#lab-1-system-setup-and-navigation)
2. [User and Permission Management](#lab-2-user-and-permission-management)
3. [File Operations and Text Processing](#lab-3-file-operations-and-text-processing)
4. [Process Management](#lab-4-process-management)
5. [Basic Networking Configuration](#lab-5-basic-networking-configuration)
6. [Package Management](#lab-6-package-management)
7. [Basic Bash Scripting](#lab-7-basic-bash-scripting)
8. [Systemd Service Management](#lab-8-systemd-service-management)
9. [Basic Firewall Configuration](#lab-9-basic-firewall-configuration)
10. [Log Analysis and Monitoring](#lab-10-log-analysis-and-monitoring)

### **Intermediate Labs (11-20)**
11. [LVM Storage Management](#lab-11-lvm-storage-management)
12. [Advanced Networking with Static Routes](#lab-12-advanced-networking-with-static-routes)
13. [SSH Hardening and Key Management](#lab-13-ssh-hardening-and-key-management)
14. [Web Server Setup (Apache + SSL)](#lab-14-web-server-setup-apache--ssl)
15. [Automated Backup Solution](#lab-15-automated-backup-solution)
16. [SELinux Configuration](#lab-16-selinux-configuration)
17. [Advanced Bash Scripting with Error Handling](#lab-17-advanced-bash-scripting-with-error-handling)
18. [Performance Tuning](#lab-18-performance-tuning)
19. [LDAP Authentication](#lab-19-ldap-authentication)
20. [Network Troubleshooting](#lab-20-network-troubleshooting)

### **Advanced Labs (21-30)**
21. [Docker Multi-Container Application](#lab-21-docker-multi-container-application)
22. [Kubernetes Deployment](#lab-22-kubernetes-deployment)
23. [Ansible Playbook for LAMP Stack](#lab-23-ansible-playbook-for-lamp-stack)
24. [MySQL Replication Setup](#lab-24-mysql-replication-setup)
25. [PostgreSQL Streaming Replication](#lab-25-postgresql-streaming-replication)
26. [LUKS Disk Encryption](#lab-26-luks-disk-encryption)
27. [OpenVPN Server Setup](#lab-27-openvpn-server-setup)
28. [Security Audit and Hardening](#lab-28-security-audit-and-hardening)
29. [Samba File Server with AD Integration](#lab-29-samba-file-server-with-ad-integration)
30. [Complete Infrastructure as Code](#lab-30-complete-infrastructure-as-code)

---

# Beginner Labs

## Lab 1: System Setup and Navigation

**Objective**: Master Linux filesystem navigation and basic commands  
**Difficulty**: Beginner  
**Time**: 45 minutes  
**Prerequisites**: Linux system (VM, WSL, or physical machine)

### Scenario
You've just been hired as a junior Linux administrator. Your first task is to familiarize yourself with the system, navigate directories, and create a proper workspace structure.

### Tasks

#### Task 1.1: System Information
```bash
# Gather system information
hostnamectl                    # System hostname and OS info
uname -a                       # Kernel version
lsb_release -a                 # Distribution info (if available)
cat /etc/os-release            # OS release information
uptime                         # System uptime and load
df -h                          # Disk space usage
free -h                        # Memory usage
```

**Questions to answer**:
1. What distribution and version are you running?
2. What kernel version is installed?
3. How much total RAM does the system have?
4. What is the system uptime?

#### Task 1.2: Directory Navigation
```bash
# Navigate filesystem hierarchy
pwd                            # Print working directory
cd /                           # Go to root
ls -la                         # List all files with details
cd /etc                        # Navigate to /etc
ls -lh | head -20              # List first 20 files
cd /var/log                    # Go to log directory
ls -lhtr | tail -10            # List 10 newest files
cd ~                           # Return to home directory
pwd                            # Verify location
```

**Create this directory structure**:
```
~/workspace/
├── projects/
│   ├── scripts/
│   ├── configs/
│   └── docs/
├── backups/
└── temp/
```

**Commands**:
```bash
cd ~
mkdir -p workspace/{projects/{scripts,configs,docs},backups,temp}
tree workspace/               # Or use ls -R if tree not available
```

#### Task 1.3: File Operations
```bash
# Create files and practice operations
cd ~/workspace/projects/docs

# Create a system info file
echo "System Information Report" > sysinfo.txt
echo "=======================" >> sysinfo.txt
hostnamectl >> sysinfo.txt
echo "" >> sysinfo.txt
echo "Disk Usage:" >> sysinfo.txt
df -h >> sysinfo.txt

# View the file
cat sysinfo.txt
less sysinfo.txt              # Press 'q' to exit

# Copy, move, rename
cp sysinfo.txt sysinfo-backup.txt
mv sysinfo-backup.txt ~/workspace/backups/
ls -l ~/workspace/backups/

# Create symbolic link
ln -s ~/workspace/backups/sysinfo-backup.txt ~/workspace/sysinfo-link.txt
ls -l ~/workspace/sysinfo-link.txt
```

#### Task 1.4: Finding Files
```bash
# Find commands
find /etc -name "*.conf" 2>/dev/null | head -10
find ~ -type f -name "sysinfo*"
find ~ -type d -name "scripts"
which bash
which python3
whereis ls
locate sysinfo 2>/dev/null || updatedb && locate sysinfo
```

### Verification
```bash
# Run these commands to verify your work
test -d ~/workspace/projects/scripts && echo "✓ Directory structure created" || echo "✗ Missing directories"
test -f ~/workspace/projects/docs/sysinfo.txt && echo "✓ sysinfo.txt created" || echo "✗ File missing"
test -L ~/workspace/sysinfo-link.txt && echo "✓ Symbolic link created" || echo "✗ Link missing"
test -f ~/workspace/backups/sysinfo-backup.txt && echo "✓ Backup created" || echo "✗ Backup missing"
```

### Solution Summary
```bash
# Complete solution script
#!/bin/bash
# Lab 1 Solution

# System information
echo "=== System Information ==="
hostnamectl
uname -a
free -h
df -h

# Create directory structure
mkdir -p ~/workspace/{projects/{scripts,configs,docs},backups,temp}

# Create and populate sysinfo file
cd ~/workspace/projects/docs
{
  echo "System Information Report"
  echo "======================="
  hostnamectl
  echo ""
  echo "Disk Usage:"
  df -h
} > sysinfo.txt

# File operations
cp sysinfo.txt sysinfo-backup.txt
mv sysinfo-backup.txt ~/workspace/backups/
ln -s ~/workspace/backups/sysinfo-backup.txt ~/workspace/sysinfo-link.txt

echo "✓ Lab 1 completed successfully"
```

### Troubleshooting
- **"Permission denied"**: Use `sudo` for system directories or work in your home directory
- **"tree: command not found"**: Install with `sudo apt install tree` or use `ls -R`
- **Symbolic link broken**: Check if source file exists, use absolute paths

---

## Lab 2: User and Permission Management

**Objective**: Create users, manage groups, and configure file permissions  
**Difficulty**: Beginner  
**Time**: 60 minutes  
**Prerequisites**: Sudo access, Lab 1 completed

### Scenario
Your company is onboarding 3 developers and 2 operations staff. You need to create user accounts, organize them into groups, and set up proper file permissions for shared project directories.

### Tasks

#### Task 2.1: Create Users and Groups
```bash
# Create groups
sudo groupadd developers
sudo groupadd operations
sudo groupadd projectx

# Create users
sudo useradd -m -s /bin/bash -c "Alice Developer" -G developers,projectx alice
sudo useradd -m -s /bin/bash -c "Bob Developer" bob
sudo useradd -m -s /bin/bash -c "Charlie Ops" -G operations charlie
sudo useradd -m -s /bin/bash -c "Diana Ops" diana
sudo useradd -m -s /bin/bash -c "Eve Developer" eve

# Set passwords (use 'Password123!' for lab)
echo "alice:Password123!" | sudo chpasswd
echo "bob:Password123!" | sudo chpasswd
echo "charlie:Password123!" | sudo chpasswd
echo "diana:Password123!" | sudo chpasswd
echo "eve:Password123!" | sudo chpasswd

# Add users to groups
sudo usermod -aG developers bob
sudo usermod -aG developers,projectx eve
sudo usermod -aG operations diana
sudo usermod -aG projectx charlie

# Verify users and groups
id alice
groups alice
getent group developers
getent group operations
getent group projectx
```

#### Task 2.2: Create Shared Directories
```bash
# Create project directories
sudo mkdir -p /projects/{shared,developers-only,operations-only,projectx}
sudo mkdir -p /projects/shared/{docs,scripts,configs}

# Set ownership and permissions
# Shared directory - readable by all, writable by developers and ops
sudo chown root:root /projects/shared
sudo chmod 755 /projects/shared
sudo chown -R root:developers /projects/shared/{docs,scripts}
sudo chown -R root:operations /projects/shared/configs
sudo chmod -R 775 /projects/shared/{docs,scripts,configs}

# Developers-only directory
sudo chown root:developers /projects/developers-only
sudo chmod 770 /projects/developers-only

# Operations-only directory
sudo chown root:operations /projects/operations-only
sudo chmod 770 /projects/operations-only

# ProjectX directory - only for projectx group members
sudo chown root:projectx /projects/projectx
sudo chmod 770 /projects/projectx

# Set SGID bit so new files inherit group
sudo chmod g+s /projects/shared/{docs,scripts,configs}
sudo chmod g+s /projects/developers-only
sudo chmod g+s /projects/operations-only
sudo chmod g+s /projects/projectx
```

#### Task 2.3: Test Permissions
```bash
# Test as alice (developer + projectx member)
sudo su - alice
whoami
groups
cd /projects/developers-only && touch alice-test.txt && ls -l
cd /projects/projectx && touch alice-project.txt && ls -l
cd /projects/operations-only  # Should fail
exit

# Test as charlie (operations + projectx member)
sudo su - charlie
cd /projects/operations-only && touch charlie-test.txt && ls -l
cd /projects/projectx && touch charlie-project.txt && ls -l
cd /projects/developers-only  # Should fail
exit

# Test as bob (developer only, not in projectx)
sudo su - bob
cd /projects/developers-only && touch bob-test.txt && ls -l
cd /projects/projectx  # Should fail
exit
```

#### Task 2.4: Advanced Permissions
```bash
# Create a file with special permissions
sudo mkdir /projects/shared/dropbox
sudo chown root:developers /projects/shared/dropbox
sudo chmod 1770 /projects/shared/dropbox  # Sticky bit

# Test sticky bit
sudo su - alice
cd /projects/shared/dropbox
touch alice-file.txt
exit

sudo su - bob
cd /projects/shared/dropbox
ls -l
rm alice-file.txt  # Should fail - can only delete own files
touch bob-file.txt
rm bob-file.txt    # Should succeed
exit

# Create a setuid example (educational - not recommended in production)
sudo cp /usr/bin/cat /tmp/cat-test
sudo chmod u+s /tmp/cat-test
ls -l /tmp/cat-test  # Note the 's' in owner permissions
sudo rm /tmp/cat-test  # Clean up
```

### Verification
```bash
# Verification script
#!/bin/bash
echo "=== User Verification ==="
id alice | grep -q "developers" && echo "✓ Alice in developers group" || echo "✗ Alice not in developers"
id alice | grep -q "projectx" && echo "✓ Alice in projectx group" || echo "✗ Alice not in projectx"
id charlie | grep -q "operations" && echo "✓ Charlie in operations group" || echo "✗ Charlie not in operations"

echo -e "\n=== Directory Verification ==="
test -d /projects/shared && echo "✓ Shared directory exists" || echo "✗ Shared directory missing"
test -d /projects/developers-only && echo "✓ Developers directory exists" || echo "✗ Missing"
test -d /projects/operations-only && echo "✓ Operations directory exists" || echo "✗ Missing"
test -d /projects/projectx && echo "✓ ProjectX directory exists" || echo "✗ Missing"

echo -e "\n=== Permission Verification ==="
stat -c "%a %G" /projects/developers-only | grep -q "770 developers" && echo "✓ Correct permissions on developers-only" || echo "✗ Wrong permissions"
stat -c "%a %G" /projects/operations-only | grep -q "770 operations" && echo "✓ Correct permissions on operations-only" || echo "✗ Wrong permissions"
```

### Solution Summary
```bash
# Complete solution script
#!/bin/bash
# Lab 2 Solution - Run with sudo

# Create groups
groupadd developers operations projectx

# Create users and set passwords
for user in alice bob charlie diana eve; do
    useradd -m -s /bin/bash $user
    echo "$user:Password123!" | chpasswd
done

# Add users to groups
usermod -aG developers,projectx alice
usermod -aG developers bob
usermod -aG developers,projectx eve
usermod -aG operations charlie
usermod -aG operations diana
usermod -aG projectx charlie

# Create directory structure
mkdir -p /projects/{shared/{docs,scripts,configs},developers-only,operations-only,projectx}

# Set ownership and permissions
chown root:developers /projects/developers-only
chown root:operations /projects/operations-only
chown root:projectx /projects/projectx
chown -R root:developers /projects/shared/{docs,scripts}
chown -R root:operations /projects/shared/configs

chmod 770 /projects/{developers-only,operations-only,projectx}
chmod -R 775 /projects/shared/{docs,scripts,configs}

# Set SGID bit
chmod g+s /projects/{developers-only,operations-only,projectx}
chmod g+s /projects/shared/{docs,scripts,configs}

# Create dropbox with sticky bit
mkdir /projects/shared/dropbox
chown root:developers /projects/shared/dropbox
chmod 1770 /projects/shared/dropbox

echo "✓ Lab 2 completed successfully"
```

### Troubleshooting
- **"Permission denied"**: Ensure you're using `sudo` for user/group management
- **User can't access directory**: Check group membership with `groups username`
- **Files don't inherit group**: Verify SGID bit is set with `ls -ld directory`
- **Can delete others' files in shared directory**: Check sticky bit with `ls -ld`

---

## Lab 3: File Operations and Text Processing

**Objective**: Master grep, sed, awk, and file manipulation  
**Difficulty**: Beginner  
**Time**: 60 minutes  
**Prerequisites**: Basic command-line knowledge

### Scenario
You've been given a web server access log file and need to extract specific information, generate reports, and analyze traffic patterns.

### Tasks

#### Task 3.1: Create Sample Data
```bash
# Create a sample Apache access log
mkdir -p ~/labs/lab3
cd ~/labs/lab3

cat > access.log << 'EOF'
192.168.1.100 - - [09/Feb/2026:10:15:32 +0000] "GET /index.html HTTP/1.1" 200 2326
192.168.1.101 - - [09/Feb/2026:10:16:05 +0000] "GET /about.html HTTP/1.1" 200 1532
192.168.1.100 - - [09/Feb/2026:10:16:45 +0000] "GET /contact.html HTTP/1.1" 200 891
10.0.0.50 - - [09/Feb/2026:10:17:12 +0000] "POST /api/login HTTP/1.1" 200 145
192.168.1.102 - - [09/Feb/2026:10:17:58 +0000] "GET /products.html HTTP/1.1" 200 4532
10.0.0.50 - - [09/Feb/2026:10:18:23 +0000] "GET /api/users HTTP/1.1" 200 2891
192.168.1.100 - - [09/Feb/2026:10:19:01 +0000] "GET /admin/dashboard HTTP/1.1" 403 512
10.0.0.51 - - [09/Feb/2026:10:19:45 +0000] "GET /api/products HTTP/1.1" 500 234
192.168.1.103 - - [09/Feb/2026:10:20:12 +0000] "GET /download/file.pdf HTTP/1.1" 200 15234
192.168.1.100 - - [09/Feb/2026:10:20:58 +0000] "GET /images/logo.png HTTP/1.1" 404 178
10.0.0.50 - - [09/Feb/2026:10:21:34 +0000] "POST /api/orders HTTP/1.1" 201 456
192.168.1.104 - - [09/Feb/2026:10:22:05 +0000] "GET /search?q=linux HTTP/1.1" 200 3421
192.168.1.100 - - [09/Feb/2026:10:22:47 +0000] "GET /admin/users HTTP/1.1" 403 512
10.0.0.52 - - [09/Feb/2026:10:23:19 +0000] "GET /api/status HTTP/1.1" 500 189
192.168.1.105 - - [09/Feb/2026:10:24:01 +0000] "GET /blog/post-1 HTTP/1.1" 200 2891
EOF

# Create a CSV file for processing
cat > users.csv << 'EOF'
id,username,email,department,status
1,alice,alice@example.com,Engineering,active
2,bob,bob@example.com,Sales,active
3,charlie,charlie@example.com,Engineering,inactive
4,diana,diana@example.com,HR,active
5,eve,eve@example.com,Sales,active
6,frank,frank@example.com,Engineering,active
7,grace,grace@example.com,Marketing,inactive
8,henry,henry@example.com,Sales,active
EOF
```

#### Task 3.2: grep Exercises
```bash
# Find all GET requests
grep "GET" access.log

# Find all requests from IP 192.168.1.100
grep "192.168.1.100" access.log

# Find all 404 and 500 errors
grep -E " (404|500) " access.log

# Count occurrences
grep -c "GET" access.log
grep -c "POST" access.log

# Case-insensitive search with line numbers
grep -in "api" access.log

# Find lines that don't contain "200"
grep -v " 200 " access.log

# Recursive search in directory (if you have multiple log files)
# grep -r "ERROR" /var/log/

# Show 2 lines before and after match
grep -A 2 -B 2 "403" access.log

# Extract IP addresses only
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log
```

#### Task 3.3: sed Exercises
```bash
# Replace all "GET" with "FETCH"
sed 's/GET/FETCH/' access.log

# Replace all "GET" globally (all occurrences per line)
sed 's/GET/FETCH/g' access.log

# Delete lines containing "404"
sed '/404/d' access.log

# Print only lines 5-10
sed -n '5,10p' access.log

# Add "LOG: " prefix to each line
sed 's/^/LOG: /' access.log

# Extract just the URL path
sed -E 's/.*"[A-Z]+ ([^ ]+).*/\1/' access.log

# Replace IP addresses with "MASKED"
sed -E 's/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/MASKED/' access.log

# In-place editing (create backup)
sed -i.bak 's/HTTP\/1.1/HTTP\/2.0/g' access.log
mv access.log.bak access.log  # Restore original
```

#### Task 3.4: awk Exercises
```bash
# Print specific columns (IP and status code)
awk '{print $1, $9}' access.log

# Print with custom formatting
awk '{printf "IP: %-15s Status: %s\n", $1, $9}' access.log

# Count requests by status code
awk '{count[$9]++} END {for (code in count) print code, count[code]}' access.log

# Calculate total bytes transferred
awk '{sum+=$10} END {print "Total bytes:", sum}' access.log

# Find average bytes per request
awk '{sum+=$10; count++} END {print "Average:", sum/count}' access.log

# Filter and print (only successful requests)
awk '$9 == 200 {print $1, $7}' access.log

# Requests per IP
awk '{ip[$1]++} END {for (i in ip) print i, ip[i]}' access.log | sort -k2 -rn

# Process CSV file - print users in Engineering
awk -F',' '$4 == "Engineering" {print $2, $3}' users.csv

# Count users by department
awk -F',' 'NR>1 {dept[$4]++} END {for (d in dept) print d, dept[d]}' users.csv

# Print active users only
awk -F',' '$5 == "active" {print $2, $4}' users.csv
```

#### Task 3.5: Combined Operations
```bash
# Generate a report of API endpoints with error rates
cat access.log | \
  grep "/api/" | \
  awk '{print $7, $9}' | \
  sort | uniq -c | \
  sort -rn > api_report.txt

# Find top 5 IP addresses by request count
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5

# Extract unique URLs and count them
awk '{print $7}' access.log | sort | uniq -c | sort -rn

# Create a summary report
cat > generate_report.sh << 'SCRIPT'
#!/bin/bash
echo "=== Apache Access Log Summary ==="
echo "Total Requests: $(wc -l < access.log)"
echo "Unique IPs: $(awk '{print $1}' access.log | sort -u | wc -l)"
echo "GET Requests: $(grep -c 'GET' access.log)"
echo "POST Requests: $(grep -c 'POST' access.log)"
echo -e "\nStatus Code Distribution:"
awk '{print $9}' access.log | sort | uniq -c | sort -rn
echo -e "\nTop 3 URLs:"
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -3
echo -e "\nTop 3 IPs:"
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -3
SCRIPT

chmod +x generate_report.sh
./generate_report.sh
```

### Verification
```bash
# Check your work
test -f ~/labs/lab3/access.log && echo "✓ access.log created" || echo "✗ Missing"
test -f ~/labs/lab3/users.csv && echo "✓ users.csv created" || echo "✗ Missing"
test -f ~/labs/lab3/generate_report.sh && echo "✓ Report script created" || echo "✗ Missing"

# Test commands
echo "Testing grep..."
grep -c "200" access.log && echo "✓ grep works"

echo "Testing awk..."
awk '{sum+=$10} END {print sum}' access.log > /dev/null && echo "✓ awk works"

echo "Testing sed..."
sed 's/GET/FETCH/' access.log > /dev/null && echo "✓ sed works"
```

### Expected Outputs
```bash
# IP request count (expected)
192.168.1.100    5
10.0.0.50        3
192.168.1.101    1
...

# Status code distribution (expected)
   9 200
   2 403
   2 500
   1 201
   1 404
```

### Troubleshooting
- **"No such file or directory"**: Ensure you created the sample files
- **awk syntax errors**: Check for proper quoting and field separators
- **sed not replacing**: Add 'g' flag for global replacement
- **grep showing nothing**: Check case sensitivity with `-i` flag

---

## Lab 4: Process Management

**Objective**: Manage processes, jobs, and system resources  
**Difficulty**: Beginner  
**Time**: 45 minutes  
**Prerequisites**: Terminal access

### Scenario
You need to manage various background processes, monitor system resources, and troubleshoot a runaway process consuming CPU.

### Tasks

#### Task 4.1: Process Viewing and Monitoring
```bash
# View all processes
ps aux | head -20
ps -ef | head -20

# View process tree
pstree
ps auxf | less

# Real-time monitoring
top
# Press: '1' (show all CPUs), 'M' (sort by memory), 'P' (sort by CPU), 'k' (kill), 'q' (quit)

htop  # If available (sudo apt install htop)

# Find specific processes
ps aux | grep bash
pgrep -a bash
pidof bash

# Process information
ps -p $$  # Current shell
ps -p $$ -o pid,ppid,cmd,%cpu,%mem
cat /proc/$$/status | head -20
```

#### Task 4.2: Starting and Managing Jobs
```bash
# Create a script that runs for a while
cat > ~/labs/lab4/long_task.sh << 'EOF'
#!/bin/bash
echo "Starting long task (PID: $$)..."
for i in {1..60}; do
    echo "Working... $i/60"
    sleep 1
done
echo "Task completed!"
EOF

chmod +x ~/labs/lab4/long_task.sh

# Run in foreground (Ctrl+C to stop)
~/labs/lab4/long_task.sh

# Run in background
~/labs/lab4/long_task.sh &
jobs
jobs -l  # Show PID

# Start in foreground, then suspend and background
~/labs/lab4/long_task.sh
# Press Ctrl+Z to suspend
bg  # Continue in background
jobs

# Bring to foreground
fg %1

# Start multiple jobs
~/labs/lab4/long_task.sh > /tmp/task1.log 2>&1 &
~/labs/lab4/long_task.sh > /tmp/task2.log 2>&1 &
~/labs/lab4/long_task.sh > /tmp/task3.log 2>&1 &
jobs

# Kill a specific job
kill %2  # Kill job 2
jobs
```

#### Task 4.3: Controlling Processes
```bash
# Create a CPU-intensive process
cat > ~/labs/lab4/cpu_hog.sh << 'EOF'
#!/bin/bash
# CPU hog for testing
while true; do
    echo "scale=10000; 4*a(1)" | bc -l > /dev/null
done
EOF

chmod +x ~/labs/lab4/cpu_hog.sh

# Start CPU hog
~/labs/lab4/cpu_hog.sh &
CPU_HOG_PID=$!
echo "CPU Hog PID: $CPU_HOG_PID"

# Monitor CPU usage
top -p $CPU_HOG_PID
# Or
ps -p $CPU_HOG_PID -o pid,ppid,cmd,%cpu,%mem

# Send signals
kill -STOP $CPU_HOG_PID   # Pause (SIGSTOP)
ps -p $CPU_HOG_PID -o pid,stat,cmd

kill -CONT $CPU_HOG_PID   # Resume (SIGCONT)
ps -p $CPU_HOG_PID -o pid,stat,cmd

kill -TERM $CPU_HOG_PID   # Terminate gracefully (SIGTERM)
# If still running after a few seconds:
kill -KILL $CPU_HOG_PID   # Force kill (SIGKILL)

# Verify it's gone
ps -p $CPU_HOG_PID || echo "Process terminated"
```

#### Task 4.4: Process Priority (nice and renice)
```bash
# Start process with low priority
nice -n 19 ~/labs/lab4/cpu_hog.sh &
LOW_PID=$!
ps -p $LOW_PID -o pid,ni,cmd

# Start process with high priority (requires sudo)
sudo nice -n -10 ~/labs/lab4/cpu_hog.sh &
HIGH_PID=$!
ps -p $HIGH_PID -o pid,ni,cmd

# Change priority of running process
renice -n 10 -p $LOW_PID
ps -p $LOW_PID -o pid,ni,cmd

# Clean up
kill $LOW_PID $HIGH_PID 2>/dev/null
sudo killall cpu_hog.sh 2>/dev/null
```

#### Task 4.5: System Resource Monitoring
```bash
# CPU and load average
uptime
cat /proc/loadavg

# CPU information
lscpu
cat /proc/cpuinfo | grep "model name" | head -1
nproc  # Number of cores

# Memory usage
free -h
cat /proc/meminfo | head -10

# Disk I/O
iostat  # If available: sudo apt install sysstat
vmstat 1 5  # 5 samples, 1 second apart

# Top memory consumers
ps aux --sort=-%mem | head -10

# Top CPU consumers
ps aux --sort=-%cpu | head -10

# Process count
ps aux | wc -l
```

### Verification
```bash
# Verification script
#!/bin/bash
echo "=== Process Management Verification ==="

# Check if scripts exist
test -f ~/labs/lab4/long_task.sh && echo "✓ long_task.sh created" || echo "✗ Missing"
test -f ~/labs/lab4/cpu_hog.sh && echo "✓ cpu_hog.sh created" || echo "✗ Missing"

# Check if scripts are executable
test -x ~/labs/lab4/long_task.sh && echo "✓ long_task.sh is executable" || echo "✗ Not executable"

# Try process commands
pgrep -h > /dev/null 2>&1 && echo "✓ pgrep available" || echo "✗ pgrep not found"
nice -n 0 true && echo "✓ nice command works" || echo "✗ nice failed"
ps aux > /dev/null && echo "✓ ps command works" || echo "✗ ps failed"
```

### Solution Summary
Key commands practiced:
- **ps**: View processes (`ps aux`, `ps -ef`, `ps -p PID`)
- **top/htop**: Real-time monitoring
- **jobs**: List background jobs
- **bg/fg**: Background/foreground control
- **kill**: Send signals (`SIGTERM`, `SIGKILL`, `SIGSTOP`, `SIGCONT`)
- **nice/renice**: Process priority
- **pgrep/pkill**: Find and kill by name

### Troubleshooting
- **"Permission denied" when using nice -n -10**: Negative nice values require sudo
- **Process won't die with kill**: Try `kill -9 PID` (SIGKILL)
- **Can't find process**: Use `pgrep` or `ps aux | grep`
- **htop not found**: Install with `sudo apt install htop`

---

## Lab 5: Basic Networking Configuration

**Objective**: Configure network interfaces, DNS, and routing  
**Difficulty**: Beginner  
**Time**: 60 minutes  
**Prerequisites**: Sudo access, network access

### Scenario
You're setting up a new Linux server and need to configure static IP addressing, set up DNS resolution, and verify network connectivity.

### Tasks

#### Task 5.1: Network Interface Discovery
```bash
# List all network interfaces
ip link show
ip addr show
ifconfig -a  # If available

# Show routing table
ip route show
route -n  # If available

# Show DNS configuration
cat /etc/resolv.conf

# Network manager status
nmcli device status
nmcli connection show

# Detailed interface info
ip addr show dev eth0  # Replace eth0 with your interface
ethtool eth0  # If available: sudo apt install ethtool
```

#### Task 5.2: Temporary IP Configuration (Lost on reboot)
```bash
# Add IP address temporarily
sudo ip addr add 192.168.100.50/24 dev eth0
ip addr show dev eth0

# Add default gateway
sudo ip route add default via 192.168.100.1

# Remove IP address
sudo ip addr del 192.168.100.50/24 dev eth0

# Bring interface down/up
sudo ip link set eth0 down
sudo ip link set eth0 up
```

#### Task 5.3: Permanent Configuration (Ubuntu/Debian with Netplan)
```bash
# Backup original configuration
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup 2>/dev/null || true

# Create static IP configuration
sudo cat > /etc/netplan/99-lab5-config.yaml << 'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      # For static IP, uncomment these and comment dhcp4:
      # addresses:
      #   - 192.168.1.100/24
      # routes:
      #   - to: default
      #     via: 192.168.1.1
      # nameservers:
      #   addresses:
      #     - 8.8.8.8
      #     - 8.8.4.4
      #   search:
      #     - example.com
EOF

# Test configuration
sudo netplan try  # Will revert after 120 seconds if not confirmed

# Apply configuration (if test was successful)
sudo netplan apply

# Verify
ip addr show
ip route show
```

#### Task 5.4: DNS Configuration
```bash
# View current DNS
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com
dig google.com
host google.com

# Detailed DNS query
dig google.com +trace
dig google.com ANY

# Reverse DNS lookup
dig -x 8.8.8.8

# Query specific DNS server
dig @8.8.8.8 google.com

# Local hosts file
sudo cat >> /etc/hosts << 'EOF'
192.168.1.10    server1.lab.local server1
192.168.1.11    server2.lab.local server2
EOF

# Test local resolution
ping -c 2 server1.lab.local
getent hosts server1.lab.local
```

#### Task 5.5: Network Testing
```bash
# Ping tests
ping -c 4 8.8.8.8           # Ping Google DNS
ping -c 4 google.com        # Ping by hostname
ping -c 4 192.168.1.1       # Ping gateway

# Traceroute
traceroute google.com
tracepath google.com

# Port connectivity
nc -zv google.com 80        # Test HTTP port
nc -zv google.com 443       # Test HTTPS port
telnet google.com 80        # Alternative method

# Check listening ports
ss -tuln                    # Socket statistics
netstat -tuln               # Network statistics
lsof -i -P -n              # List open files (network)

# Download test
wget -O /dev/null http://speedtest.tele2.net/1MB.zip
curl -o /dev/null http://speedtest.tele2.net/1MB.zip

# Bandwidth test (if iperf3 available)
# Server side: iperf3 -s
# Client side: iperf3 -c server_ip
```

### Verification
```bash
# Verification script
#!/bin/bash
echo "=== Network Configuration Verification ==="

# Check interface is up
ip link show | grep -q "state UP" && echo "✓ Network interface is UP" || echo "✗ Interface down"

# Check IP address
ip addr show | grep -q "inet " && echo "✓ IP address configured" || echo "✗ No IP address"

# Check default gateway
ip route | grep -q "default via" && echo "✓ Default gateway configured" || echo "✗ No default gateway"

# Check DNS
test -s /etc/resolv.conf && echo "✓ DNS configured" || echo "✗ No DNS configuration"

# Test internet connectivity
ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "✓ Internet reachable (IP)" || echo "✗ No internet (IP)"
ping -c 1 google.com > /dev/null 2>&1 && echo "✓ Internet reachable (DNS)" || echo "✗ DNS not working"

# Check listening services
ss -tuln | grep -q ":22 " && echo "✓ SSH service listening" || echo "! SSH not listening"
```

### Solution Summary
```bash
# Complete network setup for static IP
sudo cat > /etc/netplan/99-static.yaml << 'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF

sudo netplan apply

# Verify all settings
ip addr show eth0
ip route show
cat /etc/resolv.conf
ping -c 2 google.com
```

### Troubleshooting
- **"Permission denied"**: Use `sudo` for network configuration commands
- **Changes don't persist**: Use netplan or NetworkManager for permanent configs
- **Can ping IPs but not hostnames**: Check DNS configuration in `/etc/resolv.conf`
- **No internet after applying config**: Check gateway and DNS settings
- **netplan not available**: You may be on RHEL/CentOS - use network scripts or nmcli

---

# Intermediate Labs

## Lab 11: LVM Storage Management

**Objective**: Create and manage Logical Volume Manager (LVM) storage  
**Difficulty**: Intermediate  
**Time**: 60 minutes  
**Prerequisites**: Sudo access, additional disk or partitions available

### Scenario
Your server is running low on storage. You need to add new disks, create an LVM setup, and demonstrate the flexibility of LVM by resizing volumes on the fly.

### Tasks

#### Task 11.1: Prepare Physical Disks
```bash
# List available disks
lsblk
sudo fdisk -l

# Create partitions on available disks (using /dev/sdb as example)
# WARNING: This will destroy data on /dev/sdb!
sudo fdisk /dev/sdb
# Commands in fdisk:
# n (new partition)
# p (primary)
# 1 (partition number)
# Enter (default first sector)
# +5G (size)
# t (change type)
# 8e (Linux LVM)
# w (write changes)

# Create additional partition
sudo fdisk /dev/sdb
# n, p, 2, Enter, +5G, t, 2, 8e, w

# Verify partitions
lsblk
sudo fdisk -l /dev/sdb
```

#### Task 11.2: Create Physical Volumes
```bash
# Initialize partitions as physical volumes
sudo pvcreate /dev/sdb1
sudo pvcreate /dev/sdb2

# Display physical volumes
sudo pvdisplay
sudo pvs

# Show detailed information
sudo pvdisplay /dev/sdb1
```

#### Task 11.3: Create Volume Group
```bash
# Create volume group named "vg_data"
sudo vgcreate vg_data /dev/sdb1 /dev/sdb2

# Display volume group
sudo vgdisplay vg_data
sudo vgs

# Show volume group details
sudo vgdisplay -v vg_data
```

#### Task 11.4: Create Logical Volumes
```bash
# Create logical volumes
sudo lvcreate -L 2G -n lv_web vg_data
sudo lvcreate -L 3G -n lv_database vg_data
sudo lvcreate -l 100%FREE -n lv_backup vg_data  # Use remaining space

# Display logical volumes
sudo lvdisplay
sudo lvs

# Show details
sudo lvdisplay /dev/vg_data/lv_web
```

#### Task 11.5: Create Filesystems and Mount
```bash
# Create filesystems
sudo mkfs.ext4 /dev/vg_data/lv_web
sudo mkfs.ext4 /dev/vg_data/lv_database
sudo mkfs.xfs /dev/vg_data/lv_backup

# Create mount points
sudo mkdir -p /mnt/web /mnt/database /mnt/backup

# Mount volumes
sudo mount /dev/vg_data/lv_web /mnt/web
sudo mount /dev/vg_data/lv_database /mnt/database
sudo mount /dev/vg_data/lv_backup /mnt/backup

# Verify mounts
df -h | grep vg_data
lsblk

# Add to /etc/fstab for persistent mounting
echo "/dev/vg_data/lv_web      /mnt/web       ext4    defaults    0 2" | sudo tee -a /etc/fstab
echo "/dev/vg_data/lv_database /mnt/database  ext4    defaults    0 2" | sudo tee -a /etc/fstab
echo "/dev/vg_data/lv_backup   /mnt/backup    xfs     defaults    0 2" | sudo tee -a /etc/fstab

# Test fstab
sudo mount -a
```

#### Task 11.6: Extend Logical Volume (Online Resize)
```bash
# Create test files
sudo dd if=/dev/zero of=/mnt/web/testfile bs=1M count=100
df -h /mnt/web

# Extend logical volume by 1GB
sudo lvextend -L +1G /dev/vg_data/lv_web

# Resize filesystem (online, no unmount needed)
sudo resize2fs /dev/vg_data/lv_web

# Verify new size
df -h /mnt/web
sudo lvdisplay /dev/vg_data/lv_web
```

#### Task 11.7: Create and Manage LVM Snapshot
```bash
# Create snapshot
sudo lvcreate -L 1G -s -n lv_web_snapshot /dev/vg_data/lv_web

# Verify snapshot
sudo lvs
sudo lvdisplay /dev/vg_data/lv_web_snapshot

# Mount snapshot
sudo mkdir /mnt/web_snapshot
sudo mount /dev/vg_data/lv_web_snapshot /mnt/web_snapshot
ls -l /mnt/web_snapshot

# Make changes to original volume
sudo rm /mnt/web/testfile
ls -l /mnt/web

# Verify snapshot still has original data
ls -l /mnt/web_snapshot

# Restore from snapshot (unmount original first)
sudo umount /mnt/web
sudo lvconvert --merge /dev/vg_data/lv_web_snapshot
# Snapshot will merge on next mount

# Mount and verify
sudo mount /dev/vg_data/lv_web /mnt/web
ls -l /mnt/web  # testfile should be back

# Clean up snapshot (if not merged)
# sudo umount /mnt/web_snapshot
# sudo lvremove /dev/vg_data/lv_web_snapshot
```

### Verification
```bash
# Verification script
#!/bin/bash
echo "=== LVM Configuration Verification ==="

# Check physical volumes
sudo pvs | grep -q "vg_data" && echo "✓ Physical volumes created" || echo "✗ PVs missing"

# Check volume group
sudo vgs | grep -q "vg_data" && echo "✓ Volume group created" || echo "✗ VG missing"

# Check logical volumes
sudo lvs | grep -q "lv_web" && echo "✓ Logical volumes created" || echo "✗ LVs missing"

# Check mounts
df -h | grep -q "/mnt/web" && echo "✓ Volumes mounted" || echo "✗ Not mounted"

# Check fstab entries
grep -q "vg_data/lv_web" /etc/fstab && echo "✓ fstab configured" || echo "✗ fstab missing entries"
```

### Solution Summary
```bash
# Complete LVM setup script
#!/bin/bash

# Create physical volumes
pvcreate /dev/sdb1 /dev/sdb2

# Create volume group
vgcreate vg_data /dev/sdb1 /dev/sdb2

# Create logical volumes
lvcreate -L 2G -n lv_web vg_data
lvcreate -L 3G -n lv_database vg_data
lvcreate -l 100%FREE -n lv_backup vg_data

# Create filesystems
mkfs.ext4 /dev/vg_data/lv_web
mkfs.ext4 /dev/vg_data/lv_database
mkfs.xfs /dev/vg_data/lv_backup

# Create mount points and mount
mkdir -p /mnt/{web,database,backup}
mount /dev/vg_data/lv_web /mnt/web
mount /dev/vg_data/lv_database /mnt/database
mount /dev/vg_data/lv_backup /mnt/backup

echo "✓ LVM setup complete"
```

### Troubleshooting
- **"Device or resource busy"**: Unmount before removing LV
- **"Insufficient free space"**: Check `vgs` for available space
- **Can't extend filesystem**: Use correct command (resize2fs for ext4, xfs_growfs for xfs)
- **Snapshot full**: Extend snapshot size or remove it

---

## Lab 22: Kubernetes Deployment

**Objective**: Deploy a multi-tier application to Kubernetes  
**Difficulty**: Advanced  
**Time**: 90 minutes  
**Prerequisites**: Kubernetes cluster (minikube or kubeadm), kubectl installed

### Scenario
Deploy a 3-tier web application (Nginx frontend, Node.js API, MongoDB database) to Kubernetes with proper networking, configuration, and secrets management.

### Tasks

#### Task 22.1: Setup Kubernetes Environment
```bash
# Start minikube (if using minikube)
minikube start --cpus=2 --memory=4096

# Verify cluster
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Create namespace for our application
kubectl create namespace lab22-app
kubectl config set-context --current --namespace=lab22-app
```

#### Task 22.2: Deploy MongoDB Database
```bash
# Create MongoDB secret for credentials
kubectl create secret generic mongodb-secret \
  --from-literal=username=admin \
  --from-literal=password=SecurePassword123

# Create ConfigMap for MongoDB configuration
cat > mongodb-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongodb-config
data:
  database: myapp
  connection-string: "mongodb://mongodb-service:27017"
EOF

kubectl apply -f mongodb-configmap.yaml

# Create MongoDB Deployment
cat > mongodb-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  labels:
    app: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:5.0
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: password
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: mongodb-storage
          mountPath: /data/db
      volumes:
      - name: mongodb-storage
        emptyDir: {}
EOF

kubectl apply -f mongodb-deployment.yaml

# Create MongoDB Service
cat > mongodb-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
  type: ClusterIP
EOF

kubectl apply -f mongodb-service.yaml

# Verify MongoDB deployment
kubectl get deployments
kubectl get pods -l app=mongodb
kubectl get services
```

#### Task 22.3: Deploy Backend API
```bash
# Create backend deployment
cat > backend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: node:16-alpine
        command: ["sh", "-c", "while true; do echo 'Backend API running'; sleep 3600; done"]
        ports:
        - containerPort: 3000
        env:
        - name: MONGODB_URI
          valueFrom:
            configMapKeyRef:
              name: mongodb-config
              key: connection-string
        - name: MONGODB_USER
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: username
        - name: MONGODB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: password
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF

kubectl apply -f backend-deployment.yaml

# Create backend service
cat > backend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 3000
  type: ClusterIP
EOF

kubectl apply -f backend-service.yaml

# Verify backend deployment
kubectl get deployments backend-api
kubectl get pods -l app=backend
kubectl describe pod -l app=backend | head -50
```

#### Task 22.4: Deploy Frontend
```bash
# Create frontend ConfigMap
cat > frontend-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        upstream backend {
            server backend-service:3000;
        }
        server {
            listen 80;
            location /api/ {
                proxy_pass http://backend/;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
            }
            location / {
                root /usr/share/nginx/html;
                index index.html;
                try_files $uri $uri/ /index.html;
            }
        }
    }
EOF

kubectl apply -f frontend-configmap.yaml

# Create frontend deployment
cat > frontend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: nginx-config
        configMap:
          name: frontend-config
EOF

kubectl apply -f frontend-deployment.yaml

# Create frontend service (NodePort for external access)
cat > frontend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

kubectl apply -f frontend-service.yaml

# Verify frontend deployment
kubectl get deployments frontend
kubectl get pods -l app=frontend
kubectl get services frontend-service
```

#### Task 22.5: Test the Application
```bash
# Get service URL (minikube)
minikube service frontend-service --namespace=lab22-app --url

# Or get NodePort
NODE_PORT=$(kubectl get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Access application at: http://$NODE_IP:$NODE_PORT"

# Test from within cluster
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- sh
# Inside pod:
curl http://frontend-service
curl http://backend-service:3000
curl http://mongodb-service:27017
exit

# Check logs
kubectl logs -l app=frontend --tail=20
kubectl logs -l app=backend --tail=20
kubectl logs -l app=mongodb --tail=20

# Scale frontend
kubectl scale deployment frontend --replicas=5
kubectl get pods -l app=frontend

# Rolling update (change image)
kubectl set image deployment/frontend nginx=nginx:1.23-alpine
kubectl rollout status deployment/frontend

# Check rollout history
kubectl rollout history deployment/frontend

# Rollback if needed
# kubectl rollout undo deployment/frontend
```

#### Task 22.6: Configure Resource Monitoring
```bash
# Get resource usage
kubectl top nodes
kubectl top pods

# Describe resources
kubectl describe deployment frontend
kubectl describe service frontend-service

# Get all resources in namespace
kubectl get all -n lab22-app

# Export YAML for backup
kubectl get all -n lab22-app -o yaml > lab22-backup.yaml

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Verification
```bash
# Verification script
#!/bin/bash
echo "=== Kubernetes Deployment Verification ==="

kubectl get namespace lab22-app > /dev/null 2>&1 && echo "✓ Namespace created" || echo "✗ Namespace missing"
kubectl get deployment mongodb -n lab22-app > /dev/null 2>&1 && echo "✓ MongoDB deployed" || echo "✗ MongoDB missing"
kubectl get deployment backend-api -n lab22-app > /dev/null 2>&1 && echo "✓ Backend deployed" || echo "✗ Backend missing"
kubectl get deployment frontend -n lab22-app > /dev/null 2>&1 && echo "✓ Frontend deployed" || echo "✗ Frontend missing"

# Check pod status
READY_PODS=$(kubectl get pods -n lab22-app --field-selector=status.phase=Running --no-headers | wc -l)
echo "Ready pods: $READY_PODS"

# Check services
kubectl get svc -n lab22-app | grep -q "frontend-service" && echo "✓ Frontend service created" || echo "✗ Service missing"
```

### Troubleshooting
- **ImagePullBackOff**: Check image name and availability
- **CrashLoopBackOff**: Check pod logs with `kubectl logs`
- **Pending pods**: Check resource availability with `kubectl describe pod`
- **Service not accessible**: Verify selectors match pod labels
- **ConfigMap not loading**: Check volume mounts and subPath

---

*This document contains 30 comprehensive hands-on labs. Due to length, I've included representative samples. The full document would continue with all 30 labs covering system administration, networking, security, databases, containers, and automation.*

---

## Summary of All 30 Labs

### Beginner (1-10)
1. ✓ System Setup and Navigation
2. ✓ User and Permission Management
3. ✓ File Operations and Text Processing
4. ✓ Process Management
5. ✓ Basic Networking Configuration
6. Package Management (apt/dnf practice)
7. Basic Bash Scripting (variables, loops, functions)
8. Systemd Service Management
9. Basic Firewall Configuration (ufw/firewalld)
10. Log Analysis and Monitoring

### Intermediate (11-20)
11. ✓ LVM Storage Management
12. Advanced Networking with Static Routes
13. SSH Hardening and Key Management
14. Web Server Setup (Apache + SSL)
15. Automated Backup Solution
16. SELinux Configuration
17. Advanced Bash Scripting with Error Handling
18. Performance Tuning
19. LDAP Authentication
20. Network Troubleshooting

### Advanced (21-30)
21. Docker Multi-Container Application
22. ✓ Kubernetes Deployment
23. Ansible Playbook for LAMP Stack
24. MySQL Replication Setup
25. PostgreSQL Streaming Replication
26. LUKS Disk Encryption
27. OpenVPN Server Setup
28. Security Audit and Hardening
29. Samba File Server with AD Integration
30. Complete Infrastructure as Code

Each lab includes detailed tasks, verification steps, solutions, and troubleshooting guidance. Practice these labs in order to build comprehensive Linux expertise!
