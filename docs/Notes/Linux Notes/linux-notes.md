# Linux Master Notes (Beginner to Pro)

> Use these notes as a long-term reference. Read in order if you are new, or jump to sections as needed.

---

## 0. How To Use These Notes

- Run commands in a Linux terminal (WSL on Windows, a VM, or a real Linux install).
- Lines starting with `$` are commands you type (do **not** type the `$`).
- Lines starting with `#` (inside code blocks) are comments explaining commands.
- Practice each command as you read – don’t just read.

Example:
```bash
$ ls        # list files in current directory
```

---

## 1. What is Linux?

- **Kernel**: Core part of the OS managing hardware and processes.
- **GNU tools**: Command-line utilities (ls, cp, mv, etc.).
- **Distribution (distro)**: Complete OS package (Ubuntu, Debian, Fedora, Arch, etc.).
- **Shell**: Program that takes your commands (bash, zsh, fish).

Key ideas:
- Everything is a **file** (devices, pipes, sockets, etc. are represented as files).
- Linux is **multi-user** and **multi-tasking**.

---

## 2. Getting a Linux Environment

You can use Linux in several ways:

- **WSL (Windows Subsystem for Linux)** on Windows (recommended for you):
  - Enable WSL and install Ubuntu from Microsoft Store.
- **Virtual Machine**: Use VirtualBox / VMware and install a distro ISO.
- **Dual boot / Bare metal**: Install Linux directly on hardware.

Check your shell:
```bash
$ echo $SHELL
```

Common shells:
- `/bin/bash` – Bourne Again Shell (default on many distros)
- `/bin/zsh` – Z shell

---

## 3. Basic Terminal Usage

### 3.1 Opening a Terminal

- GUI: search for "Terminal" or press shortcut (often `Ctrl+Alt+T`).
- In WSL: open Windows Terminal or PowerShell and run:
  ```bash
  wsl
  ```

### 3.2 Basic Navigation

```bash
$ pwd           # print working directory
$ ls            # list files
$ ls -l         # long listing
$ ls -a         # include hidden files (starting with .)
$ cd /path      # change directory
$ cd            # go to home directory
$ cd ..         # go up one directory
$ cd -          # go to previous directory
```

Useful shortcuts:
- `Ctrl + C` – stop/cancel current command.
- `Ctrl + D` – send EOF / logout from shell.
- `Ctrl + L` – clear screen.

Command history:
- Up / Down arrow – previous / next commands.
- `history` – show command history.
- `!n` – run command number `n` from history.

---

## 4. Filesystem Basics

### 4.1 Path Types

- **Absolute path**: starts from root `/`.
  - Example: `/home/user/Documents`.
- **Relative path**: relative to current directory.
  - Example: `../Downloads`, `./script.sh`.

Special entries:
- `.` – current directory.
- `..` – parent directory.
- `~` – current user’s home directory.

### 4.2 Linux Directory Structure (FHS)

Common top-level directories:

- `/` – root of filesystem.
- `/home` – users’ home directories.
- `/root` – root (admin) user’s home.
- `/bin` – essential user binaries.
- `/sbin` – system binaries.
- `/usr` – user programs and data.
- `/var` – variable data (logs, spool, cache).
- `/etc` – configuration files.
- `/tmp` – temporary files.
- `/dev` – device files.
- `/proc`, `/sys` – virtual filesystems for kernel & processes.

Check where you are and what’s there:
```bash
$ pwd
$ ls /
$ ls /home
```

---

## 5. Working With Files and Directories

### 5.1 Creating and Removing Directories

```bash
$ mkdir mydir              # create directory
$ mkdir -p a/b/c           # create nested directories
$ rmdir emptydir           # remove empty directory
$ rm -r dir_to_remove      # remove directory recursively
$ rm -rf dir_to_force      # force recursive delete (DANGEROUS)
```

### 5.2 Creating, Copying, Moving, Deleting Files

```bash
$ touch file.txt           # create empty file or update timestamp
$ cp file1 file2           # copy file1 to file2
$ cp file1 file2 dir/      # copy into directory
$ cp -r dir1 dir2          # copy directory recursively

$ mv old new               # rename file or move path
$ mv file1 dir/            # move to directory

$ rm file.txt              # remove file
$ rm -f file.txt           # force remove (no prompt)
```

### 5.3 Viewing Files

```bash
$ cat file.txt             # show whole file
$ less file.txt            # view (scroll with arrows, q to quit)
$ head file.txt            # first 10 lines
$ head -n 20 file.txt      # first 20 lines
$ tail file.txt            # last 10 lines
$ tail -f logfile          # follow (stream) file as it grows
```

---

## 6. Text Editing (nano, vim)

### 6.1 nano (Beginner-Friendly Editor)

```bash
$ nano file.txt
```

Basics:
- Type to edit text.
- `Ctrl + O` – write (save) file.
- `Ctrl + X` – exit.
- `Ctrl + W` – search.

### 6.2 vim (Powerful, Steep Learning Curve)

```bash
$ vim file.txt
```

Modes:
- **Normal mode** – navigation & commands.
- **Insert mode** – typing text (`i`, `a`, `o` to enter).

Basics:
- `i` – enter insert mode before cursor.
- `Esc` – back to normal mode.
- `:w` – save.
- `:q` – quit.
- `:wq` – save & quit.
- `:q!` – quit without saving.

---

## 7. Permissions, Ownership, and Execution

Every file has:
- **Owner** user.
- **Group**.
- **Permission bits** for: user (u), group (g), others (o).

View permissions:
```bash
$ ls -l
-rwxr-xr-- 1 user group  1234 Feb  1 12:00 script.sh
```

Breakdown of `-rwxr-xr--`:
- `-` – file type (`d` for directory, `-` for regular file).
- `rwx` – owner can read, write, execute.
- `r-x` – group can read, execute.
- `r--` – others can read.

### 7.1 Changing Permissions (chmod)

Symbolic mode:
```bash
$ chmod u+x script.sh      # add execute for user
$ chmod go-r file.txt      # remove read for group & others
$ chmod a+r file.txt       # all (u,g,o) read
```

Numeric mode:
- `r = 4`, `w = 2`, `x = 1`.
- Add values per group.

```bash
$ chmod 755 script.sh      # rwx r-x r-x
$ chmod 644 file.txt       # rw- r-- r--
```

### 7.2 Changing Ownership (chown)

```bash
$ sudo chown newuser file.txt
$ sudo chown newuser:newgroup file.txt
```

(DANGEROUS – usually only root uses `chown`.)

---

## 8. Users and Groups

### 8.1 Viewing Users & Identity

```bash
$ whoami              # current user
$ id                  # user and group IDs
$ groups              # groups current user belongs to
$ who                 # logged-in users
$ w                   # more detailed user info and load
```

### 8.2 Switching Users (su, sudo)

```bash
$ su -                # switch to root (if you know root password)
$ su - otheruser      # switch to other user

$ sudo command        # run a single command as root
$ sudo -i             # root shell if allowed
```

`sudo` uses `/etc/sudoers` and group `sudo` or `wheel` (distro dependent).

---

## 9. Processes and Jobs

### 9.1 Viewing Processes

```bash
$ ps                  # processes in current shell
$ ps aux              # all processes
$ top                 # live process view
$ htop                # nicer top (may need install)
```

In `top` / `htop`:
- `q` – quit.
- Sort by CPU, memory, etc.

### 9.2 Killing Processes

```bash
$ kill PID            # send TERM signal (polite ask to stop)
$ kill -9 PID         # send KILL signal (force stop)
$ pkill name          # kill processes by name
$ killall name        # kill all processes with this name
```

Get PID first:
```bash
$ ps aux | grep program
```

### 9.3 Background and Foreground Jobs

```bash
$ long_command &      # run in background
$ jobs                # list jobs
$ fg %1               # bring job 1 to foreground
$ bg %1               # send job 1 to background
```

Stop a foreground job with `Ctrl + Z` (suspend), then:
- `bg` to run it in background.
- `fg` to bring it back.

---

## 10. Package Management

Depends on distro:

- **Debian/Ubuntu**: `apt`, `apt-get`.
- **Fedora/RHEL/CentOS**: `dnf` (or older `yum`).
- **Arch**: `pacman`.

### 10.1 Debian/Ubuntu (apt)

```bash
$ sudo apt update                     # update package index
$ sudo apt upgrade                    # upgrade installed packages
$ sudo apt install package-name       # install package
$ sudo apt remove package-name        # remove package
$ sudo apt purge package-name         # remove including config
$ apt search keyword                  # search packages
$ apt show package-name               # package info
```

### 10.2 Fedora/RHEL (dnf)

```bash
$ sudo dnf update
$ sudo dnf install package-name
$ sudo dnf remove package-name
```

### 10.3 Arch (pacman)

```bash
$ sudo pacman -Syu                    # sync, refresh, upgrade
$ sudo pacman -S package-name         # install
$ sudo pacman -R package-name         # remove
```

---

## 11. Redirection and Pipes

### 11.1 Standard Streams

- `stdin` – standard input (0).
- `stdout` – standard output (1).
- `stderr` – standard error (2).

### 11.2 Redirection

```bash
$ command > file           # stdout to file (overwrite)
$ command >> file          # stdout to file (append)
$ command 2> errors.log    # stderr to file
$ command > out 2>&1       # stdout and stderr to same file
$ command < input.txt      # read stdin from file
```

### 11.3 Pipes

```bash
$ command1 | command2      # output of 1 becomes input of 2

$ ls -l | less             # view long listing with pager
$ ps aux | grep ssh        # filter processes containing 'ssh'
$ dmesg | tail             # show last kernel messages
```

---

## 12. Searching and Text Processing (grep, find, sed, awk)

### 12.1 grep – Search Text

```bash
$ grep pattern file.txt
$ grep -i pattern file.txt         # case-insensitive
$ grep -r pattern dir/             # recursive
$ grep -n pattern file.txt         # show line numbers
$ grep -E "regex" file.txt        # extended regex
```

Regex examples:
- `^pattern` – start of line.
- `pattern$` – end of line.
- `^$` – empty line.
- `[0-9]+` – one or more digits.

### 12.2 find – Search Files

```bash
$ find /path -name "*.log"            # by name
$ find . -type f -size +10M           # files > 10MB
$ find . -mtime -1                    # modified in last 1 day
$ find . -type f -exec ls -lh {} \;   # run command per file
```

### 12.3 sed – Stream Editor

```bash
$ sed 's/old/new/' file.txt          # replace first occurrence per line
$ sed 's/old/new/g' file.txt         # replace all occurrences per line
$ sed -n '5,10p' file.txt            # print lines 5–10
```

### 12.4 awk – Field-Based Processing

```bash
$ awk '{print $1}' file.txt          # print first column
$ awk -F: '{print $1, $3}' /etc/passwd
$ df -h | awk 'NR==1 || $5+0 > 80'   # mountpoints >80% usage
```

---

## 13. Archives and Compression

### 13.1 tar

```bash
# create archive
$ tar -cvf archive.tar dir/

# extract archive
$ tar -xvf archive.tar

# create compressed (gzip) tar
$ tar -czvf archive.tar.gz dir/

# extract compressed tar
$ tar -xzvf archive.tar.gz
```

Options:
- `c` – create.
- `x` – extract.
- `v` – verbose.
- `f` – specify file.
- `z` – gzip compression.

### 13.2 zip / unzip

```bash
$ zip file.zip file1 file2
$ unzip file.zip
```

---

## 14. Disk Usage and Filesystems

### 14.1 Checking Disk Space

```bash
$ df -h                  # disk space for filesystems
$ du -sh *               # size of directories/files in current dir
$ du -sh /var/log        # size of /var/log
```

### 14.2 Mounts and Devices (Overview)

```bash
$ lsblk                  # list block devices
$ mount                  # show mounted filesystems
$ sudo mount /dev/sdXN /mnt   # mount device (example)
$ sudo umount /mnt            # unmount
```

Editing `/etc/fstab` controls permanent mounts (advanced – be careful).

---

## 15. System Information and Logs

### 15.1 System Info

```bash
$ uname -a               # kernel and system info
$ hostname               # system hostname
$ lsb_release -a         # distro info (Debian/Ubuntu)
$ cat /etc/os-release    # generic OS info
$ uptime                 # how long system has been running
$ free -h                # memory usage
$ lscpu                  # CPU info
$ lsusb                  # USB devices
$ lspci                  # PCI devices
```

### 15.2 Logs (systemd-based systems)

```bash
$ journalctl                 # all logs
$ journalctl -b              # current boot
$ journalctl -u service      # logs for service
$ dmesg                      # kernel ring buffer
```

Manual log files:
```bash
$ ls /var/log
$ tail -f /var/log/syslog    # Debian/Ubuntu main log
$ tail -f /var/log/messages  # RHEL/Fedora main log
```

---

## 16. Services and systemd

Most modern distros use **systemd** to manage services and startup.

```bash
$ systemctl status            # overall systemd status
$ systemctl list-units --type=service
$ systemctl status ssh        # status of ssh service
$ sudo systemctl start ssh    # start service now
$ sudo systemctl stop ssh     # stop service
$ sudo systemctl restart ssh  # restart service
$ sudo systemctl enable ssh   # start on boot
$ sudo systemctl disable ssh  # disable on boot
```

---

## 17. Networking Basics

### 17.1 Checking Network Configuration

```bash
$ ip a                    # IP addresses
$ ip r                    # routing table
$ hostname -I             # IP addresses of host
$ ping 8.8.8.8            # test connectivity
$ ping google.com         # test DNS + connectivity
$ traceroute host         # path to host (may need install)
$ nslookup domain         # DNS lookup
```

### 17.2 Common Network Tools

```bash
$ curl https://example.com      # fetch URL
$ wget https://example.com      # download file
$ netstat -tulnp                # listening ports (may use ss instead)
$ ss -tulnp                     # sockets summary
```

Ports and protocols:
- `22` – SSH.
- `80` – HTTP.
- `443` – HTTPS.

---

## 18. SSH and Remote Administration

### 18.1 Connecting to Remote Server

```bash
$ ssh user@host                # default port 22
$ ssh -p 2222 user@host        # custom port
```

### 18.2 Managing Keys

Generate key pair:
```bash
$ ssh-keygen -t ed25519 -C "your_email@example.com"
```

Copy key to server:
```bash
$ ssh-copy-id user@host
```

Then you can connect without password (if configured).

### 18.3 Secure File Copy

```bash
$ scp file.txt user@host:/path/
$ scp -r dir/ user@host:/path/
$ scp user@host:/path/file.txt .
```

For more advanced transfers, use `rsync` (next section).

---

## 19. rsync – Efficient File Synchronization

```bash
$ rsync -av source/ dest/                # local sync
$ rsync -av file user@host:/path/       # to remote
$ rsync -av user@host:/path/ dest/      # from remote
$ rsync -av --delete src/ dest/         # delete files not in src (careful)
```

Common options:
- `-a` – archive mode (preserve permissions, etc.).
- `-v` – verbose.
- `-z` – compress.
- `--progress` – show progress.

---

## 20. Environment Variables and Shell Configuration

### 20.1 Viewing and Setting Variables

```bash
$ echo $HOME
$ echo $PATH
$ export MYVAR="hello"       # set variable for current shell
$ echo $MYVAR
```

### 20.2 PATH

`PATH` is a colon-separated list of directories searched for commands.

```bash
$ echo $PATH
$ export PATH="$HOME/bin:$PATH"   # add ~/bin at beginning
```

To make permanent, add exports to:
- `~/.bashrc` (interactive shells).
- `~/.profile` or `~/.bash_profile` (login shells, depends on distro).

Example in `~/.bashrc`:
```bash
export PATH="$HOME/bin:$PATH"
export EDITOR=nano
```

Reload:
```bash
$ source ~/.bashrc
```

---

## 21. Bash Scripting (From Basic to Advanced)

### 21.1 First Script

Create `hello.sh`:
```bash
#!/usr/bin/env bash

echo "Hello, world!"
```

Make executable and run:
```bash
$ chmod +x hello.sh
$ ./hello.sh
```

### 21.2 Variables

```bash
#!/usr/bin/env bash

name="Alice"
echo "Hello, $name"
```

Rules:
- No spaces around `=` when assigning.
- Use `$var` to read.

### 21.3 Input (read)

```bash
read -p "Enter your name: " name
echo "Hi, $name"
```

### 21.4 Positional Parameters

```bash
#!/usr/bin/env bash

echo "Script name: $0"
echo "First arg: $1"
echo "Second arg: $2"
echo "All args: $@"
```

Run:
```bash
$ ./script.sh one two
```

### 21.5 Conditionals

```bash
if [ condition ]; then
  commands
elif [ other_condition ]; then
  commands
else
  commands
fi
```

Examples:
```bash
if [ "$1" = "start" ]; then
  echo "Starting"
elif [ "$1" = "stop" ]; then
  echo "Stopping"
else
  echo "Usage: $0 start|stop"
fi
```

Numeric comparisons:
- `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge`.

String tests:
- `=`, `!=`, `-z` (empty), `-n` (non-empty).

File tests:
- `-f file` – regular file exists.
- `-d dir` – directory exists.
- `-e path` – exists.
- `-x file` – executable.

```bash
if [ -d "/etc" ]; then
  echo "/etc exists"
fi
```

### 21.6 Loops

For loop (list):
```bash
for x in 1 2 3; do
  echo $x
done
```

For loop (over files):
```bash
for f in *.txt; do
  echo "File: $f"
done
```

While loop:
```bash
count=1
while [ $count -le 5 ]; do
  echo $count
  count=$((count+1))
done
```

### 21.7 Functions

```bash
myfunc() {
  echo "Hello from function"
}

myfunc
```

With parameters:
```bash
greet() {
  echo "Hello, $1"
}

greet "Alice"
```

### 21.8 Error Handling and Exit Codes

- Every command has an **exit status**: `0` = success, non-zero = failure.

```bash
$ echo $?
```

In scripts:
```bash
command
if [ $? -ne 0 ]; then
  echo "command failed" >&2
  exit 1
fi
```

Better pattern (set -e):
```bash
set -euo pipefail
```

- `-e` – exit on error.
- `-u` – error on use of undefined variable.
- `-o pipefail` – fail if any command in a pipe fails.

---

## 22. Scheduling Tasks (cron, at)

### 22.1 cron

Crontab syntax (per-user scheduled tasks):

```bash
$ crontab -e            # edit crontab
$ crontab -l            # list crontab
```

Crontab line format:
```text
MIN HOUR DOM MON DOW  command
```

Examples:
- Every day at 02:30:
  ```text
  30 2 * * * /path/to/backup.sh
  ```
- Every 5 minutes:
  ```text
  */5 * * * * /path/to/script.sh
  ```

Fields:
- `MIN` – 0–59.
- `HOUR` – 0–23.
- `DOM` – day of month 1–31.
- `MON` – month 1–12.
- `DOW` – day of week 0–7 (0/7 = Sunday).

### 22.2 at (Run Once in Future)

```bash
$ at 14:30
at> echo "Hello" >> /tmp/hello.txt
at> <Ctrl+D>
```

List jobs:
```bash
$ atq
```

---

## 23. System Security Basics

### 23.1 Principle of Least Privilege

- Use normal user for daily work.
- Use `sudo` only when needed.
- Do **not** run as `root` all the time.

### 23.2 File Permissions and Sensitive Files

- `/etc/passwd` – user account info.
- `/etc/shadow` – password hashes (root-only).

Check permissions:
```bash
$ ls -l /etc/passwd /etc/shadow
```

### 23.3 Firewall (ufw / firewalld Overview)

On Ubuntu (ufw):
```bash
$ sudo ufw status
$ sudo ufw enable
$ sudo ufw allow 22/tcp
$ sudo ufw deny 23/tcp
```

On RHEL/Fedora (firewalld):
```bash
$ sudo firewall-cmd --state
$ sudo firewall-cmd --add-service=ssh --permanent
$ sudo firewall-cmd --reload
```

---

## 24. Performance Monitoring and Troubleshooting

### 24.1 Key Commands

```bash
$ top                # CPU/memory usage
$ htop               # nicer top
$ vmstat 1           # system performance summary
$ iostat 1           # disk I/O (requires sysstat)
$ free -h            # memory usage
$ df -h              # disk usage
$ sar                # historical statistics (sysstat)
```

### 24.2 Typical Troubleshooting Flow

1. Check system load: `uptime`, `top`.
2. Check memory: `free -h`.
3. Check disk space: `df -h`.
4. Check I/O: `iostat`, `vmstat`.
5. Check logs: `journalctl`, `/var/log/*`.

---

## 25. Device Management (Overview)

- Devices appear under `/dev`.
- `lsblk` – list block (disk) devices.
- `udevadm` – manage device events.

```bash
$ ls /dev
$ lsblk
```

Mounting USB drive (example – may differ by system):
```bash
$ lsblk                          # find device, e.g., /dev/sdb1
$ sudo mkdir -p /mnt/usb
$ sudo mount /dev/sdb1 /mnt/usb
$ ls /mnt/usb
$ sudo umount /mnt/usb
```

---

## 26. Containers (Very High-Level Overview)

Linux skills are essential for Docker & containers.

Basic Docker commands (if Docker installed):
```bash
$ docker ps                      # running containers
$ docker images                  # images
$ docker run -it ubuntu bash     # run container
$ docker exec -it <id> bash      # shell into running container
```

---

## 27. Becoming a Linux Pro – Learning Path

1. **Daily usage**
   - Use Linux as your main dev environment.
   - Replace GUI actions with commands when possible.
2. **Practice challenges**
   - Try to achieve tasks only via terminal.
   - E.g. "search all .log files >10MB modified last week".
3. **Scripting automation**
   - Automate backups, log rotations, and small admin tasks.
4. **System administration**
   - Manage users/groups.
   - Configure services with `systemd`.
   - Manage packages and updates responsibly.
5. **Deep dive topics** (later):
   - SELinux / AppArmor.
   - LVM, RAID, advanced storage.
   - Network services (nginx, Apache, DNS, etc.).

---

## 28. Practice Ideas

Try to do these without looking at the solution, then verify.

1. **Navigation & files**
   - Create a directory `projects/linux101`.
   - Create 3 files: `a.txt`, `b.txt`, `c.txt`.
   - Append some text to each file.
   - List them with size and timestamps.

2. **Permissions**
   - Make a script `runme.sh` that prints `Hello`.
   - Make it executable.
   - Change its permissions so only you can execute it.

3. **Search & text processing**
   - Find all `.log` files under `/var/log` containing the word `error`.
   - Count how many lines have the word `failed` in `auth.log` (or similar file).

4. **Scripting**
   - Write a script that:
     - Accepts a directory as argument.
     - Lists top 5 largest files in that directory.

5. **Cron**
   - Schedule a job that appends the current date to `~/dates.log` every day at 12:00.

---

## 29. Useful Built-In Help

- `man command` – manual pages (quit with `q`).
- `command --help` – brief usage.

Examples:
```bash
$ man ls
$ ls --help
$ man bash
```

Reading `man` pages is a key skill – almost every command is documented there.

---

## 30. Next Steps For You

- Set up **WSL with Ubuntu** on your Windows machine.
- Go through sections **3–7** slowly and practice each command.
- Then move to **11–13**, **17–19**, and **21** for scripting.
- Revisit these notes often; update this file with your own examples and commands you discover.
