# Linux 12 – Kernel, Modules & System Tuning

## 0. Goal of This Note

- Understand the Linux kernel and its role.  
- Learn kernel module management.  
- Master sysctl for kernel parameter tuning.  
- Optimize system performance.  
- Update and compile custom kernels (overview).

---

## 1. Understanding the Linux Kernel

### 1.1 Kernel Information

**View kernel version:**
```bash
uname -r                         # kernel release
uname -a                         # all system info
cat /proc/version                # detailed version
hostnamectl                      # includes kernel info
```

**Example output:**
```
6.1.0-17-amd64
│││└─ architecture
││└── patch level
│└─── minor version
└──── major version
```

**Kernel types:**
- **Mainline**: Latest features, bleeding edge
- **Stable**: Bug fixes for mainline
- **Longterm (LTS)**: Extended support (2-6 years)
- **Distribution kernel**: Vendor-patched (Ubuntu, RHEL, etc.)

### 1.2 Kernel Ring Buffer (dmesg)

**View boot messages:**
```bash
dmesg                            # all kernel messages
dmesg | less                     # scrollable
dmesg | tail -50                 # last 50 messages
dmesg -T                         # human-readable timestamps
dmesg -w                         # follow mode (like tail -f)

# Filter by log level
dmesg -l err                     # errors only
dmesg -l warn                    # warnings
dmesg -l info                    # info messages

# Filter by facility
dmesg -f kern                    # kernel messages
```

**Clear dmesg:**
```bash
sudo dmesg -C
```

**Save dmesg:**
```bash
dmesg > boot_messages.log
```

### 1.3 Kernel Parameters at Boot

View current boot parameters:
```bash
cat /proc/cmdline
```

Edit GRUB to add parameters:
```bash
sudo vim /etc/default/grub

# Modify this line:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Common parameters:
# - quiet: less verbose
# - nomodeset: disable kernel mode setting (GPU issues)
# - acpi=off: disable ACPI (hardware issues)
# - maxcpus=2: limit CPUs
# - mem=4G: limit RAM

# Update GRUB
sudo update-grub                 # Debian/Ubuntu
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # RHEL/Fedora
```

---

## 2. Kernel Modules

### 2.1 What Are Kernel Modules?

**Kernel modules** are pieces of code that can be loaded/unloaded into the kernel without rebooting.

- Drivers (network, USB, filesystem)
- Filesystem support
- Hardware support
- Features (e.g., netfilter, crypto)

### 2.2 Module Management Commands

**List loaded modules:**
```bash\nlsmod                            # list all loaded modules
lsmod | grep module_name         # find specific module
```

**Module information:**
```bash
modinfo module_name              # detailed info
modinfo -p module_name           # parameters
modinfo e1000e                   # example: Intel network driver

# Example output shows:
# - filename, description, author
# - license, dependencies
# - available parameters
```

**Load module:**
```bash
sudo modprobe module_name        # load with dependencies
sudo modprobe -v module_name     # verbose
sudo insmod /path/to/module.ko   # low-level, no dependencies
```

**Unload module:**
```bash
sudo modprobe -r module_name     # unload with dependencies
sudo rmmod module_name           # low-level, no dependencies
```

**Load module with parameters:**
```bash
sudo modprobe module_name param1=value1 param2=value2
```

### 2.3 Persistent Module Configuration

**Blacklist module (prevent loading):**
```bash
# Create blacklist file
sudo vim /etc/modprobe.d/blacklist-custom.conf

# Add:
blacklist module_name

# Rebuild initramfs
sudo update-initramfs -u         # Debian/Ubuntu
sudo dracut --force              # RHEL/Fedora
```

**Load module at boot:**
```bash
# Add to /etc/modules (Debian/Ubuntu)
echo "module_name" | sudo tee -a /etc/modules

# Or /etc/modules-load.d/custom.conf
echo "module_name" | sudo tee /etc/modules-load.d/custom.conf
```

**Module parameters at boot:**
```bash
# Create file in /etc/modprobe.d/
sudo vim /etc/modprobe.d/module_name.conf

# Add parameters:
options module_name param1=value1 param2=value2

# Example for Intel wireless:
options iwlwifi 11n_disable=1 swcrypto=1
```

### 2.4 Finding Module Dependencies

```bash
# Show dependencies
modprobe --show-depends module_name

# Module dependency file
cat /lib/modules/$(uname -r)/modules.dep

# Update module dependencies
sudo depmod -a
```

---

## 3. sysctl – Kernel Parameter Tuning

### 3.1 What is sysctl?

**sysctl** allows reading and modifying kernel parameters at runtime via `/proc/sys/`.

### 3.2 Viewing Parameters

```bash
# View all parameters
sysctl -a                        # all (thousands)
sysctl -a | grep keyword         # filter

# View specific parameter
sysctl net.ipv4.ip_forward
cat /proc/sys/net/ipv4/ip_forward  # same thing

# Common categories
sysctl -a | grep '^kernel\.'     # kernel parameters
sysctl -a | grep '^vm\.'         # virtual memory
sysctl -a | grep '^net\.'        # network
sysctl -a | grep '^fs\.'         # filesystem
```

### 3.3 Modifying Parameters (Temporary)

```bash
# Set parameter (until reboot)
sudo sysctl -w net.ipv4.ip_forward=1

# Or directly:
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

### 3.4 Persistent Configuration

**Main config file:**
```bash
sudo vim /etc/sysctl.conf

# Or create custom file (preferred):
sudo vim /etc/sysctl.d/99-custom.conf
```

**Apply changes:**
```bash
sudo sysctl -p                   # load /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.d/99-custom.conf  # specific file
sudo sysctl --system             # load all config files
```

### 3.5 Important Tuning Parameters

**Network Performance:**
```bash
# /etc/sysctl.d/99-network-tune.conf

# Enable IP forwarding (for router/gateway)
net.ipv4.ip_forward = 1

# Increase TCP buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Increase connection backlog
net.core.somaxconn = 4096
net.core.netdev_max_backlog = 5000

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# Reduce TIME_WAIT connections
net.ipv4.tcp_tw_reuse = 1

# Protect against SYN flood attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 8192
```

**Virtual Memory (swap behavior):**
```bash
# /etc/sysctl.d/99-vm-tune.conf

# Swappiness (0-100, lower = less swap)
# 0 = only swap to prevent OOM
# 10 = recommended for servers
# 60 = default
# 100 = swap aggressively
vm.swappiness = 10

# Dirty ratio (memory that can be dirty before sync)
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Cache pressure (higher = reclaim cache more aggressively)
vm.vfs_cache_pressure = 50
```

**Filesystem Limits:**
```bash
# /etc/sysctl.d/99-fs-tune.conf

# Increase file handles
fs.file-max = 2097152

# Increase inotify limits (for file watching)
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
```

**Kernel Security:**
```bash
# /etc/sysctl.d/99-security.conf

# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Enable bad error message protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1

# Log martian packets
net.ipv4.conf.all.log_martians = 1

# Protect against SYN flood
net.ipv4.tcp_syncookies = 1

# Randomize kernel addresses (KASLR)
kernel.randomize_va_space = 2
```

**System Limits:**
```bash
# Maximum PID value
kernel.pid_max = 4194304

# Core dump settings
kernel.core_pattern = /var/crash/core.%e.%p.%t
kernel.core_uses_pid = 1

# Shared memory limits
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
```

---

## 4. System Performance Tuning

### 4.1 CPU Tuning

**View CPU info:**
```bash
lscpu                            # detailed CPU info
cat /proc/cpuinfo                # raw CPU data
nproc                            # number of processors
```

**CPU governor (frequency scaling):**
```bash
# View current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Available governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Common governors:
# - performance: max frequency always
# - powersave: min frequency
# - ondemand: scale based on load
# - conservative: gradual scaling
# - schedutil: scheduler-based (modern)

# Set governor (temporary)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Or use cpupower tool
sudo apt install linux-tools-generic  # Debian/Ubuntu
sudo cpupower frequency-set -g performance
```

**Process priority (nice values):**
```bash
# Run with lower priority
nice -n 10 command               # niceness 10 (lower priority)
nice -n -5 sudo command          # niceness -5 (higher, requires root)

# Change running process priority
renice -n 5 -p PID
renice -n -10 -p PID             # requires root for negative values
```

**CPU affinity:**
```bash
# Pin process to specific CPUs
taskset -c 0,1 command           # run on CPU 0 and 1
taskset -p 0,1 PID               # set for running process

# View affinity
taskset -p PID
```

### 4.2 Memory Tuning

**Huge pages:**
```bash
# View huge page info
cat /proc/meminfo | grep Huge

# Configure huge pages
sudo sysctl -w vm.nr_hugepages=1024

# Persistent
echo "vm.nr_hugepages = 1024" | sudo tee -a /etc/sysctl.d/99-hugepages.conf
```

**Transparent Huge Pages (THP):**
```bash
# Check status
cat /sys/kernel/mm/transparent_hugepage/enabled

# Disable (sometimes needed for databases)
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# Persistent
sudo vim /etc/default/grub
# Add to GRUB_CMDLINE_LINUX_DEFAULT:
# transparent_hugepage=never
sudo update-grub
```

### 4.3 I/O Scheduler

**View current scheduler:**
```bash
cat /sys/block/sda/queue/scheduler

# Output: [mq-deadline] none
# Brackets show active scheduler
```

**Available schedulers:**
- **mq-deadline**: Default for most systems, good balance
- **none**: No scheduling (for fast NVMe drives)
- **bfq**: Best for desktops, interactive workloads
- **kyber**: Low-latency for fast storage

**Change scheduler:**
```bash
# Temporary
echo bfq | sudo tee /sys/block/sda/queue/scheduler

# Persistent (via udev rule)
sudo vim /etc/udev/rules.d/60-scheduler.rules
# Add:
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
```

**I/O priority (ionice):**
```bash
# Classes: 0=none, 1=realtime, 2=best-effort, 3=idle

# Run with idle priority
ionice -c 3 command

# Change running process
ionice -c 2 -n 0 -p PID          # best-effort, priority 0 (highest)
```

---

## 5. Kernel Updates

### 5.1 Updating Kernel (Package Manager)

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt upgrade                 # upgrades kernel if available
sudo apt dist-upgrade            # for major kernel updates

# Install specific version
apt search linux-image
sudo apt install linux-image-5.15.0-56-generic
```

**RHEL/Fedora:**
```bash
sudo dnf update kernel           # install new kernel (keeps old)
sudo dnf list kernel             # list installed kernels
```

**Reboot:**
```bash
sudo reboot
```

**Check new kernel:**
```bash
uname -r
```

### 5.2 Managing Multiple Kernels

**List installed kernels:**
```bash
# Debian/Ubuntu
dpkg -l | grep linux-image

# RHEL/Fedora
rpm -qa | grep kernel

# Or check GRUB menu at boot
```

**Remove old kernels:**
```bash
# Debian/Ubuntu
sudo apt autoremove              # removes old kernels
sudo apt purge linux-image-x.x.x-xx-generic

# RHEL/Fedora
sudo dnf remove kernel-x.x.x
```

**Set default kernel in GRUB:**
```bash
# Debian/Ubuntu
sudo vim /etc/default/grub
GRUB_DEFAULT=0                   # 0 = first entry, 1 = second, etc.
# Or use saved:
GRUB_DEFAULT=saved
sudo grub-set-default 0
sudo update-grub
```

---

## 6. Custom Kernel Compilation (Overview)

**WARNING**: For advanced users only. Not recommended for production.

```bash
# 1. Install dependencies
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev

# 2. Download kernel source
cd /usr/src
sudo wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.tar.xz
sudo tar -xvf linux-6.1.tar.xz
cd linux-6.1

# 3. Configure
make menuconfig                  # interactive configuration
# Or copy current config:
cp /boot/config-$(uname -r) .config
make olddefconfig                # update to new kernel version

# 4. Compile (this takes time!)
make -j$(nproc)                  # use all CPU cores

# 5. Install modules
sudo make modules_install

# 6. Install kernel
sudo make install

# 7. Update GRUB
sudo update-grub

# 8. Reboot
sudo reboot
```

---

## 7. Practice Exercises

1. **Module management:**
   - Find and load a module (e.g., `dummy` network driver)
   - View its parameters with `modinfo`
   - Unload it
   - Blacklist it

2. **sysctl tuning:**
   - Check current swappiness
   - Set it to 10 temporarily
   - Make it permanent
   - Test by monitoring `vmstat`

3. **Performance:**
   - Check current I/O scheduler
   - Test different schedulers with `dd` benchmark
   - Set CPU governor to `performance`
   - Monitor with `htop`

4. **Kernel update:**
   - Check current kernel version
   - Update to latest available
   - Verify new kernel after reboot
   - Keep old kernel as backup

Next: **Linux 13 – Containers & Virtualization** for Docker and VMs.
