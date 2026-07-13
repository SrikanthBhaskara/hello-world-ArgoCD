# Linux 00 – Overview & Getting Started

## 0. Goal of This Note

- Understand what Linux is and common terms.  
- Choose and set up a practical Linux environment (on your Windows PC).  
- Learn how to open a terminal and get basic help.

---

## 1. What Exactly Is Linux?

### 1.1 Linux Architecture Layers

Linux is a complete operating system built in layers:

```
┌─────────────────────────────────────────┐
│   User Applications & Tools             │
│   (Firefox, vim, gcc, etc.)             │
├─────────────────────────────────────────┤
│   Shell & User Space Utilities          │
│   (bash, GNU coreutils, systemd)        │
├─────────────────────────────────────────┤
│   System Libraries                      │
│   (glibc, libpthread, etc.)            │
├─────────────────────────────────────────┤
│   System Call Interface                 │
├─────────────────────────────────────────┤
│   Linux Kernel                          │
│   - Process Management                  │
│   - Memory Management (MMU)             │
│   - Filesystem (VFS)                    │
│   - Network Stack                       │
│   - Device Drivers                      │
├─────────────────────────────────────────┤
│   Hardware                              │
│   (CPU, RAM, Disk, Network, etc.)       │
└─────────────────────────────────────────┘
```

### 1.2 The Linux Kernel

**Kernel** = core program managing all hardware and providing services to userspace.

Key kernel subsystems:

- **Process Scheduler**: Decides which process runs when (CFS - Completely Fair Scheduler).  
- **Memory Manager**: Virtual memory, paging, swapping, caching.  
- **Virtual File System (VFS)**: Unified interface for all filesystem types.  
- **Network Stack**: TCP/IP implementation, routing, firewalling.  
- **Device Drivers**: Code to interact with hardware (block devices, character devices, network interfaces).  
- **IPC (Inter-Process Communication)**: Pipes, signals, shared memory, message queues.

Kernel versions:
- Format: `major.minor.patch` (e.g., `6.1.15`)
- Check yours: `uname -r`
- Mainline vs LTS (Long Term Support) kernels

### 1.3 GNU Userland

**GNU Project** provides the essential Unix-like tools:

- **Core utilities** (coreutils): ls, cp, mv, rm, cat, chmod, etc.
- **File utilities**: find, xargs, locate
- **Text utilities**: grep, sed, awk, sort, uniq
- **Shell utilities**: bash (Bourne Again Shell)
- **Build tools**: gcc (compiler), make, autotools
- **Text editors**: emacs, nano

Without GNU tools, the Linux kernel alone wouldn't be usable. That's why some call it "GNU/Linux."

### 1.4 Distribution (Distro) Deep Dive

A **distribution** = Linux kernel + GNU tools + package manager + init system + default configs + applications

#### Distribution Family Tree

```
Debian Family:
├── Debian (stable, testing, unstable)
│   ├── Ubuntu (LTS every 2 years)
│   │   ├── Kubuntu, Xubuntu, Lubuntu (different desktops)
│   │   ├── Linux Mint (beginner-friendly)
│   │   └── Pop!_OS (gaming/developer focused)
│   └── Kali Linux (penetration testing)

Red Hat Family:
├── RHEL (Red Hat Enterprise Linux)
│   ├── CentOS Stream
│   ├── AlmaLinux (community RHEL rebuild)
│   ├── Rocky Linux (community RHEL rebuild)
│   └── Oracle Linux
└── Fedora (cutting edge, upstream for RHEL)

Arch Family:
├── Arch Linux (rolling release, DIY)
│   ├── Manjaro (user-friendly Arch)
│   └── EndeavourOS

Independent:
├── Slackware (oldest surviving distro)
├── Gentoo (source-based, compile everything)
└── Void Linux (runit instead of systemd)
```

#### Detailed Comparison Table

| Distro | Package Manager | Init System | Release Model | Best For |
|--------|----------------|-------------|---------------|----------|
| **Ubuntu** | apt/dpkg | systemd | Fixed (6mo) + LTS | Beginners, desktops, servers |
| **Debian** | apt/dpkg | systemd | Stable (~2yr) | Servers, stability |
| **Fedora** | dnf/rpm | systemd | Fixed (6mo) | Latest features, developers |
| **RHEL/Alma/Rocky** | dnf/rpm | systemd | Fixed (10yr support) | Enterprise servers |
| **Arch** | pacman | systemd | Rolling | Advanced users, customization |
| **Gentoo** | portage | OpenRC/systemd | Rolling | Experts, optimization |
| **openSUSE** | zypper/rpm | systemd | Fixed + Rolling | Sysadmins, YaST tool |

### 1.5 Key Linux Philosophies

1. **Everything is a file**  
   - Regular files, directories, devices (`/dev/sda`), pipes, sockets, processes (`/proc/1234`)  
   - Unified interface: open, read, write, close

2. **Small, focused tools**  
   - Each program does one thing well  
   - Combine tools with pipes: `cat file | grep pattern | sort | uniq -c`

3. **Multi-user from the ground up**  
   - Every file has owner/group/permissions  
   - Users isolated by UID/GID  
   - Root (UID 0) has unlimited power

4. **Text configuration files**  
   - Human-readable configs in `/etc`  
   - No hidden binary registry  
   - Version control friendly

5. **Scriptable automation**  
   - Shell scripting built-in  
   - Cron for scheduling  
   - Everything controllable from CLI

---

## 2. Shells & Terminals

### 2.1 Understanding Shells

A **shell** is a command-line interpreter that:
- Takes your text commands  
- Parses and interprets them  
- Executes programs  
- Manages processes and I/O  
- Provides scripting capabilities

A **terminal emulator** is the GUI window displaying the shell (GNOME Terminal, Konsole, xterm, Windows Terminal).

### 2.2 Shell Comparison

| Shell | Path | Pros | Cons | Best For |
|-------|------|------|------|----------|
| **bash** | `/bin/bash` | Default everywhere, vast resources, POSIX-compatible | Older syntax, limited interactive features | Scripts, compatibility |
| **zsh** | `/usr/bin/zsh` | Powerful completion, themes, plugins (oh-my-zsh) | Slight learning curve | Interactive use, power users |
| **fish** | `/usr/bin/fish` | Amazing defaults, syntax highlighting, user-friendly | Not POSIX-compliant, scripts won't work in bash | Beginners, interactive |
| **dash** | `/bin/dash` | Very fast, lightweight | Minimal features, no arrays | System scripts, speed |
| **sh** | `/bin/sh` | POSIX standard | Usually symlink to bash/dash | Portable scripts |

### 2.3 Shell Features You Should Know

**Tab completion**:
```bash
# Type first few letters and hit Tab
cd /etc/sys<Tab>      # completes to /etc/systemd/
ls --col<Tab>         # completes to --color
```

**Command history**:
```bash
history               # show all history
history 20            # last 20 commands
!42                   # run command number 42
!!                    # repeat last command
!ssh                  # run last command starting with 'ssh'
```

**Environment variables**:
```bash
echo $HOME            # your home directory
echo $PATH            # where shell looks for commands
echo $USER            # your username
env                   # show all environment variables
```

**Aliases** (shortcuts):
```bash
alias ll='ls -lah'    # create alias
alias                 # list all aliases
unalias ll            # remove alias
```

Check your current shell:
```bash
echo $SHELL           # login shell
echo $0               # current shell
ps -p $$              # process info of current shell
```

Change your default shell:
```bash
chsh -s /usr/bin/zsh  # change to zsh (log out/in to apply)
```

---

## 3. Getting Linux on Your Windows Machine (Recommended Paths)

### 3.1 WSL (Windows Subsystem for Linux)

Best option for you because you’re already on Windows.

High-level steps:

1. Open PowerShell **as Administrator**.  
2. Run:
   ```powershell
   wsl --install -d Ubuntu
   ```
3. Reboot if asked, then Windows will finish installing Ubuntu.  
4. After reboot, open **Ubuntu** from Start menu.  
5. Choose a username and password when Ubuntu first starts.

Then, from PowerShell or Windows Terminal any time:

```powershell
wsl            # drop into your Linux shell
wsl -d Ubuntu  # specify distro if you have multiple
```

### 3.2 Virtual Machine (VM)

- Install **VirtualBox** or **VMware Workstation Player**.  
- Download an ISO (Ubuntu, Fedora, etc.).  
- Create a new VM and install Linux inside it.

Pros vs WSL:

- WSL: better integration with Windows, lower overhead, great for dev.  
- VM: closer to a “real” Linux machine (boot, GRUB, full hardware model).

### 3.3 Dual Boot / Bare Metal

- Install Linux side‑by‑side with Windows or replace Windows.  
- Best performance and realism, but more risky; only do this when you’re confident.

---

## 4. Basic Terminal Habits

Once in Linux (WSL, VM, or real machine), practice:

```bash
pwd        # where am I?
ls         # list files
ls -la     # include hidden files in long format
cd         # go to home directory
cd /       # go to filesystem root
cd ..      # go up one level
```

Essential keyboard shortcuts:

- `Ctrl + C` – cancel current command.  
- `Ctrl + L` – clear screen.  
- `Ctrl + D` – logout / end of input.  
- Up / Down arrows – browse command history.  
- `Tab` – auto-complete commands and paths.

---

## 5. Built-In Help

Use built-in documentation instead of web searches whenever possible:

```bash
man command      # full manual page
command --help  # quick help / options
```

Example:

```bash
man ls
ls --help
```

Navigation inside `man`:

- Up/Down or `j`/`k` – scroll.  
- `/` – search.  
- `n` – next match.  
- `q` – quit.

---

## 6. First Exercises

Do these on your Linux system (WSL/VM/real):

1. Find out:
   - Your current shell using `echo $SHELL`.  
   - Your home directory using `echo $HOME`.  
   - Your username using `whoami`.
   - Your user ID using `id`.
   - System information using `uname -a`.
2. Navigate:
   - Go to `/`, list contents, then go back to `~` (home).  
   - Inside `~`, create a directory `linux-learning` using `mkdir` and go into it.
3. Practice `man`:
   - Try `man ls`, `man cp`, `man bash`.
   - Practice searching inside `man` with `/pattern` and `n` for next match.
4. Check your distro:
   - Try `cat /etc/os-release` to see detailed distro info.
   - Try `lsb_release -a` (if available).

---

## 7. Understanding Processes and Memory (Preview)

Even as a beginner, knowing these basics helps:\n\n**Process**: Running instance of a program, has PID (Process ID).\n```bash\nps aux | head           # see first few processes\ntop                     # live view (q to quit)\necho $$                 # PID of your current shell\n```\n\n**Memory**:\n```bash\nfree -h                 # RAM usage\n```\n\nOutput explanation:\n- `total` – physical RAM installed  \n- `used` – RAM in use by programs  \n- `free` – completely unused  \n- `available` – RAM available for new apps (includes cache that can be freed)  \n- `buff/cache` – used for disk caching (speeds up system, can be reclaimed)\n\n---\n\n## 8. File System Basics (Quick Preview)\n\nLinux has **one unified tree** starting at `/` (root), unlike Windows with `C:`, `D:`.\n\nEverything is under `/`:\n```bash\nls /              # top-level directories\nls /home          # user home directories\nls /etc           # configuration files\nls /var/log       # log files\n```\n\nYour home directory:\n```bash\ncd ~              # or just: cd\npwd               # should show /home/username\nls -la            # list all files including hidden (starting with .)\n```\n\nHidden config files:\n```bash\nls -la ~/ | grep \"^\\.\"\n# You'll see .bashrc, .profile, .bash_history, etc.\n```\n\n---\n\n## 9. Package Management Preview\n\nInstalling software on Linux uses **package managers** (not downloading .exe files).\n\n**Ubuntu/Debian**:\n```bash\nsudo apt update                  # update package lists\nsudo apt install tree            # install 'tree' command\nsudo apt search editor           # search for packages\nsudo apt remove tree             # uninstall\n```\n\n**Fedora/RHEL**:\n```bash\nsudo dnf update\nsudo dnf install tree\n```\n\n**Arch**:\n```bash\nsudo pacman -Syu                 # update system\nsudo pacman -S tree              # install\n```\n\nTest after installing:\n```bash\ntree -L 2 ~                      # show home directory as tree\n```\n\n---\n\n## 10. Common Beginner Mistakes to Avoid\n\n1. **Running everything as root**  \n   - DON'T: `sudo su` and stay as root  \n   - DO: Use `sudo` only for commands that need it\n\n2. **Forgetting spaces in commands**  \n   - WRONG: `cd/etc`  \n   - RIGHT: `cd /etc`\n\n3. **Copy-pasting commands without understanding**  \n   - Always read what a command does, especially if it has `sudo` or `rm`\n\n4. **Using `rm -rf` carelessly**  \n   ```bash\n   sudo rm -rf /     # DESTROYS YOUR SYSTEM\n   sudo rm -rf /*    # ALSO DESTROYS EVERYTHING\n   ```\n   Modern systems have protections, but be careful.\n\n5. **Not using Tab completion**  \n   - Type first few letters, hit `Tab` to auto-complete  \n   - Saves time and prevents typos\n\n6. **Ignoring error messages**  \n   - Read what the system tells you  \n   - Copy error messages into search engines for help\n\n---\n\n## 11. Getting Help When Stuck\n\n### Built-in Help\n```bash\nman command         # full manual\ncommand --help      # quick help\ninfo command        # info pages (GNU documentation)\n```\n\n### Online Resources\n\n- **Arch Wiki**: https://wiki.archlinux.org (best Linux documentation, works for all distros)\n- **Ubuntu Help**: https://help.ubuntu.com  \n- **StackExchange**: https://unix.stackexchange.com  \n- **Reddit**: r/linux4noobs, r/linuxquestions\n\n### Search Tips\n\n- Include your distro name: \"ubuntu how to install nginx\"  \n- Include error messages in quotes: \"bash: command not found\"  \n- Check the date (old solutions may not work on new distros)\n\n---\n\n## 12. Setting Up Your Learning Environment\n\n### Recommended First Installs (Ubuntu/Debian)\n\n```bash\n# Update system first\nsudo apt update && sudo apt upgrade -y\n\n# Essential tools\nsudo apt install -y \\\n  vim \\\n  git \\\n  curl \\\n  wget \\\n  tree \\\n  htop \\\n  net-tools \\\n  build-essential\n```\n\n### Configure git (for version control learning)\n\n```bash\ngit config --global user.name \"Your Name\"\ngit config --global user.email \"your.email@example.com\"\ngit config --global core.editor nano    # or vim\n```\n\n### Create Practice Directory Structure\n\n```bash\nmkdir -p ~/linux-learning/{basics,scripts,projects,tmp}\ncd ~/linux-learning\ntree\n```\n\nIf these feel comfortable, proceed to **Linux 01 – Shell Basics**.
