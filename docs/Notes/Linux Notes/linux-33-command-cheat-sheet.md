# Linux Command Cheat Sheet

**Complete command reference from beginner to expert level - organized by category for quick lookup.**

---

## Table of Contents

1. [File & Directory Operations](#1-file--directory-operations)
2. [User & Permission Management](#2-user--permission-management)
3. [Process Management](#3-process-management)
4. [System Information](#4-system-information)
5. [Networking](#5-networking)
6. [Package Management](#6-package-management)
7. [Text Processing & Search](#7-text-processing--search)
8. [Disk & Storage Management](#8-disk--storage-management)
9. [Service Management (systemd)](#9-service-management-systemd)
10. [Security & Firewall](#10-security--firewall)
11. [Monitoring & Performance](#11-monitoring--performance)
12. [Compression & Archives](#12-compression--archives)
13. [Bash Scripting Essentials](#13-bash-scripting-essentials)
14. [Advanced Administration](#14-advanced-administration)
15. [Containers & Virtualization](#15-containers--virtualization)
16. [Backup & Recovery](#16-backup--recovery)
17. [Kernel & Modules](#17-kernel--modules)

---

## 1. File & Directory Operations

### Navigation
```bash
pwd                          # Print working directory
cd /path                     # Change directory
cd ~                         # Go to home directory
cd ..                        # Go up one directory
cd -                         # Go to previous directory
```

### Listing Files
```bash
ls                           # List files
ls -l                        # Long format
ls -lh                       # Human-readable sizes
ls -la                       # Include hidden files
ls -ltr                      # Sort by modification time (oldest first)
ls -lS                       # Sort by size
ls -R                        # Recursive listing
tree                         # Visual tree structure
tree -L 2                    # Limit depth to 2 levels
```

### Creating Files & Directories
```bash
touch file.txt               # Create empty file or update timestamp
mkdir dirname                # Create directory
mkdir -p path/to/dir         # Create parent directories
mkdir -p dir{1,2,3}          # Create multiple directories
```

### Copying, Moving, Deleting
```bash
cp source dest               # Copy file
cp -r sourcedir destdir      # Copy directory recursively
cp -i file dest              # Interactive (prompt before overwrite)
cp -p file dest              # Preserve permissions and timestamps
mv source dest               # Move or rename
rm file                      # Remove file
rm -r dirname                # Remove directory recursively
rm -rf dirname               # Force remove (dangerous!)
rm -i file                   # Interactive removal
shred -vfz -n 10 file        # Secure delete (overwrite 10 times)
```

### Viewing Files
```bash
cat file                     # Display entire file
cat -n file                  # With line numbers
less file                    # Paginated viewer (q to quit)
more file                    # Simple pager
head file                    # First 10 lines
head -n 20 file              # First 20 lines
tail file                    # Last 10 lines
tail -n 50 file              # Last 50 lines
tail -f file                 # Follow file (monitor logs)
tail -f file | grep ERROR    # Follow and filter
```

### Finding Files
```bash
find /path -name "*.txt"     # Find by name
find /path -iname "*.txt"    # Case-insensitive
find /path -type f           # Find files only
find /path -type d           # Find directories only
find /path -size +100M       # Files larger than 100MB
find /path -mtime -7         # Modified in last 7 days
find /path -mtime +30        # Modified more than 30 days ago
find /path -perm 644         # Find by permissions
find /path -user john        # Find by owner
find /path -empty            # Find empty files/directories
find /path -name "*.log" -exec rm {} \;  # Find and delete
find /path -name "*.txt" -exec grep "pattern" {} \; -print
locate filename              # Fast search (uses database)
sudo updatedb                # Update locate database
which command                # Find command location
whereis command              # Find binary, source, manual
```

### Links
```bash
ln target linkname           # Create hard link
ln -s target linkname        # Create symbolic (soft) link
readlink linkname            # Show link target
readlink -f linkname         # Follow all symlinks to final target
ls -l linkname               # View link details
find /path -type l           # Find all symbolic links
find /path -type l -xtype l  # Find broken symlinks
```

### File Information
```bash
file filename                # Determine file type
file -b filename             # Brief output
stat filename                # Detailed file statistics
stat -c %s filename          # File size only
stat -c %y filename          # Modification time
basename /path/to/file       # Extract filename
dirname /path/to/file        # Extract directory path
realpath file                # Absolute path
md5sum file                  # MD5 checksum
sha256sum file               # SHA-256 checksum
sha512sum file               # SHA-512 checksum
md5sum -c checksums.txt      # Verify checksums
diff file1 file2             # Compare files
diff -u file1 file2          # Unified format
diff -r dir1 dir2            # Compare directories
cmp file1 file2              # Binary comparison
comm file1 file2             # Compare sorted files
```

### File Permissions
```bash
chmod 755 file               # rwxr-xr-x
chmod u+x file               # Add execute for owner
chmod g-w file               # Remove write for group
chmod o=r file               # Set read only for others
chmod -R 755 directory       # Recursive
chown user:group file        # Change owner and group
chown -R user:group dir      # Recursive
chgrp group file             # Change group only

# Common permission patterns:
chmod 644 file               # rw-r--r-- (files)
chmod 755 file               # rwxr-xr-x (executables/dirs)
chmod 600 file               # rw------- (sensitive files)
chmod 700 directory          # rwx------ (private directory)
chmod 4755 file              # rwsr-xr-x (SUID)
chmod 2755 directory         # rwxr-sr-x (SGID)
chmod 1777 directory         # rwxrwxrwt (sticky bit - /tmp)
```

---

## 2. User & Permission Management

### User Management
```bash
whoami                       # Current user
id                           # User ID and group IDs
id username                  # Info for specific user
who                          # Logged in users
w                            # Who and what they're doing
last                         # Login history
lastlog                      # Last login for all users
useradd username             # Create user (basic)
useradd -m -s /bin/bash user # Create with home dir and shell
useradd -m -G sudo,docker user # Add to groups
passwd username              # Set/change password
passwd -l username           # Lock user account
passwd -u username           # Unlock user account
usermod -aG groupname user   # Add user to group
usermod -s /bin/bash user    # Change shell
usermod -L username          # Lock account
userdel username             # Delete user
userdel -r username          # Delete user and home directory
su - username                # Switch user
sudo command                 # Execute as root
sudo -i                      # Interactive root shell
sudo -u user command         # Execute as specific user
visudo                       # Edit sudoers file safely
```

### Group Management
```bash
groups                       # Show current user's groups
groups username              # Show user's groups
groupadd groupname           # Create group
groupdel groupname           # Delete group
groupmod -n newname oldname  # Rename group
gpasswd -a user group        # Add user to group
gpasswd -d user group        # Remove user from group
newgrp groupname             # Change current group ID
getent group                 # List all groups
getent group groupname       # Show group info
getent passwd                # List all users
getent passwd username       # Show user info
```

### Account Management
```bash
chage -l username            # Password aging info
chage -M 90 username         # Max password age (90 days)
chage -m 7 username          # Min days between password changes
chage -W 14 username         # Password expiry warning (14 days)
chage -E 2025-12-31 username # Account expiration date
chage -I 30 username         # Inactive days after password expiry
finger username              # User information (if installed)
users                        # Currently logged in users
logname                      # Current login name
```

---

## 3. Process Management

### Viewing Processes
```bash
ps                           # Current shell processes
ps aux                       # All processes (BSD style)
ps -ef                       # All processes (UNIX style)
ps -u username               # User's processes
ps -p PID                    # Specific process
pstree                       # Process tree
pstree -p                    # With PIDs
pgrep processname            # Find process ID by name
pidof processname            # Get PID(s) of running program
```

### Process Control
```bash
kill PID                     # Send TERM signal (graceful)
kill -9 PID                  # Send KILL signal (force)
kill -STOP PID               # Pause process
kill -CONT PID               # Resume process
killall processname          # Kill all by name
pkill processname            # Kill by pattern
pkill -u username            # Kill user's processes
nice -n 10 command           # Start with priority (+19 lowest, -20 highest)
renice -n 5 -p PID           # Change priority of running process
```

### Background & Foreground Jobs
```bash
command &                    # Run in background
jobs                         # List background jobs
fg                           # Bring last job to foreground
fg %1                        # Bring job 1 to foreground
bg                           # Resume job in background
bg %2                        # Resume job 2 in background
Ctrl+Z                       # Suspend current job
Ctrl+C                       # Terminate current job
nohup command &              # Run immune to hangups
disown %1                    # Detach job from shell
```

### Process Monitoring
```bash
top                          # Real-time process monitor
htop                         # Enhanced top (if installed)
# In top:
# P - sort by CPU
# M - sort by memory
# k - kill process
# r - renice process
# q - quit

atop                         # Advanced system monitor
glances                      # Modern monitoring tool
watch command                # Execute command repeatedly
watch -n 2 "ps aux | grep app"  # Every 2 seconds
watch -d df -h               # Highlight differences
timeout 10s command          # Run command with timeout
time command                 # Measure execution time
stdbuf -o0 command           # Unbuffered output
```

### Terminal Multiplexing
```bash
# screen
screen                       # Start session
screen -S name               # Named session
screen -ls                   # List sessions
screen -r                    # Reattach to session
screen -r name               # Reattach to named session
# Ctrl+A d - detach
# Ctrl+A c - new window
# Ctrl+A n - next window
# Ctrl+A p - previous window
# Ctrl+A k - kill window

# tmux
tmux                         # Start session
tmux new -s name             # Named session
tmux ls                      # List sessions
tmux attach                  # Attach to last session
tmux attach -t name          # Attach to named session
tmux kill-session -t name    # Kill session
# Ctrl+B d - detach
# Ctrl+B c - new window
# Ctrl+B n - next window
# Ctrl+B p - previous window
# Ctrl+B % - split vertical
# Ctrl+B " - split horizontal
# Ctrl+B arrow - switch pane
```

---

## 4. System Information

### Hardware Info
```bash
uname -a                     # All system info
uname -r                     # Kernel version
uname -m                     # Architecture
hostnamectl                  # Hostname and OS info
lsb_release -a               # Distribution info (Ubuntu/Debian)
cat /etc/os-release          # OS information
cat /proc/cpuinfo            # CPU information
lscpu                        # CPU architecture info
cat /proc/meminfo            # Memory information
free -h                      # Memory usage (human-readable)
lsblk                        # Block devices
lsblk -f                     # With filesystem info
lshw                         # Detailed hardware
lshw -short                  # Summary
lspci                        # PCI devices
lsusb                        # USB devices
dmidecode                    # DMI/SMBIOS info
dmidecode -t memory          # Memory info
dmidecode -t processor       # Processor info
```

### System Resources
```bash
uptime                       # System uptime and load
w                            # Uptime + logged in users
df -h                        # Disk space (human-readable)
df -i                        # Inode usage
du -h /path                  # Directory size
du -sh /path                 # Summary only
du -h --max-depth=1 /path    # One level deep
ncdu /path                   # Interactive disk usage analyzer
free -h                      # Memory usage
vmstat 1                     # Virtual memory stats (1 sec intervals)
iostat                       # I/O statistics
iostat -x 1 5                # Extended I/O stats, 5 samples
mpstat                       # Processor stats
sar                          # System activity reporter
```

### Date & Time
```bash
date                         # Current date and time
date "+%Y-%m-%d %H:%M:%S"    # Custom format
date "+%s"                   # Unix timestamp
date -d "2025-01-01"         # Format specific date
date -d "yesterday"          # Yesterday
date -d "next Monday"        # Next Monday
date -d "2 weeks ago"        # 2 weeks ago
date -d @1234567890          # From timestamp
timedatectl                  # Time and date settings
timedatectl list-timezones   # List timezones
timedatectl set-timezone "America/New_York"
timedatectl set-time "2025-01-01 12:00:00"
timedatectl set-ntp true     # Enable NTP sync
hwclock                      # Hardware clock
hwclock --systohc            # Sync system time to hardware clock
hwclock --hctosys            # Sync hardware clock to system time
cal                          # Calendar
cal 2025                     # Year calendar
ncal -3                      # 3-month calendar
```

---

## 5. Networking

### Network Configuration
```bash
ip addr                      # Show IP addresses
ip addr show                 # Same as above
ip -4 addr                   # IPv4 only
ip -6 addr                   # IPv6 only
ip link                      # Show network interfaces
ip link set eth0 up          # Bring interface up
ip link set eth0 down        # Bring interface down
ip route                     # Show routing table
ip route show                # Same as above
ip route add default via 192.168.1.1  # Add default gateway
ifconfig                     # Legacy interface config (deprecated)
ifconfig eth0                # Specific interface
```

### Network Testing
```bash
ping host                    # Test connectivity
ping -c 4 host               # Limit to 4 packets
ping6 host                   # IPv6 ping
traceroute host              # Trace route to host
tracepath host               # Similar to traceroute
mtr host                     # Continuous traceroute
host domain.com              # DNS lookup
nslookup domain.com          # DNS query
dig domain.com               # Detailed DNS query
dig @8.8.8.8 domain.com      # Query specific DNS server
dig +short domain.com        # Short output
whois domain.com             # Domain registration info
```

### Network Connections
```bash
ss -tuln                     # All listening TCP/UDP ports
ss -tunap                    # All connections with processes
ss -s                        # Summary statistics
ss -t state established      # Established TCP connections
netstat -tuln                # Legacy version of ss
netstat -tunap               # All connections
lsof -i                      # Files opened by network connections
lsof -i :80                  # What's using port 80
lsof -i TCP                  # TCP connections only
```

### File Transfer
```bash
scp file user@host:/path     # Copy file to remote
scp user@host:/path/file .   # Copy from remote
scp -r dir user@host:/path   # Copy directory
scp -P 2222 file user@host:  # Custom port
rsync -avz source dest       # Sync files/directories
rsync -avz --delete src dst  # Delete in dest
rsync -avzP src dst          # With progress
rsync -avz -e "ssh -p 2222" src user@host:dst  # Custom SSH port
wget URL                     # Download file
wget -c URL                  # Continue interrupted download
wget -r URL                  # Recursive download
curl URL                     # Transfer data
curl -O URL                  # Save with original filename
curl -I URL                  # Headers only
curl -X POST -d "data" URL   # POST request
```

### NetworkManager (RHEL/CentOS/Fedora)
```bash
nmcli                        # NetworkManager CLI
nmcli device status          # Device status
nmcli connection show        # Show connections
nmcli con show eth0          # Connection details
nmcli con add type ethernet con-name eth0 ifname eth0
nmcli con mod eth0 ipv4.addresses 192.168.1.100/24
nmcli con mod eth0 ipv4.gateway 192.168.1.1
nmcli con mod eth0 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con mod eth0 ipv4.method manual
nmcli con up eth0            # Activate connection
nmcli con down eth0          # Deactivate connection
nmcli device wifi list       # List WiFi networks
nmcli device wifi connect SSID password PASSWORD
nmcli radio wifi on/off      # Enable/disable WiFi
```

### Advanced Network Commands
```bash
# ARP
arp -a                       # Show ARP cache
arp -n                       # Numeric addresses
ip neigh                     # Show ARP (modern)
ip neigh flush all           # Clear ARP cache

# Routing
route -n                     # Show routing table (legacy)
ip route show                # Show routing table
ip route get 8.8.8.8         # Route to specific IP
ip route add 10.0.0.0/24 via 192.168.1.1
ip route del 10.0.0.0/24

# Interface statistics
ethtool eth0                 # Interface details
ethtool -i eth0              # Driver info
ethtool -S eth0              # Statistics
ip -s link                   # Link statistics

# Network testing
nc -zv host port             # Test port (netcat)
nc -l 8080                   # Listen on port
nc host 8080                 # Connect to port
telnet host port             # Test connection
timeout 5 telnet host port   # With timeout

# Bandwidth testing
iperf3 -s                    # Server mode
iperf3 -c server             # Client mode
speedtest-cli                # Internet speed test

# DNS tools
nslookup domain              # DNS lookup
nslookup -type=mx domain     # MX records
nslookup -type=ns domain     # NS records
dig domain                   # Detailed DNS
dig +short domain            # Short output
dig @8.8.8.8 domain          # Specific DNS server
dig -x IP                    # Reverse DNS
host domain                  # Simple DNS lookup
```

---

## 6. Package Management

### Debian/Ubuntu (apt)
```bash
sudo apt update              # Update package lists
sudo apt upgrade             # Upgrade installed packages
sudo apt full-upgrade        # Upgrade + handle dependencies
sudo apt install package     # Install package
sudo apt install -y package  # Auto-yes to prompts
sudo apt remove package      # Remove package
sudo apt purge package       # Remove package + config files
sudo apt autoremove          # Remove unused dependencies
sudo apt search keyword      # Search for packages
apt list --installed         # List installed packages
apt list --upgradable        # List upgradable packages
apt show package             # Show package details
sudo apt clean               # Clean package cache
sudo apt autoclean           # Clean old packages
dpkg -l                      # List installed packages
dpkg -L package              # List files installed by package
dpkg -i package.deb          # Install .deb file
dpkg -r package              # Remove package
dpkg --configure -a          # Fix broken packages
```

### RHEL/CentOS/Fedora (dnf/yum)
```bash
sudo dnf update              # Update all packages
sudo dnf upgrade             # Same as update
sudo dnf install package     # Install package
sudo dnf install -y package  # Auto-yes
sudo dnf remove package      # Remove package
sudo dnf autoremove          # Remove unused dependencies
sudo dnf search keyword      # Search packages
dnf list installed           # List installed
dnf list available           # List available
dnf info package             # Package details
sudo dnf clean all           # Clean cache
dnf provides /path/to/file   # Find which package provides file
sudo dnf groupinstall "Development Tools"  # Install package group
dnf grouplist                # List package groups
dnf history                  # Transaction history
sudo dnf history undo ID     # Undo transaction
sudo dnf history redo ID     # Redo transaction
dnf repolist                 # List repositories
sudo dnf config-manager --add-repo URL  # Add repo
sudo dnf config-manager --enable repo   # Enable repo
sudo dnf config-manager --disable repo  # Disable repo
dnf check-update             # Check for updates
sudo dnf download package    # Download without installing
rpm -qa                      # List all RPM packages
rpm -qi package              # Package info
rpm -ql package              # List files in package
rpm -qf /path/to/file        # Which package owns file
rpm -qc package              # List config files
rpm -qd package              # List documentation
sudo rpm -ivh package.rpm    # Install RPM file
sudo rpm -Uvh package.rpm    # Upgrade RPM
sudo rpm -e package          # Remove RPM
rpm -V package               # Verify package
rpm2cpio package.rpm | cpio -idmv  # Extract RPM
```

---

## 7. Text Processing & Search

### Searching in Files
```bash
grep "pattern" file          # Search in file
grep -i "pattern" file       # Case-insensitive
grep -r "pattern" directory  # Recursive search
grep -n "pattern" file       # Show line numbers
grep -v "pattern" file       # Invert match (exclude)
grep -c "pattern" file       # Count matches
grep -l "pattern" files      # List matching files only
grep -w "word" file          # Match whole word
grep -E "regex" file         # Extended regex
grep -A 3 "pattern" file     # Show 3 lines after match
grep -B 2 "pattern" file     # Show 2 lines before match
grep -C 2 "pattern" file     # Show 2 lines before and after
zgrep "pattern" file.gz      # Search in compressed file
```

### Text Manipulation
```bash
# sed - Stream editor
sed 's/old/new/' file        # Replace first occurrence per line
sed 's/old/new/g' file       # Replace all occurrences
sed 's/old/new/gi' file      # Case-insensitive replace
sed -i 's/old/new/g' file    # Edit file in-place
sed -i.bak 's/old/new/g' file # With backup
sed -n '10,20p' file         # Print lines 10-20
sed '5d' file                # Delete line 5
sed '/pattern/d' file        # Delete lines matching pattern
sed 's/^/prefix/' file       # Add prefix to each line
sed 's/$/suffix/' file       # Add suffix to each line
sed -n '/start/,/end/p' file # Print between patterns
sed 'y/abc/ABC/' file        # Translate characters

# awk - Pattern scanning and processing
awk '{print $1}' file        # Print first column
awk '{print $1, $3}' file    # Print columns 1 and 3
awk -F: '{print $1}' file    # Custom delimiter (:)
awk '/pattern/ {print $2}' file  # Print column 2 where pattern matches
awk '{sum+=$1} END {print sum}' file  # Sum first column
awk 'NR==10,NR==20' file     # Print lines 10-20
awk 'length > 80' file       # Lines longer than 80 chars
awk '{print NR, $0}' file    # Add line numbers
awk 'NF > 0' file            # Remove blank lines
awk '{print $NF}' file       # Print last field
awk '{for(i=1;i<=NF;i++) print $i}' file  # Print each field on new line

# cut - Extract sections
cut -d: -f1 /etc/passwd      # Extract first field (: delimiter)
cut -d: -f1,3 /etc/passwd    # Fields 1 and 3
cut -c1-10 file              # Extract characters 1-10
cut -f1,3 file               # Extract fields 1 and 3 (tab delimiter)
cut -d' ' -f2- file          # All fields from 2nd onwards

# sort - Sort lines
sort file                    # Alphabetical sort
sort -r file                 # Reverse sort
sort -n file                 # Numeric sort
sort -k2 file                # Sort by 2nd column
sort -u file                 # Sort and remove duplicates
sort -t: -k3 -n /etc/passwd  # Sort by 3rd field numerically
sort -h file                 # Human-numeric sort (1K, 2M, etc.)
sort -M file                 # Month sort
sort -R file                 # Random sort

# uniq - Remove duplicates
uniq file                    # Remove consecutive duplicates
sort file | uniq             # Remove all duplicates
uniq -c file                 # Count occurrences
uniq -d file                 # Show only duplicates
uniq -u file                 # Show only unique lines
uniq -i file                 # Case-insensitive

# tr - Translate characters
tr 'a-z' 'A-Z' < file        # Lowercase to uppercase
tr -d '0-9' < file           # Delete all digits
tr -s ' ' < file             # Squeeze repeated spaces
tr -c 'a-zA-Z' '\n' < file   # Replace non-letters with newline
tr '\n' ' ' < file           # Replace newlines with space

# wc - Word count
wc file                      # Lines, words, bytes
wc -l file                   # Count lines
wc -w file                   # Count words
wc -c file                   # Count bytes
wc -m file                   # Count characters
wc -L file                   # Longest line length

# paste - Merge lines
paste file1 file2            # Merge files side by side
paste -d: file1 file2        # Custom delimiter
paste -s file                # Serial (all lines on one)

# column - Format into columns
column -t file               # Table format
cat /etc/passwd | column -t -s:  # With delimiter

# expand/unexpand - Convert tabs
expand file                  # Tabs to spaces
expand -t 4 file             # Tab size 4
unexpand file                # Spaces to tabs

# nl - Number lines
nl file                      # Number non-empty lines
nl -ba file                  # Number all lines
nl -nrz file                 # Right-justified with leading zeros

# tee - Read from stdin and write to file and stdout
command | tee file           # Write to file and display
command | tee -a file        # Append to file
command | tee file1 file2    # Multiple files

# rev - Reverse lines
rev file                     # Reverse character order in lines

# tac - Reverse file
tac file                     # Display file in reverse order
```

### Text Viewing & Editing
```bash
nano file                    # Simple text editor
vi file                      # Vi editor
vim file                     # Vim editor
# For detailed Nano and Vim commands, see linux-nano-vim-cheatsheet.md
```

---

## 8. Disk & Storage Management

### Disk Information
```bash
lsblk                        # List block devices
lsblk -f                     # With filesystem info
fdisk -l                     # List all disks
sudo fdisk -l /dev/sda       # Specific disk
df -h                        # Disk space usage
df -i                        # Inode usage
du -sh directory             # Directory size
du -h --max-depth=1 /        # Size of / subdirectories
```

### Partitioning
```bash
sudo fdisk /dev/sda          # Partition disk (MBR)
# Common fdisk commands:
# m - help
# n - new partition
# d - delete partition
# p - print partition table
# w - write changes
# q - quit without saving

sudo parted /dev/sda         # Partition disk (GPT)
# parted commands:
# print - show partitions
# mkpart - create partition
# rm - remove partition

sudo cfdisk /dev/sda         # TUI partitioning tool
```

### Filesystem Operations
```bash
# Create filesystems
sudo mkfs.ext4 /dev/sda1     # Create ext4 filesystem
3dd                  # Delete 3 lines
d/pattern            # Delete until pattern
dt{char}             # Delete till character
df{char}             # Delete through character
```

**Copy (Yank)**
```
yy or Y              # Yank (copy) line
y{motion}            # Yank with motion

Common yank commands:
yw                   # Yank word
ye                   # Yank to end of word
y$                   # Yank to end of line
y0                   # Yank to beginning of line
yG                   # Yank to end of file
ygg                  # Yank to beginning of file
3yy                  # Yank 3 lines
y}                   # Yank paragraph
```

**Paste**
```
p                    # Paste after cursor/line
P                    # Paste before cursor/line
gp                   # Paste and move cursor after
gP                   # Paste before and move cursor
]p                   # Paste and adjust indentation
```

**Change**
```
c{motion}            # Change (delete and enter insert mode)
cc or S              # Change entire line
C                    # Change to end of line

Common change commands:
cw                   # Change word
ce                   # Change to end of word
c$                   # Change to end of line
c0                   # Change to beginning of line
ciw                  # Change inner word
caw                  # Change a word (including space)
ci"                  # Change inside quotes
ca"                  # Change around quotes
ci(                  # Change inside parentheses
ca(                  # Change around parentheses
cit                  # Change inside HTML/XML tag
```

**Replace**
```
r{char}              # Replace single character
R                    # Enter replace mode
~                    # Toggle case of character
g~{motion}           # Toggle case
gu{motion}           # Make lowercase
gU{motion}           # Make uppercase

Examples:
guiw                 # Lowercase word
gUiw                 # Uppercase word
g~~                  # Toggle case of line
```

**Undo/Redo**
```
u                    # Undo
Ctrl+r               # Redo
U                    # Undo all changes on line
.                    # Repeat last command
```

**Indentation**
```
>>                   # Indent line
<<                   # Unindent line
>}                   # Indent paragraph
<}                   # Unindent paragraph
={motion}            # Auto-indent
gg=G                 # Auto-indent entire file
```

**Join Lines**
```
J                    # Join current line with next
3J                   # Join 3 lines
gJ                   # Join without adding space
```

#### Vim Visual Mode

**Visual Selection**
```
v                    # Character-wise visual mode
V                    # Line-wise visual mode
Ctrl+v               # Block visual mode
gv                   # Re-select last visual selection
o                    # Toggle cursor to other end of selection
```

**Visual Mode Operations**
```
# After selecting text:
d                    # Delete selection
y                    # Yank (copy) selection
c                    # Change selection
>                    # Indent selection
<                    # Unindent selection
=                    # Auto-indent selection
u                    # Lowercase
U                    # Uppercase
~                    # Toggle case
:                    # Execute command on selection
J                    # Join lines
```

**Visual Block Mode (Ctrl+v)**
```
# After selecting block:
I                    # Insert before block
A                    # Append after block
c                    # Change block
r{char}              # Replace all chars in block
$                    # Extend to end of each line
```

#### Vim Search and Replace

**Search**
```
/pattern             # Search forward
?pattern             # Search backward
/\<word\>            # Search for exact word
/pattern\c           # Case-insensitive search
/pattern\C           # Case-sensitive search
n                    # Next match
N                    # Previous match
:noh                 # Clear search highlighting
```

**Search Options**
```
:set ignorecase      # Case-insensitive search
:set smartcase       # Smart case (case-sensitive if uppercase used)
:set hlsearch        # Highlight search results
:set incsearch       # Incremental search (search as you type)
```

**Replace**
```
:s/old/new/          # Replace first occurrence in line
:s/old/new/g         # Replace all in line
:s/old/new/gc        # Replace all in line with confirmation
:%s/old/new/g        # Replace all in file
:%s/old/new/gc       # Replace all in file with confirmation
:5,12s/old/new/g     # Replace in lines 5-12
:.,$s/old/new/g      # Replace from current line to end
:.,+5s/old/new/g     # Replace in current line and next 5
:'<,'>s/old/new/g    # Replace in visual selection
:%s/\<old\>/new/g    # Replace whole word only

# Flags:
# g - global (all occurrences in line)
# c - confirm each replacement
# i - case-insensitive
# I - case-sensitive
```

**Advanced Replace**
```
:%s/old/new/gn       # Count occurrences without replacing
:%s/\n/,/g           # Replace newlines with commas
:%s/\s\+$//g         # Remove trailing whitespace
:%s/^/prefix/g       # Add prefix to all lines
:%s/$/suffix/g       # Add suffix to all lines
:%s/^/#/g            # Comment all lines (with #)
:%s/^#//g            # Uncomment lines
```

#### Vim File Operations

**Saving and Quitting**
```
:w                   # Save file
:w filename          # Save as filename
:w!                  # Force save
:wq or :x or ZZ      # Save and quit
:q                   # Quit (fails if unsaved changes)
:q!                  # Quit without saving
:qa                  # Quit all windows
:wqa                 # Save and quit all
ZQ                   # Quit without saving
:w !sudo tee %       # Save with sudo (when opened without sudo)
```

**File Management**
```
:e filename          # Edit file
:e!                  # Reload current file (discard changes)
:e .                 # Open file browser (current directory)
:Ex                  # Explore (file browser)
:Sex                 # Split and explore
:Vex                 # Vertical split and explore
:bn                  # Next buffer
:bp                  # Previous buffer
:bd                  # Close buffer
:ls or :buffers      # List buffers
:b2                  # Switch to buffer 2
:b filename          # Switch to buffer by name
```

**Reading & Writing**
```
:r filename          # Insert file contents
:r !command          # Insert command output
:w !command          # Send buffer to command
:5,10w filename      # Write lines 5-10 to file
:5,10w >> file       # Append lines 5-10 to file
```

#### Vim Windows and Tabs

**Window Splits**
```
:split or :sp        # Horizontal split
:vsplit or :vsp      # Vertical split
:split filename      # Horizontal split with file
:vsplit filename     # Vertical split with file
:new                 # New horizontal split
:vnew                # New vertical split

# Navigate between splits
Ctrl+w h             # Move to left split
Ctrl+w j             # Move to down split
Ctrl+w k             # Move to up split
Ctrl+w l             # Move to right split
Ctrl+w w             # Cycle through splits
Ctrl+w p             # Previous split

# Resize splits
Ctrl+w =             # Equal size
Ctrl+w +             # Increase height
Ctrl+w -             # Decrease height
Ctrl+w >             # Increase width
Ctrl+w <             # Decrease width
:resize 20           # Set height to 20
:vertical resize 80  # Set width to 80

# Close splits
Ctrl+w q or :q       # Close current split
Ctrl+w o or :only    # Close all other splits
```

**Tabs**
```
:tabnew              # New tab
:tabnew filename     # New tab with file
:tabedit filename    # Edit file in new tab
:tabclose or :tabc   # Close tab
:tabonly or :tabo    # Close all other tabs

# Navigate tabs
gt or :tabnext       # Next tab
gT or :tabprev       # Previous tab
:tabfirst            # First tab
:tablast             # Last tab
2gt                  # Go to tab 2
:tabs                # List tabs
```

#### Vim Registers

**Using Registers**
```
"ayy                 # Yank line to register a
"ap                  # Paste from register a
"Ayy                 # Append line to register a
:reg                 # Show all registers
:reg a               # Show register a

Special registers:
""                   # Unnamed register (default)
"0                   # Last yank
"1-"9                # Last 9 deletes
"a-"z                # Named registers
"A-"Z                # Append to named registers
"-                   # Small delete register
"+                   # System clipboard
"*                   # Selection clipboard (X11)
"/                   # Last search pattern
":                   # Last command
".                   # Last inserted text
"%                   # Current filename
"#                   # Alternate filename
```

**System Clipboard**
```
"+yy                 # Copy line to clipboard
"+p                  # Paste from clipboard
"*yy                 # Copy to selection (X11)
:set clipboard=unnamed     # Use system clipboard by default
:set clipboard=unnamedplus # Use + register
```

#### Vim Macros

**Recording Macros**
```
q{letter}            # Start recording macro to register
# ... perform actions ...
q                    # Stop recording
@{letter}            # Play macro
@@                   # Repeat last macro
3@a                  # Play macro 'a' 3 times

Example:
qa                   # Start recording to register a
I#<Esc>j            # Insert # at beginning, move down
q                    # Stop recording
@a                   # Play macro (comment line)
10@a                 # Comment next 10 lines
```

**Editing Macros**
```
:let @a='            # Edit register a
# Type new macro content
'
:put a               # Paste register a to edit visually
# Edit the line
"ayy                 # Yank back to register a
```

#### Vim Marks and Jumps

**Marks**
```
ma                   # Set mark 'a' at cursor
'a                   # Jump to mark 'a' (first non-blank)
`a                   # Jump to mark 'a' (exact position)
:marks               # List all marks
:delmarks a          # Delete mark a
:delmarks!           # Delete all marks

Special marks:
'.                   # Last change
'0-'9                # Last 10 cursor positions
''                   # Position before last jump
'<                   # Start of last visual selection
'>                   # End of last visual selection
```

**Jump List**
```
Ctrl+o               # Jump to previous location
Ctrl+i               # Jump to next location
:jumps               # Show jump list
```

#### Vim Advanced Commands

**Sorting**
```
:sort                # Sort lines
:sort!               # Reverse sort
:sort u              # Sort and remove duplicates
:5,10sort            # Sort lines 5-10
:'<,'>sort           # Sort visual selection
```

**Filter Through External Command**
```
:%!sort              # Sort entire file using system sort
:5,10!sort           # Sort lines 5-10
!!command            # Filter current line
!}sort               # Sort paragraph
```

**Math/Numbers**
```
Ctrl+a               # Increment number under cursor
Ctrl+x               # Decrement number under cursor
g Ctrl+a             # Create sequence (in visual block)

# In visual block mode:
# Select numbers in column
# g Ctrl+a to create sequence
```

**Folding**
```
zf{motion}           # Create fold
zf}                  # Fold paragraph
zfap                 # Fold a paragraph
3zF                  # Fold 3 lines
za                   # Toggle fold
zo                   # Open fold
zc                   # Close fold
zR                   # Open all folds
zM                   # Close all folds
zd                   # Delete fold
```

**Spell Check**
```
:set spell           # Enable spell check
:set nospell         # Disable spell check
:set spell spelllang=en_us
]s                   # Next misspelled word
[s                   # Previous misspelled word
z=                   # Suggest corrections
zg                   # Add to dictionary
zug                  # Undo add to dictionary
zw                   # Mark as wrong
```

#### Vim Configuration (.vimrc)

**Essential .vimrc Settings**
```vim
" ~/.vimrc or ~/.vim/vimrc

" General settings
set nocompatible       " Disable Vi compatibility
syntax on              " Enable syntax highlighting
filetype plugin indent on " Enable filetype detection

" Interface
set number             " Show line numbers
set relativenumber     " Relative line numbers
set ruler              " Show cursor position
set showcmd            " Show command in status line
set showmatch          " Highlight matching brackets
set wildmenu           " Enhanced command line completion
set laststatus=2       " Always show status line

" Search
set hlsearch           " Highlight search results
set incsearch          " Incremental search
set ignorecase         " Case-insensitive search
set smartcase          " Smart case sensitivity

" Indentation
set autoindent         " Auto indent
set smartindent        " Smart indent
set expandtab          " Spaces instead of tabs
set tabstop=4          " Tab width
set shiftwidth=4       " Indent width
set softtabstop=4      " Backspace removes 4 spaces

" Performance
set lazyredraw         " Don't redraw during macros
set ttyfast            " Fast terminal connection

" Backup
set nobackup           " No backup files
set noswapfile         " No swap files
set undofile           " Persistent undo
set undodir=~/.vim/undo

" Clipboard
set clipboard=unnamedplus " Use system clipboard

" Mouse
set mouse=a            " Enable mouse in all modes

" Colors
colorscheme desert     " Color scheme
set background=dark    " Dark background

" Key mappings
let mapleader = ","    " Leader key
nnoremap <leader>w :w<CR>       " Quick save
nnoremap <leader>q :q<CR>       " Quick quit
nnoremap <leader>h :noh<CR>     " Clear search highlight
```

#### Vim Quick Reference Card

```
MODES               NAVIGATION           EDITING
─────               ──────────           ───────
i     Insert        h j k l   Movement   dd    Delete line
a     Append        w b       Word       yy    Copy line
v     Visual        gg G      File       p     Paste
V     Visual line   0 $       Line       u     Undo
Esc   Normal        f F t T   Find char  Ctrl+r Redo
:     Command       / ?       Search     .     Repeat
                    n N       Next/prev
FILES                          SEARCH/REPLACE
─────               VISUAL MODE ──────────────
:w    Save          ──────────  /pat   Search
:q    Quit          v  Visual   n      Next match
:wq   Save+quit     V  V-Line   :%s/old/new/g Replace all
:e f  Edit file     ^v V-Block  :%s/old/new/gc Confirm
:bn   Next buffer   d  Delete
:sp   Split         y  Yank     WINDOW/TABS
:vs   V-split       >  Indent   ───────────
                                :sp    Split
ADVANCED                        :vs    V-split
────────                        ^w h/j/k/l  Navigate
qa    Record macro              :tabnew     New tab
@a    Play macro                gt     Next tab
ma    Set mark a
'a    Jump to mark
```

---

## 8. Disk & Storage Management

### Disk Information
```bash
lsblk                        # List block devices
lsblk -f                     # With filesystem info
fdisk -l                     # List all disks
sudo fdisk -l /dev/sda       # Specific disk
df -h                        # Disk space usage
df -i                        # Inode usage
du -sh directory             # Directory size
du -h --max-depth=1 /        # Size of / subdirectories
```

### Partitioning
```bash
sudo fdisk /dev/sda          # Partition disk (MBR)
# Common fdisk commands:
# m - help
# n - new partition
# d - delete partition
# p - print partition table
# w - write changes
# q - quit without saving

sudo parted /dev/sda         # Partition disk (GPT)
# parted commands:
# print - show partitions
# mkpart - create partition
# rm - remove partition

sudo cfdisk /dev/sda         # TUI partitioning tool
```

### Filesystem Operations
```bash
# Create filesystems
sudo mkfs.ext4 /dev/sda1     # Create ext4 filesystem
sudo mkfs.xfs /dev/sda1      # Create XFS filesystem
sudo mkfs.ext4 -L mylabel /dev/sda1  # With label

# Mount/Unmount
sudo mount /dev/sda1 /mnt    # Mount filesystem
sudo mount -t ext4 /dev/sda1 /mnt  # Specify filesystem type
sudo mount -o ro /dev/sda1 /mnt    # Read-only
sudo umount /mnt             # Unmount
sudo umount /dev/sda1        # Unmount by device
mount | grep /mnt            # Check if mounted

# Persistent mounts (/etc/fstab)
# Format: device mountpoint fstype options dump pass
/dev/sda1  /data  ext4  defaults  0  2
UUID=xxx   /data  ext4  defaults  0  2

# Find UUID
sudo blkid /dev/sda1
lsblk -f

# Test fstab
sudo mount -a                # Mount all in fstab
sudo findmnt --verify        # Verify fstab

# Filesystem check
sudo fsck /dev/sda1          # Check and repair
sudo fsck -y /dev/sda1       # Auto-repair
sudo e2fsck -f /dev/sda1     # ext4 check (force)
sudo xfs_repair /dev/sda1    # XFS repair
```

### LVM (Logical Volume Manager)
```bash
# Physical Volumes
sudo pvcreate /dev/sdb       # Create PV
sudo pvdisplay               # Show PVs
sudo pvs                     # PV summary

# Volume Groups
sudo vgcreate vg_data /dev/sdb /dev/sdc  # Create VG
sudo vgdisplay               # Show VGs
sudo vgs                     # VG summary
sudo vgextend vg_data /dev/sdd  # Add PV to VG

# Logical Volumes
sudo lvcreate -L 10G -n lv_data vg_data  # Create 10GB LV
sudo lvcreate -l 100%FREE -n lv_data vg_data  # Use all free space
sudo lvdisplay               # Show LVs
sudo lvs                     # LV summary

# Extend LV
sudo lvextend -L +5G /dev/vg_data/lv_data  # Add 5GB
sudo lvextend -l +100%FREE /dev/vg_data/lv_data  # Use all free
# Resize filesystem
sudo resize2fs /dev/vg_data/lv_data  # ext4
sudo xfs_growfs /mount/point         # XFS

# Reduce LV (ext4 only, not XFS!)
sudo umount /dev/vg_data/lv_data
sudo e2fsck -f /dev/vg_data/lv_data
sudo resize2fs /dev/vg_data/lv_data 5G
sudo lvreduce -L 5G /dev/vg_data/lv_data
```

### RAID
```bash
# View RAID arrays
cat /proc/mdstat
sudo mdadm --detail /dev/md0
sudo mdadm --detail --scan

# Create RAID
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc  # RAID 1
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd  # RAID 5
sudo mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sd{b,c,d,e}  # RAID 10

# Add/remove devices
sudo mdadm /dev/md0 --add /dev/sdd  # Add spare
sudo mdadm /dev/md0 --remove /dev/sdb  # Remove device
sudo mdadm /dev/md0 --fail /dev/sdb    # Mark as failed
sudo mdadm /dev/md0 --remove /dev/sdb  # Then remove

# Save configuration
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u

# Stop/Start RAID
sudo mdadm --stop /dev/md0
sudo mdadm --assemble /dev/md0
sudo mdadm --assemble --scan  # Auto-assemble all

# Monitor
sudo mdadm --monitor --scan --daemonize
```

### Disk Utilities
```bash
# dd - Disk copy/convert
dd if=/dev/sda of=/dev/sdb bs=4M status=progress  # Clone disk
dd if=/dev/zero of=/dev/sdb bs=1M count=1000  # Write zeros
dd if=/dev/urandom of=file.bin bs=1M count=100  # Random data
dd if=file.iso of=/dev/sdb bs=4M status=progress  # Write ISO to USB

# sync - Flush filesystem buffers
sync                         # Flush all
sync /path/to/file          # Sync specific file

# hdparm - Hard disk parameters
sudo hdparm -I /dev/sda      # Detailed info
sudo hdparm -t /dev/sda      # Test read speed
sudo hdparm -T /dev/sda      # Test cache read
sudo hdparm -Y /dev/sda      # Sleep drive
sudo hdparm -S 120 /dev/sda  # Set standby timeout

# smartctl - SMART monitoring
sudo smartctl -a /dev/sda    # All SMART info
sudo smartctl -H /dev/sda    # Health status
sudo smartctl -t short /dev/sda  # Short self-test
sudo smartctl -t long /dev/sda   # Long self-test
sudo smartctl -l selftest /dev/sda  # Test results

# badblocks - Check for bad sectors
sudo badblocks -v /dev/sda   # Read-only test
sudo badblocks -nsv /dev/sda # Non-destructive write test
sudo badblocks -wsv /dev/sda # Destructive write test (ERASES DATA!)

# fstrim - SSD trim
sudo fstrim -v /              # Trim root filesystem
sudo fstrim -av               # Trim all mounted filesystems
```

---

## 9. Service Management (systemd)

### Service Control
```bash
sudo systemctl start service    # Start service
sudo systemctl stop service     # Stop service
sudo systemctl restart service  # Restart service
sudo systemctl reload service   # Reload config (if supported)
sudo systemctl status service   # Service status
systemctl is-active service     # Check if running
systemctl is-enabled service    # Check if enabled
sudo systemctl enable service   # Enable at boot
sudo systemctl disable service  # Disable at boot
sudo systemctl enable --now service  # Enable and start
sudo systemctl mask service     # Prevent service from starting
sudo systemctl unmask service   # Remove mask
```

### Viewing Services
```bash
systemctl list-units --type=service  # List all services
systemctl list-units --state=running # Running services
systemctl list-units --state=failed  # Failed services
systemctl list-unit-files            # All unit files
systemctl list-dependencies service  # Service dependencies
```

### Journal Logs
```bash
journalctl                      # All journal logs
journalctl -u service           # Logs for specific service
journalctl -u service -f        # Follow logs
journalctl -u service -n 50     # Last 50 lines
journalctl -u service --since "1 hour ago"
journalctl -u service --since "2024-01-01"
journalctl -u service --until "2024-01-31"
journalctl -p err               # Priority: err and above
journalctl -b                   # Current boot
journalctl -b -1                # Previous boot
journalctl --disk-usage         # Journal disk usage
journalctl --vacuum-time=7d     # Keep last 7 days
journalctl --vacuum-size=500M   # Keep max 500MB
```

### System Control
```bash
sudo systemctl reboot           # Reboot system
sudo systemctl poweroff         # Shutdown
sudo systemctl suspend          # Suspend
sudo systemctl hibernate        # Hibernate
systemctl get-default           # Get default target
sudo systemctl set-default multi-user.target  # Set default target
sudo systemctl isolate multi-user.target      # Switch target
```

---

## 10. Security & Firewall

### Firewall (firewalld - RHEL/CentOS)
```bash
sudo systemctl start firewalld
sudo firewall-cmd --state       # Check firewall status
sudo firewall-cmd --get-zones   # List zones
sudo firewall-cmd --get-default-zone  # Default zone
sudo firewall-cmd --get-active-zones  # Active zones
sudo firewall-cmd --list-all          # All settings
sudo firewall-cmd --list-services     # Allowed services
sudo firewall-cmd --list-ports        # Allowed ports

# Add services/ports
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Remove services/ports
sudo firewall-cmd --remove-service=http --permanent
sudo firewall-cmd --remove-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Rich rules
sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" accept' --permanent
sudo firewall-cmd --reload
```

### UFW (Ubuntu)
```bash
sudo ufw status                 # Status
sudo ufw enable                 # Enable firewall
sudo ufw disable                # Disable firewall
sudo ufw allow 22               # Allow SSH
sudo ufw allow 80/tcp           # Allow HTTP
sudo ufw allow from 192.168.1.0/24  # Allow subnet
sudo ufw deny 23                # Block telnet
sudo ufw delete allow 80        # Remove rule
sudo ufw reset                  # Reset to defaults
sudo ufw status numbered        # Show rule numbers
sudo ufw delete 2               # Delete rule by number
```

### iptables (Legacy)
```bash
sudo iptables -L                # List rules
sudo iptables -L -n -v          # Verbose with numbers
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # Allow HTTP
sudo iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT  # Allow subnet
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP  # Rate limit SSH
sudo iptables -D INPUT 3        # Delete rule 3
sudo iptables -F                # Flush all rules
sudo iptables-save > /etc/iptables/rules.v4  # Save rules
sudo iptables-restore < /etc/iptables/rules.v4  # Restore rules
```

### SELinux
```bash
getenforce                      # Get SELinux mode
sestatus                        # SELinux status
sestatus -v                     # Verbose status
sudo setenforce 0               # Set permissive (temporary)
sudo setenforce 1               # Set enforcing (temporary)
# Permanent: Edit /etc/selinux/config
# SELINUX=enforcing|permissive|disabled

# File contexts
ls -Z file                      # View SELinux context
ls -Zd directory                # Directory context
ps -Z                           # Process contexts
id -Z                           # User context
sudo chcon -t httpd_sys_content_t /var/www/html/file  # Change context
sudo chcon -u system_u file     # Change user
sudo chcon -r object_r file     # Change role
sudo restorecon -Rv /var/www/html  # Restore default contexts
sudo semanage fcontext -a -t httpd_sys_content_t "/webdata(/.*)?"
sudo restorecon -Rv /webdata

# Booleans
getsebool -a                    # List all booleans
getsebool httpd_can_network_connect
sudo setsebool httpd_can_network_connect on  # Temporary
sudo setsebool -P httpd_can_network_connect on  # Permanent (-P)

# Ports
sudo semanage port -l           # List port contexts
sudo semanage port -a -t http_port_t -p tcp 8080  # Add port
sudo semanage port -d -t http_port_t -p tcp 8080  # Delete

# Troubleshooting
sudo ausearch -m avc -ts recent # Recent denials
sudo ausearch -m avc -ts today  # Today's denials
sudo sealert -a /var/log/audit/audit.log  # Analyze audit log
sudo audit2allow -a             # Generate policy from denials
sudo audit2allow -a -M mypolicy # Create policy module
sudo semodule -i mypolicy.pp    # Install module

# Modules
sudo semodule -l                # List modules
sudo semodule -r modulename     # Remove module
```

### AppArmor (Ubuntu/Debian)
```bash
sudo aa-status                  # AppArmor status
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox  # Enforce mode
sudo aa-complain /etc/apparmor.d/usr.bin.firefox # Complain mode
sudo aa-disable /etc/apparmor.d/usr.bin.firefox  # Disable profile
sudo aa-logprof                 # Generate profile from logs
sudo aa-genprof command         # Generate new profile
```

### Fail2ban
```bash
sudo fail2ban-client status     # Status
sudo fail2ban-client status sshd  # Specific jail
sudo fail2ban-client set sshd unbanip 1.2.3.4  # Unban IP
sudo fail2ban-client set sshd banip 1.2.3.4    # Ban IP
sudo fail2ban-client reload     # Reload config
sudo fail2ban-client start      # Start
sudo fail2ban-client stop       # Stop
```

### SSH Security
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id user@server
# Or manually:
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# SSH config (~/.ssh/config)
Host myserver
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Harden SSH (/etc/ssh/sshd_config)
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port 2222
MaxAuthTries 3
AllowUsers admin deploy
```

---

## 11. Monitoring & Performance

### Resource Monitoring
```bash
top                             # Process monitor
htop                            # Enhanced top
atop                            # Advanced monitor
glances                         # Modern monitor
uptime                          # Load average
w                               # Load + users
free -h                         # Memory usage
vmstat 1                        # Virtual memory stats
vmstat 1 10                     # 10 samples, 1 sec interval
iostat                          # I/O statistics
iostat -x 1                     # Extended, 1 sec interval
mpstat                          # CPU statistics
mpstat -P ALL                   # Per-CPU statistics
sar                             # System activity
sar -u 1 10                     # CPU usage
sar -r 1 10                     # Memory usage
sar -b 1 10                     # I/O statistics
```

### Process Monitoring
```bash
ps aux --sort=-%cpu | head     # Top CPU consumers
ps aux --sort=-%mem | head     # Top memory consumers
pgrep -a processname           # Find process with full command
lsof                           # Open files
lsof -u username               # Files opened by user
lsof -p PID                    # Files opened by process
lsof -i :80                    # What's using port 80
lsof /path                     # Processes using file/directory
strace -p PID                  # Trace system calls
strace command                 # Trace command execution
ltrace command                 # Trace library calls
```

### Disk I/O Monitoring
```bash
iotop                          # I/O monitor (like top)
iotop -o                       # Only active processes
iostat -x 1                    # Extended I/O stats
sudo iotop -P                  # Show PIDs
```

### Network Monitoring
```bash
iftop                          # Network bandwidth (interface)
iftop -i eth0                  # Specific interface
nethogs                        # Network bandwidth (per process)
nload                          # Network load
ss -s                          # Socket statistics
netstat -s                     # Network statistics
tcpdump -i eth0                # Capture packets
tcpdump -i eth0 port 80        # Capture HTTP traffic
tcpdump -i eth0 -w capture.pcap  # Save to file
```

### Log Monitoring
```bash
tail -f /var/log/syslog        # Follow system log
tail -f /var/log/messages      # RHEL/CentOS
journalctl -f                  # Follow journal
multitail /var/log/syslog /var/log/auth.log  # Multiple logs
dmesg                          # Kernel messages
dmesg -T                       # Human-readable timestamps
dmesg -w                       # Follow kernel messages
dmesg -l err,warn              # Errors and warnings only
logger "Test message"          # Write to syslog
logger -p user.err "Error message"  # With priority
```

### Performance Analysis
```bash
# perf - Performance analysis
sudo perf top                  # Real-time profiling
sudo perf stat command         # Performance statistics
sudo perf record command       # Record performance data
sudo perf report               # View recorded data

# sysstat package
sar -u 1 10                    # CPU usage (1s intervals, 10 samples)
sar -r 1 10                    # Memory usage
sar -b 1 10                    # I/O statistics
sar -n DEV 1 10                # Network statistics
sar -q 1 10                    # Load average and queue
sar -f /var/log/sa/sa01        # Read from file

# pidstat - Per-process statistics
pidstat                        # CPU stats for all processes
pidstat -r                     # Memory stats
pidstat -d                     # Disk I/O stats
pidstat -u -p PID 1            # Specific process, 1s interval

# System load
uptime                         # Load average
cat /proc/loadavg              # Load average (raw)
tload                          # Graph of load average
```

---

## 12. Compression & Archives

### tar Archives
```bash
tar -cvf archive.tar files     # Create tar archive
tar -czvf archive.tar.gz files # Create tar.gz (gzip)
tar -cjvf archive.tar.bz2 files # Create tar.bz2 (bzip2)
tar -cJvf archive.tar.xz files # Create tar.xz (xz)
tar -xvf archive.tar           # Extract tar
tar -xzvf archive.tar.gz       # Extract tar.gz
tar -xjvf archive.tar.bz2      # Extract tar.bz2
tar -xJvf archive.tar.xz       # Extract tar.xz
tar -tvf archive.tar           # List contents
tar -xvf archive.tar -C /path  # Extract to directory
tar --exclude='*.log' -czf archive.tar.gz dir  # Exclude pattern

# Flags:
# c - create
# x - extract
# v - verbose
# f - file
# z - gzip
# j - bzip2
# J - xz
# t - list
```

### Compression
```bash
gzip file                      # Compress (removes original)
gzip -k file                   # Keep original
gzip -9 file                   # Maximum compression
gzip -1 file                   # Fast compression
gunzip file.gz                 # Decompress
gzip -d file.gz                # Decompress (same as gunzip)
zcat file.gz                   # View compressed file
zgrep pattern file.gz          # Search in compressed
zless file.gz                  # Page through compressed

bzip2 file                     # Better compression
bzip2 -k file                  # Keep original
bunzip2 file.bz2               # Decompress
bzip2 -d file.bz2              # Decompress
bzcat file.bz2                 # View compressed
bzgrep pattern file.bz2        # Search in compressed

xz file                        # Best compression
xz -k file                     # Keep original
xz -9 file                     # Maximum compression
unxz file.xz                   # Decompress
xz -d file.xz                  # Decompress
xzcat file.xz                  # View compressed

zip archive.zip files          # Create zip
zip -r archive.zip directory   # Recursive
zip -e archive.zip files       # Encrypted
zip -9 archive.zip files       # Maximum compression
unzip archive.zip              # Extract
unzip -l archive.zip           # List contents
unzip -t archive.zip           # Test integrity
unzip archive.zip -d /path     # Extract to directory

7z a archive.7z files          # Create 7z archive
7z a -p archive.7z files       # With password
7z x archive.7z                # Extract
7z l archive.7z                # List contents
7z t archive.7z                # Test archive

rar a archive.rar files        # Create RAR
rar x archive.rar              # Extract RAR
unrar x archive.rar            # Extract RAR
```

---

## 13. Bash Scripting Essentials

### Variables
```bash
#!/bin/bash
NAME="John"                    # Variable
echo $NAME                     # Use variable
echo ${NAME}                   # Better syntax
readonly CONSTANT="value"      # Constant
export VAR="value"             # Environment variable

# Special variables
$0                             # Script name
$1, $2, ...                    # Arguments
$#                             # Number of arguments
$@                             # All arguments
$?                             # Exit status of last command
$$                             # Process ID
```

### Conditionals
```bash
# if statement
if [ condition ]; then
    commands
elif [ condition ]; then
    commands
else
    commands
fi

# File tests
[ -f file ]                    # File exists
[ -d directory ]               # Directory exists
[ -r file ]                    # Readable
[ -w file ]                    # Writable
[ -x file ]                    # Executable
[ -s file ]                    # Not empty
[ file1 -nt file2 ]            # file1 newer than file2

# String tests
[ -z "$str" ]                  # String is empty
[ -n "$str" ]                  # String is not empty
[ "$str1" = "$str2" ]          # Strings equal
[ "$str1" != "$str2" ]         # Strings not equal

# Numeric tests
[ $num1 -eq $num2 ]            # Equal
[ $num1 -ne $num2 ]            # Not equal
[ $num1 -gt $num2 ]            # Greater than
[ $num1 -lt $num2 ]            # Less than
[ $num1 -ge $num2 ]            # Greater or equal
[ $num1 -le $num2 ]            # Less or equal

# Logical operators
[ condition1 ] && [ condition2 ]  # AND
[ condition1 ] || [ condition2 ]  # OR
[ ! condition ]                   # NOT
```

### Loops
```bash
# for loop
for i in 1 2 3 4 5; do
    echo $i
done

for file in *.txt; do
    echo $file
done

for i in {1..10}; do
    echo $i
done

for ((i=1; i<=10; i++)); do
    echo $i
done

# while loop
while [ condition ]; do
    commands
done

counter=1
while [ $counter -le 10 ]; do
    echo $counter
    ((counter++))
done

# until loop
until [ condition ]; do
    commands
done

# break and continue
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue  # Skip 5
    fi
    if [ $i -eq 8 ]; then
        break     # Stop at 8
    fi
    echo $i
done
```

### Functions
```bash
# Function definition
function_name() {
    commands
    return value
}

# With parameters
greet() {
    echo "Hello, $1!"
}
greet "John"

# Return value
add() {
    result=$(($1 + $2))
    echo $result
}
sum=$(add 5 3)
echo $sum
```

### Input/Output
```bash
# Read user input
read -p "Enter name: " name
echo "Hello, $name"

# Read password (hidden)
read -sp "Enter password: " password
echo

# Read with timeout
read -t 5 -p "Enter (5s): " input

# Read single character
read -n 1 -p "Press any key"

# Command substitution
current_date=$(date +%Y-%m-%d)
files=$(ls *.txt)
lines=`cat file | wc -l`      # Old style (backticks)

# Arithmetic
result=$((5 + 3))              # Addition
result=$((5 - 3))              # Subtraction
result=$((5 * 3))              # Multiplication
result=$((10 / 2))             # Division
result=$((10 % 3))             # Modulo
result=$((2 ** 3))             # Exponent
((counter++))                  # Increment
((counter--))                  # Decrement
((counter += 5))               # Add 5

# String operations
string="Hello World"
echo ${#string}                # Length
echo ${string:0:5}             # Substring (Hello)
echo ${string:6}               # From position 6 (World)
echo ${string/World/Linux}     # Replace (Hello Linux)
echo ${string//o/0}            # Replace all o with 0
echo ${string^^}               # Uppercase
echo ${string,,}               # Lowercase
echo ${string#Hello }          # Remove prefix
echo ${string%World}           # Remove suffix

# Default values
echo ${var:-default}           # Use default if var empty
echo ${var:=default}           # Set and use default
echo ${var:?error}             # Error if empty
```

### Arrays
```bash
# Array declaration
arr=(one two three four)
arr[0]="first"

# Access elements
echo ${arr[0]}                 # First element
echo ${arr[@]}                 # All elements
echo ${arr[*]}                 # All elements
echo ${#arr[@]}                # Array length

# Iterate
for item in "${arr[@]}"; do
    echo $item
done

# Associative arrays (bash 4+)
declare -A assoc
assoc[key1]="value1"
assoc[key2]="value2"
echo ${assoc[key1]}
echo ${!assoc[@]}              # All keys
```

---

## 14. Advanced Administration

### One-Time Scheduled Tasks (at)
```bash
at now + 1 hour                # Schedule task in 1 hour
at 10:00 AM                    # Schedule for 10 AM
at 10:00 AM tomorrow           # Tomorrow at 10 AM
at 10:00 AM 2025-01-01         # Specific date
# Enter commands, then Ctrl+D to save

atq                            # List scheduled jobs
at -l                          # Same as atq
at -c jobid                    # Show job details
atrm jobid                     # Remove job
at -d jobid                    # Same as atrm

batch                          # Run when load is low
# Enter commands, then Ctrl+D

# Example
echo "tar -czf backup.tar.gz /data" | at now + 1 hour
```

### Scheduled Tasks (Cron)
```bash
crontab -e                     # Edit crontab
crontab -l                     # List crontab
crontab -r                     # Remove crontab
crontab -u username -e         # Edit user's crontab
sudo crontab -u user -e        # Edit user's crontab (as root)

# Cron format:
# MIN HOUR DOM MON DOW COMMAND
# *   *    *   *   *   command
# 0-59  0-23  1-31  1-12  0-7 (0 or 7 = Sunday)

# Special strings
@reboot command                # Run at startup
@yearly command                # 0 0 1 1 *
@annually command              # Same as @yearly
@monthly command               # 0 0 1 * *
@weekly command                # 0 0 * * 0
@daily command                 # 0 0 * * *
@midnight command              # Same as @daily
@hourly command                # 0 * * * *

# Examples:
0 2 * * * /path/to/script.sh           # Daily at 2 AM
*/15 * * * * /path/to/script.sh        # Every 15 minutes
0 */6 * * * /path/to/script.sh         # Every 6 hours
0 0 * * 0 /path/to/script.sh           # Weekly (Sunday midnight)
0 0 1 * * /path/to/script.sh           # Monthly (1st at midnight)
0 9-17 * * 1-5 /path/to/script.sh      # Weekdays 9 AM - 5 PM
30 4 1,15 * * /path/to/script.sh       # 1st and 15th at 4:30 AM

# System cron directories (run as root):
/etc/cron.hourly/
/etc/cron.daily/
/etc/cron.weekly/
/etc/cron.monthly/

# Anacron (for systems not always on)
sudo vim /etc/anacrontab
# period delay job-identifier command
1  5  daily-backup  /path/to/backup.sh  # Daily, 5 min delay
7  10 weekly-report /path/to/report.sh  # Weekly, 10 min delay
```

### Systemd Timers
```bash
# List timers
systemctl list-timers
systemctl list-timers --all

# Create timer
# /etc/systemd/system/mytask.timer
[Unit]
Description=My Task Timer

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
OnBootSec=10min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target

# /etc/systemd/system/mytask.service
[Unit]
Description=My Task

[Service]
Type=oneshot
ExecStart=/path/to/script.sh

# Enable timer
sudo systemctl daemon-reload
sudo systemctl enable mytask.timer
sudo systemctl start mytask.timer
sudo systemctl status mytask.timer

# OnCalendar examples:
OnCalendar=daily               # Every day at midnight
OnCalendar=weekly              # Every Monday at midnight
OnCalendar=monthly             # 1st of month at midnight
OnCalendar=*-*-* 02:00:00      # Every day at 2 AM
OnCalendar=Mon *-*-* 10:00:00  # Every Monday at 10 AM
OnCalendar=*-*-01 03:00:00     # 1st of month at 3 AM
OnCalendar=*-01,07-15 04:00:00 # 15th of Jan & Jul at 4 AM
```

### Environment Variables
```bash
env                            # List all variables
printenv                       # Same as env
printenv PATH                  # Specific variable
echo $PATH                     # Print PATH
echo $HOME                     # Home directory
echo $USER                     # Current user
echo $SHELL                    # Current shell
echo $PWD                      # Working directory
export VAR="value"             # Set for current session
export PATH=$PATH:/new/path    # Add to PATH
unset VAR                      # Remove variable

# Persistent variables
~/.bashrc                      # User-specific (interactive non-login)
~/.bash_profile                # User-specific (login shells)
~/.profile                     # User-specific (POSIX compatible)
/etc/environment               # System-wide (simple VAR=value)
/etc/profile                   # System-wide (login shells)
/etc/bash.bashrc               # System-wide (interactive)

# Set in ~/.bashrc
export EDITOR=vim
export JAVA_HOME=/usr/lib/jvm/java-11
export PATH=$PATH:$HOME/bin

# Source to reload
source ~/.bashrc
. ~/.bashrc                    # Same as source
```

### Performance Tuning
```bash
# Swappiness (0-100, default 60)
cat /proc/sys/vm/swappiness
sudo sysctl vm.swappiness=10
# Permanent: /etc/sysctl.conf or /etc/sysctl.d/99-custom.conf
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p                 # Reload sysctl

# File descriptor limits
ulimit -n                      # Current limit
ulimit -a                      # All limits
ulimit -n 4096                 # Set limit (session only)
# Permanent: /etc/security/limits.conf
*  soft  nofile  65536
*  hard  nofile  65536
*  soft  nproc   4096
*  hard  nproc   8192

# Network tuning
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
# Permanent: /etc/sysctl.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216

# View all sysctl parameters
sysctl -a
sysctl -a | grep net.ipv4

# Kernel parameters
cat /proc/sys/kernel/hostname
cat /proc/cmdline              # Boot parameters
```

### Sudo Configuration
```bash
sudo visudo                    # Edit sudoers safely
sudo visudo -f /etc/sudoers.d/custom

# Sudoers syntax:
# user    hosts=(runas) NOPASSWD: commands
username ALL=(ALL:ALL) ALL
username ALL=(ALL) NOPASSWD: ALL
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl
%groupname ALL=(ALL:ALL) ALL
%sudo ALL=(ALL:ALL) ALL

# Command aliases
Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig
username ALL = NETWORKING

# User aliases
User_Alias ADMINS = alice, bob
ADMINS ALL=(ALL) ALL

# Defaults
Defaults env_reset
Defaults mail_badpass
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults timestamp_timeout=15  # sudo timeout (minutes)
Defaults passwd_tries=3        # Password attempts
```

### Alternative Package Managers
```bash
# Snap (Ubuntu)
snap find package              # Search
snap list                      # Installed snaps
sudo snap install package      # Install
sudo snap refresh package      # Update
sudo snap remove package       # Remove
sudo snap revert package       # Revert to previous version

# Flatpak
flatpak search package         # Search
flatpak list                   # Installed apps
flatpak install flathub package
flatpak update                 # Update all
flatpak uninstall package      # Remove
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# AppImage
chmod +x application.AppImage
./application.AppImage         # Run

# pip (Python)
pip install package            # Install
pip install --user package     # User install
pip list                       # List packages
pip show package               # Package info
pip uninstall package          # Remove
pip freeze > requirements.txt  # Export
pip install -r requirements.txt # Install from file
```

---

## 15. Containers & Virtualization

### Docker
```bash
# Container management
docker ps                      # Running containers
docker ps -a                   # All containers
docker run image               # Run container
docker run -d image            # Detached mode
docker run -it image /bin/bash # Interactive
docker run -p 8080:80 image    # Port mapping
docker run -v /host:/container image  # Volume mount
docker run --name myapp image  # Named container
docker start container         # Start stopped container
docker stop container          # Stop container
docker restart container       # Restart container
docker rm container            # Remove container
docker rm -f container         # Force remove
docker exec -it container bash # Execute in running container
docker logs container          # View logs
docker logs -f container       # Follow logs
docker inspect container       # Detailed info
docker stats                   # Resource usage

# Image management
docker images                  # List images
docker pull image              # Download image
docker build -t name .         # Build from Dockerfile
docker tag image newtag        # Tag image
docker push image              # Upload to registry
docker rmi image               # Remove image
docker history image           # Image layers
docker save image > file.tar   # Export image
docker load < file.tar         # Import image

# System management
docker system df               # Disk usage
docker system prune            # Clean up
docker system prune -a         # Remove all unused
docker volume ls               # List volumes
docker volume rm volume        # Remove volume
docker network ls              # List networks
docker network create net      # Create network
```

### Podman (RHEL/Fedora)
```bash
# Similar to Docker
podman ps                      # Running containers
podman run -d image            # Run detached
podman images                  # List images
podman build -t name .         # Build image
podman pod create --name mypod # Create pod
podman pod ps                  # List pods
podman generate systemd container > container.service
```

### KVM/QEMU Virtualization
```bash
# Virtualization check
lsmod | grep kvm               # KVM modules loaded
egrep -c '(vmx|svm)' /proc/cpuinfo  # CPU virtualization support

# virsh (libvirt)
virsh list                     # Running VMs
virsh list --all               # All VMs
virsh start vm-name            # Start VM
virsh shutdown vm-name         # Graceful shutdown
virsh destroy vm-name          # Force stop
virsh undefine vm-name         # Remove VM definition
virsh autostart vm-name        # Enable autostart
virsh console vm-name          # Connect to console
virsh snapshot-create-as vm-name snap1  # Create snapshot
virsh snapshot-list vm-name    # List snapshots
virsh snapshot-revert vm-name snap1     # Restore snapshot
virsh dumpxml vm-name          # VM configuration
virt-install                   # Create new VM
virt-clone                     # Clone VM
```

---

## 16. Backup & Recovery

### rsync Backups
```bash
# Basic backup
rsync -av source/ destination/  # Archive mode, verbose
rsync -avz source/ user@host:dest/  # With compression
rsync -avz --delete src/ dst/   # Mirror (delete in dest)
rsync -avzP src/ dst/           # With progress
rsync -avz --exclude='*.log' src/ dst/  # Exclude files
rsync -avz --exclude-from=exclude.txt src/ dst/
rsync -avz --bwlimit=1000 src/ dst/  # Limit bandwidth (KB/s)

# Incremental backup
rsync -av --link-dest=/backup/previous /data/ /backup/current/

# Backup script example
#!/bin/bash
DATE=$(date +%Y-%m-%d)
rsync -avz --delete /data/ /backup/$DATE/
find /backup/ -mtime +30 -delete  # Keep 30 days
```

### tar Backups
```bash
# Create full backup
tar -czf backup-$(date +%Y%m%d).tar.gz /data

# Create with verification
tar -czvf backup.tar.gz /data

# Incremental backup
tar -czf full.tar.gz -g snapshot.file /data
tar -czf incremental.tar.gz -g snapshot.file /data

# Exclude files
tar -czf backup.tar.gz --exclude='*.log' --exclude='cache' /data

# Restore
tar -xzf backup.tar.gz -C /restore/path
tar -xzf backup.tar.gz --strip-components=1  # Remove top directory
```

### dd Imaging
```bash
# Full disk image
sudo dd if=/dev/sda of=/backup/disk.img bs=4M status=progress

# Compressed image
sudo dd if=/dev/sda bs=4M status=progress | gzip > disk.img.gz

# Restore
sudo dd if=/backup/disk.img of=/dev/sda bs=4M status=progress
gunzip -c disk.img.gz | sudo dd of=/dev/sda bs=4M status=progress

# Clone disk
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress
```

### Database Backups
```bash
# MySQL/MariaDB
mysqldump -u root -p database > backup.sql
mysqldump -u root -p --all-databases > all-dbs.sql
mysql -u root -p database < backup.sql  # Restore

# PostgreSQL
pg_dump dbname > backup.sql
pg_dumpall > all-dbs.sql
psql dbname < backup.sql               # Restore

# MongoDB
mongodump --db dbname --out /backup
mongorestore --db dbname /backup/dbname
```

### System Snapshots (Btrfs/LVM)
```bash
# LVM snapshots
sudo lvcreate -L 5G -s -n lv_data_snap /dev/vg_data/lv_data
sudo mount /dev/vg_data/lv_data_snap /mnt/snapshot
# Restore: merge snapshot
sudo lvconvert --merge /dev/vg_data/lv_data_snap

# Btrfs snapshots
sudo btrfs subvolume snapshot /data /data/.snapshots/$(date +%Y%m%d)
sudo btrfs subvolume list /data
sudo btrfs subvolume delete /data/.snapshots/20250101
```

---

## 17. Kernel & Modules

### Kernel Information
```bash
uname -r                       # Kernel version
uname -a                       # All info
cat /proc/version              # Detailed version
cat /proc/cmdline              # Boot parameters
hostnamectl                    # System info including kernel
```

### Kernel Modules
```bash
lsmod                          # List loaded modules
lsmod | grep module            # Check specific module
modinfo module                 # Module information
modinfo -p module              # Module parameters

sudo modprobe module           # Load module
sudo modprobe -r module        # Remove module
sudo modprobe module param=value  # Load with parameter

sudo insmod /path/to/module.ko # Insert module
sudo rmmod module              # Remove module

# Blacklist module (prevent loading)
echo "blacklist modulename" | sudo tee /etc/modprobe.d/blacklist.conf

# Auto-load at boot
echo "modulename" | sudo tee -a /etc/modules

# Module dependencies
sudo depmod -a                 # Generate module dependencies
cat /lib/modules/$(uname -r)/modules.dep
```

### Kernel Parameters
```bash
# View parameters
sysctl -a                      # All parameters
sysctl kernel.hostname         # Specific parameter

# Modify temporarily
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent (/etc/sysctl.conf or /etc/sysctl.d/*.conf)
net.ipv4.ip_forward=1
vm.swappiness=10
fs.file-max=500000

# Apply changes
sudo sysctl -p                 # Load /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.d/custom.conf
```

### Kernel Upgrade
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install linux-generic # Latest kernel
dpkg --list | grep linux-image # List installed kernels
sudo apt remove linux-image-x.x.x  # Remove old kernel
sudo update-grub               # Update bootloader

# RHEL/CentOS/Fedora
sudo dnf update kernel         # Update kernel
rpm -qa | grep kernel          # List kernels
sudo dnf remove kernel-x.x.x   # Remove old
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Reboot to new kernel
sudo reboot
```

### GRUB Configuration
```bash
# Edit GRUB
sudo vim /etc/default/grub
# Common settings:
GRUB_TIMEOUT=10                # Boot menu timeout
GRUB_DEFAULT=0                 # Default entry
GRUB_CMDLINE_LINUX="quiet splash"  # Kernel parameters

# Update GRUB
sudo update-grub               # Ubuntu/Debian
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # RHEL/CentOS

# List GRUB entries
grep menuentry /boot/grub/grub.cfg
```

---

## Quick Reference: Most Used Commands

**Daily Use (Top 20)**:
```bash
ls, cd, pwd, cat, less, grep
cp, mv, rm, mkdir, touch
ps, top, kill, systemctl
df, du, free, tail, chmod
sudo
```

**Essential for Troubleshooting (Top 15)**:
```bash
journalctl, dmesg, tail -f
ps aux, top, htop, lsof
ss, ip addr, ping, curl
systemctl status, df -h
grep, find, which
```

**Certification Essentials (LFCS/RHCSA)**:
```bash
# User/Group: useradd, usermod, passwd, groupadd
# Permissions: chmod, chown, chgrp
# systemd: systemctl, journalctl
# Network: nmcli, ip, ss
# Storage: lsblk, fdisk, mkfs, mount, lvm commands
# Firewall: firewall-cmd
# SELinux: getenforce, semanage, restorecon
# Package: dnf/apt
# Monitoring: top, free, df, du
# Text: grep, sed, awk, find
```

---

**Master these commands and you'll handle 95% of Linux administration tasks! 🚀**

For more detailed examples and scenarios, see the other documentation files in this series.