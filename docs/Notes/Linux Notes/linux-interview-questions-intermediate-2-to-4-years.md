# Linux Interview Questions: Intermediate (2 to 4 Years)

## Focus Areas

- system administration
- systemd and boot
- storage and LVM
- networking and troubleshooting
- shell scripting
- monitoring and logging
- Docker and package-management basics

## Sysadmin and Boot

### 1. Explain the Linux boot process at a practical level.
Short answer:
The flow is BIOS or UEFI, bootloader, kernel, init or systemd, and then system services.

Better answer:
At a practical level, the firmware initializes hardware, the bootloader loads the kernel, the kernel initializes devices and mounts the root filesystem, and then `systemd` or another init system starts userspace services. In interviews, I explain both the sequence and how I would debug failures at each stage.

### 2. What is the difference between a service, target, and unit in systemd?
Short answer:
A unit is the general configuration object, a service unit manages a process, and a target groups units into a desired system state.

Better answer:
`systemd` uses units for many object types such as services, mounts, timers, and targets. A service unit manages a background process, while a target is more like a grouping or milestone such as `multi-user.target`.

### 3. How do you investigate why a service failed to start?
Short answer:
Start with `systemctl status` and `journalctl -u <service>`.

Better answer:
I first inspect the unit status and recent logs, then check exit codes, environment files, file permissions, missing dependencies, and whether the service account or runtime path is correct.

Sample:
```bash
systemctl status nginx
journalctl -u nginx -n 100 --no-pager
```

## Storage and Filesystems

### 4. Difference between ext4, XFS, and Btrfs?
Short answer:
`ext4` is common and stable, `XFS` is strong for large filesystems and throughput, and `Btrfs` provides advanced features like snapshots.

Better answer:
I describe them in terms of tradeoffs. `ext4` is a safe general-purpose choice, `XFS` is often chosen for performance and large-scale storage, and `Btrfs` offers modern features such as snapshots and checksumming but may require more operational familiarity.

### 5. What is LVM and why is it useful?
Short answer:
LVM is Logical Volume Management that abstracts storage into physical volumes, volume groups, and logical volumes.

Better answer:
LVM makes storage more flexible because disks can be grouped and resized more easily than with fixed partitions alone. It is especially helpful when a filesystem needs to grow without redesigning the whole disk layout.

### 6. How do you extend a filesystem or logical volume?
Short answer:
Extend the logical volume first, then grow the filesystem.

Better answer:
The exact commands depend on the filesystem type, but the general flow is to increase the underlying logical volume and then expand the mounted filesystem safely. I always verify available space, backups, and filesystem type before resizing.

Sample:
```bash
lvextend -L +10G /dev/vgdata/lvapp
resize2fs /dev/vgdata/lvapp
```

### 7. What is `/etc/fstab` used for?
Short answer:
It defines persistent filesystem mount configuration.

Better answer:
`/etc/fstab` tells the system what to mount at boot or on demand, where to mount it, and which options to use. It is important for consistency but must be edited carefully.

### 8. What happens if `/etc/fstab` is wrong?
Short answer:
Boot can hang, drop to emergency mode, or fail to mount important filesystems.

Better answer:
A bad `fstab` entry can make the system partially unusable after reboot. That is why I validate with `mount -a` before assuming the change is safe.

## Networking and Security

### 9. How do you troubleshoot a server that has no internet connectivity?
Short answer:
Check IP configuration, routes, DNS, firewall rules, and gateway reachability.

Better answer:
I work from local to external: verify interface status, confirm IP and default route, test the gateway, test by IP, then test DNS. That sequence quickly separates routing issues from name-resolution issues.

### 10. Difference between `iptables` and `nftables` conceptually?
Short answer:
`iptables` is the older packet-filtering interface, while `nftables` is the newer framework that simplifies rule management.

Better answer:
I explain that many Linux systems historically used `iptables`, but `nftables` provides a more unified and modern rule engine. In practice, the key point is understanding packet filtering and troubleshooting, not memorizing every command.

### 11. What is the purpose of SSH key-based authentication?
Short answer:
It provides stronger and more automatable authentication than passwords.

Better answer:
SSH keys reduce brute-force risk, support automation, and work well with restricted access policies. In production, key-based auth is usually preferred over password login.

### 12. How would you harden SSH on a Linux server?
Short answer:
Use keys, restrict root login, disable password auth where possible, limit access, and audit logs.

Better answer:
I usually focus on key-based authentication, careful root-login policy, firewall restrictions, allowed-user controls, logging, and timely patching. Hardening should improve safety without breaking legitimate operational access.

## Monitoring and Logging

### 13. Difference between `top`, `htop`, `vmstat`, `iostat`, and `sar`?
Short answer:
They all help with performance visibility, but each focuses on different runtime details.

Better answer:
`top` and `htop` show live process-level usage, `vmstat` helps with CPU, memory, and context-switch view, `iostat` focuses on disk I/O, and `sar` is useful for historical performance analysis.

### 14. How do you investigate high CPU or memory usage?
Short answer:
Identify the top consumers, then determine whether the issue is process behavior, load pattern, leak, or system pressure.

Better answer:
For CPU I check process usage, run queue, and whether the load is user, system, or wait-related. For memory I look at resident usage, cache, swap activity, and whether the OOM killer or memory leak behavior is visible.

### 15. How do you use `journalctl` effectively?
Short answer:
Use it to query systemd logs by unit, time, priority, or boot.

Better answer:
`journalctl` is powerful because it lets me narrow logs by service, recent time window, boot instance, or severity. That is much faster than scanning general log files blindly.

Sample:
```bash
journalctl -u docker --since "1 hour ago"
journalctl -p err -b
```

### 16. What is log rotation and why is it important?
Short answer:
Log rotation prevents logs from growing indefinitely and consuming disk space.

Better answer:
It also helps with retention policy, filesystem health, and operational stability. Uncontrolled logging can fill disks and become a production incident by itself.

## Shell Scripting

### 17. How do you handle errors in shell scripts?
Short answer:
Check exit codes, validate inputs, quote variables, and fail safely.

Better answer:
I treat shell scripts as operational code. That means defensive checks, useful logging, predictable exit behavior, and avoiding assumptions that could turn a simple mistake into destructive behavior.

### 18. Difference between `awk`, `sed`, and `grep`?
Short answer:
`grep` searches, `sed` edits streams, and `awk` is stronger for structured text processing.

Better answer:
I usually choose `grep` for filtering, `sed` for substitutions, and `awk` when I need field-aware processing or light reporting logic.

### 19. When do you prefer `rsync` over `cp`?
Short answer:
When I need efficient repeated copy, synchronization, metadata preservation, or remote transfer.

Better answer:
`rsync` is better when large directory trees or repeated syncs are involved because it can transfer only changes and preserve important attributes more flexibly.

### 20. What are common mistakes in shell scripting?
Short answer:
Unquoted variables, unsafe globs, ignoring exit codes, and destructive assumptions.

Better answer:
I also watch for scripts that assume a current directory, run as root unnecessarily, or mix validation and destructive actions without clear safeguards.

## Containers and Packaging

### 21. Difference between package manager installation and compiling from source?
Short answer:
Package managers provide tested managed packages, while source compilation gives more control but more maintenance overhead.

Better answer:
I prefer package-manager installation when possible because it integrates better with updates and security fixes. Compiling from source is usually justified only for special version or feature needs.

### 22. Difference between containers and VMs?
Short answer:
Containers share the host kernel, while VMs run separate guest operating systems.

Better answer:
That makes containers lighter and faster to start, while VMs offer stronger isolation boundaries and more OS flexibility.

### 23. Basic Docker troubleshooting questions you should know?
Short answer:
Know image vs container, volume vs bind mount, port mapping, startup command, and how to inspect logs.

Better answer:
Interviewers usually want to see that you can reason about build-time versus runtime issues. For example, a correct image can still fail because of bad env vars, missing mounts, or wrong published ports.

## Real-World Scenarios

### 24. A Linux server is slow. How do you narrow the bottleneck?
Short answer:
Check CPU, memory, disk I/O, network, process list, and recent logs.

Better answer:
I avoid guessing. I inspect system load, top processes, swap or OOM signals, disk wait, network saturation, and any recent deployment or config change. The goal is to identify whether the bottleneck is compute, memory, storage, or external dependency.

### 25. A service starts but the app is not reachable. What do you check?
Short answer:
Check listening port, firewall, bind address, service config, reverse proxy, and application logs.

Better answer:
A started process does not prove the app is exposed correctly. I verify whether it is listening on the expected interface and port, whether the service definition and firewall allow traffic, and whether an upstream proxy is routing correctly.

### 26. A filesystem is mounted read-only unexpectedly. What might you investigate?
Short answer:
Check kernel logs, disk health, filesystem errors, and whether the remount happened for protection.

Better answer:
Read-only remount often signals underlying corruption or I/O errors. I check `dmesg`, SMART or storage health, recent kernel messages, and whether the filesystem needs repair during a maintenance window.

### 27. A cron job did not run. What do you verify?
Short answer:
Check cron service status, schedule syntax, user context, environment assumptions, permissions, and logs.

Better answer:
Cron often fails because of path differences, missing environment variables, bad file permissions, or incorrect schedule syntax. I also confirm whether output was redirected somewhere useful.

### 28. DNS resolution works on one host but not another. What steps do you take?
Short answer:
Compare resolver config, DNS server reachability, search domains, firewall rules, and caching behavior.

Better answer:
I check `/etc/resolv.conf`, test name resolution directly, compare working and failing hosts, and separate whether the issue is local config, DNS server availability, or network path differences.

## What to Revise Before Interview

- `systemctl` and `journalctl`
- LVM basics
- networking troubleshooting
- logging and monitoring
- shell scripting
- Docker fundamentals
