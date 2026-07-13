# Linux Interview Questions: Beginner (0 to 2 Years)

## Focus Areas

- shell basics
- files and directories
- users and permissions
- processes
- networking basics
- SSH
- package management basics

## Fundamentals

### 1. What is Linux?
Short answer:
Linux is an open-source operating system built around the Linux kernel.

Better answer:
Linux is widely used for servers, cloud systems, and containers because it is stable, scriptable, and highly configurable. In interviews I usually mention that Linux strictly refers to the kernel, while distributions provide the full usable operating system.

### 2. Difference between Linux kernel and distribution?
Short answer:
The kernel is the core of the operating system, while a distribution is the full package built around it.

Better answer:
The kernel handles low-level tasks like process scheduling and hardware interaction. A distribution like Ubuntu or RHEL includes the kernel plus packages, tools, libraries, and configuration defaults.

### 3. What is the shell?
Short answer:
The shell is a command-line interface used to interact with the operating system.

Better answer:
The shell is both an interactive command interpreter and a scripting environment. Tools like `bash`, `zsh`, and `sh` let us run commands, automate tasks, and chain operations efficiently.

### 4. Difference between absolute path and relative path?
Short answer:
An absolute path starts from root, and a relative path depends on the current directory.

Better answer:
For example, `/var/log` is absolute because it starts from root. `../logs` is relative because it depends on where I currently am. I prefer absolute paths in scripts when predictability matters.

### 5. What do `pwd`, `ls`, `cd`, `mkdir`, `rm`, and `cp` do?
Short answer:
They show current location, list files, change directory, create directories, remove files, and copy files.

Better answer:
These are basic daily-use commands. I also mention safe usage, especially with `rm`, because the interviewer usually wants practical awareness, not only command expansion.

## Filesystem

### 6. What is the Linux filesystem hierarchy?
Short answer:
It is the standard directory structure used to organize config, binaries, logs, temp files, and user data.

Better answer:
Important paths include `/etc` for config, `/var` for logs and variable data, `/home` for user directories, `/tmp` for temp data, `/usr` for many installed programs, `/bin` for essential binaries, and `/opt` for optional software.

### 7. Difference between hard link and soft link?
Short answer:
A hard link points to the same inode, while a soft link points to a path.

Better answer:
A hard link behaves like another name for the same file and usually cannot cross filesystems. A soft link is more flexible and can point to directories, but it breaks if the target path disappears.

### 8. How do you check disk usage?
Short answer:
Use `df -h` for filesystem usage and `du -sh` for directory usage.

Better answer:
`df -h` shows which filesystem is full, while `du -sh *` helps identify which directory is consuming space. In troubleshooting I usually use both together.

## Users and Permissions

### 9. Difference between user, group, and other permissions?
Short answer:
User permissions are for the owner, group permissions are for the file's group, and other permissions are for everyone else.

Better answer:
Linux permissions are based on owner, group, and others, and each category can have read, write, and execute rights. I often explain them using `ls -l` output because it shows practical understanding.

### 10. What do `chmod`, `chown`, and `chgrp` do?
Short answer:
`chmod` changes permissions, `chown` changes owner, and `chgrp` changes group.

Better answer:
These commands are often used together during troubleshooting. If access fails, I check both permission bits and ownership instead of assuming only one of them is the problem.

### 11. What does `755` mean?
Short answer:
Owner gets read, write, execute; group and others get read and execute.

Better answer:
`7` means read, write, execute and `5` means read and execute. `755` is common for directories and executable scripts where the owner can modify but others can still access or run them.

### 12. What is `sudo`?
Short answer:
`sudo` lets an authorized user run commands with elevated privileges.

Better answer:
`sudo` is safer than logging in directly as root for routine work because it supports controlled privilege escalation and usually leaves an audit trail.

### 13. Difference between `su` and `sudo`?
Short answer:
`su` switches user context, while `sudo` runs a specific command with another user's privileges.

Better answer:
`su` is more like moving into another account session. `sudo` is more controlled and is preferred in most administration workflows because it grants limited elevated access per command.

## Processes and systemd

### 14. How do you list running processes?
Short answer:
Use `ps`, `top`, or `htop`.

Better answer:
`ps -ef` gives a process snapshot, while `top` or `htop` helps with live monitoring of CPU and memory. I choose based on whether I need a quick list or a real-time view.

### 15. What is a PID?
Short answer:
PID is the unique process ID of a running process.

Better answer:
The PID helps identify, inspect, or stop a specific process. It is basic but important in troubleshooting and monitoring.

### 16. How do you kill a process?
Short answer:
Use `kill`, `kill -9`, or `pkill`.

Better answer:
I prefer to start with a normal `kill` signal so the process can stop gracefully. I use `kill -9` only when the process is stuck and not responding.

### 17. What is systemd?
Short answer:
`systemd` is the service manager used by many Linux systems.

Better answer:
It manages service startup, restart behavior, status checks, and boot-time orchestration. In practice it matters because most server-side services are managed through `systemctl`.

### 18. How do you start, stop, restart, and check a service?
Short answer:
Use `systemctl start`, `stop`, `restart`, and `status`.

Better answer:
I usually begin with `systemctl status` so I understand the current state before taking action. Then I use start, stop, or restart as needed and check logs if the service is failing repeatedly.

## Networking

### 19. How do you check IP address in Linux?
Short answer:
Use `ip a` or `hostname -I`.

Better answer:
`ip a` is more complete because it shows interfaces and assigned addresses. `hostname -I` is a quick shortcut when I only need the IP output.

### 20. How do you test connectivity?
Short answer:
Use `ping`, `curl`, `ssh`, and sometimes port-level tools.

Better answer:
I choose based on the layer being tested. `ping` checks basic reachability, `curl` checks HTTP behavior, `ssh` checks remote login access, and port checks help confirm whether a service is actually listening.

### 21. What is DNS?
Short answer:
DNS maps domain names to IP addresses.

Better answer:
DNS is the naming system that allows systems to find each other without remembering IP addresses directly. DNS failures can make healthy services look unavailable.

### 22. Difference between `scp` and `rsync`?
Short answer:
`scp` does direct copy, while `rsync` is better for efficient repeated sync and transfer.

Better answer:
`rsync` is preferred for larger or repeated file transfers because it can transfer only the changed parts. `scp` is simpler and fine for quick one-time copies.

## Scripting Basics

### 23. What is a shell script?
Short answer:
A shell script is a file of shell commands that runs as a program.

Better answer:
Shell scripts are useful for automating repetitive Linux tasks such as deployment steps, monitoring checks, file operations, and environment setup.

### 24. How do you pass arguments to a shell script?
Short answer:
Pass values after the script name and access them with `$1`, `$2`, and `$@`.

Better answer:
I explain that `$1` is the first argument, `$2` is the second, and `$@` represents all arguments. In practical scripts I also validate required arguments early.

### 25. What is the difference between `#!/bin/bash` and running commands manually?
Short answer:
The shebang tells the system which interpreter should run the script.

Better answer:
When I run commands manually, I use the current shell session. When I use `#!/bin/bash`, I make the interpreter explicit so the script behaves consistently during automation.

## Beginner Scenarios

### 26. A file says permission denied. What do you check?
Short answer:
I check ownership, permission bits, parent directory permissions, and whether elevated access is required.

Better answer:
I start with `ls -l` and also check the parent directory because directory permissions affect access too. I avoid blindly setting `777` because that is unsafe and usually not the real fix.

### 27. Disk is full. What are your first 3 commands?
Short answer:
`df -h`, `du -sh *`, and then detailed checks inside the biggest directory.

Better answer:
First I identify which filesystem is full with `df -h`. Then I locate the largest consumers using `du -sh`. After that I clean only understood and safe data such as old logs or temp artifacts.

### 28. Service is down. What do you check first?
Short answer:
I check service status, logs, and dependency failures.

Better answer:
My first command is usually `systemctl status` because it quickly shows whether the service failed to start, crashed, or is disabled. Then I review logs and verify config, ports, permissions, and dependencies.

### 29. SSH is not working. What basic checks do you do?
Short answer:
I check reachability, SSH service status, firewall or security rules, credentials, and the target port.

Better answer:
I verify the host is reachable, confirm the SSH daemon is running, check whether the correct port is open, and validate the user and key or password. If needed, I also inspect firewall, security group, or SSH server logs.

### 30. You need to find a file quickly. Which commands can help?
Short answer:
`find`, `locate`, `grep`, and `ls`.

Better answer:
`find` is the most reliable because it searches the filesystem directly with filters like name, type, or time. `locate` is faster when its database is updated, and `grep` helps when I need to search file contents instead of filenames.

## What to Revise Before Interview

- navigation commands
- permissions
- users and groups
- process commands
- `systemctl`
- `ssh`, `scp`, `rsync`
- `df`, `du`, `find`, `grep`
- explain troubleshooting steps in sequence
