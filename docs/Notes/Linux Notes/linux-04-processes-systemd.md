# Linux 04 – Processes, Jobs, Boot & systemd

## 0. Goal of This Note

- Understand how processes and jobs work.  
- Learn basic monitoring & killing commands.  
- Get an overview of boot, runlevels/targets, and `systemd` services.

---

## 1. Processes Basics

A **process** is a running instance of a program.

Key concepts:

- PID – process ID (unique number).  
- PPID – parent process ID.  
- Signals – messages sent to processes (e.g., TERM, KILL).

View your shell’s PID:

```bash
echo $$
```

### 1.1 Listing Processes

```bash
ps                    # processes in current shell
ps aux                # all processes (BSD style)
ps -ef                # all processes (SysV style)
```

Common filters:

```bash
ps aux | grep ssh
ps -ef | grep nginx
```

### 1.2 top / htop – Live View

```bash
top
```

Inside `top`:

- `P` – sort by CPU.  
- `M` – sort by memory.  
- `q` – quit.

`htop` (if installed) is nicer:

```bash
htop
```

---

## 2. Signals & Killing Processes

Send signals with `kill`:

```bash
kill PID           # default: SIGTERM (15)
kill -9 PID        # SIGKILL – force kill
kill -HUP PID      # hangup – reload config for some daemons
```

By name:

```bash
pkill process-name
killall process-name
```

Good practice:

1. Try `kill PID` (TERM) first.  
2. If it ignores that, try `kill -9 PID` (KILL) as last resort.

---

## 3. Jobs, Background & Foreground

Jobs are processes started from your current shell.

Start in background:

```bash
sleep 60 &
```

List jobs:

```bash
jobs
```

Suspend a foreground job with `Ctrl + Z`, then:

```bash
bg %1         # send job 1 to background
fg %1         # bring back to foreground
```

Useful pattern:

- Start a long-running command, realize you need your terminal → `Ctrl + Z`, then `bg` and continue working.

---

## 4. Boot Process (High-Level)

Typical flow on modern systems:

1. BIOS/UEFI firmware starts.  
2. Bootloader (GRUB, systemd-boot) loads kernel.  
3. Kernel initializes hardware and mounts root filesystem.  
4. `systemd` (PID 1) starts as first userspace process.  
5. `systemd` launches services, mounts, timers, etc., according to units and targets.

You don’t usually manage early boot manually; you mainly interact with `systemd`.

---

## 5. systemd Units & Targets

A **unit** is a resource that `systemd` manages:

- `.service` – daemons / services.  
- `.socket` – sockets that activate services.  
- `.timer` – cron-like timers.  
- `.mount` – mount points.  
- `.target` – grouping of units (like runlevels).

View running services:

```bash
systemctl list-units --type=service
```

Current default target (boot state):

```bash
systemctl get-default
```

Common targets:

- `graphical.target` – multi-user with GUI.  
- `multi-user.target` – multi-user, no GUI.

Change default target (admin):

```bash
sudo systemctl set-default multi-user.target
```

---

## 6. Managing Services with systemd

### 6.1 Core Commands

```bash
systemctl status              # overall
systemctl status ssh          # ssh service status

sudo systemctl start ssh      # start now
sudo systemctl stop ssh       # stop
sudo systemctl restart ssh    # restart

sudo systemctl enable ssh     # start at boot
sudo systemctl disable ssh    # don’t start at boot
```

Check if a service is enabled:

```bash
systemctl is-enabled ssh
```

### 6.2 Logs for a Service

Use `journalctl`:

```bash
journalctl -u ssh             # all logs
journalctl -u ssh -b          # logs from current boot
journalctl -u ssh -n 50       # last 50 lines
journalctl -u ssh -f          # follow in real time
```

---

## 7. systemd Unit Files (Overview)

Unit files live in:

- `/lib/systemd/system` or `/usr/lib/systemd/system` – packaged units.  
- `/etc/systemd/system` – local/admin overrides or custom units.

Example simple service unit:

```ini
[Unit]
Description=My simple service
After=network.target

[Service]
ExecStart=/usr/local/bin/my-service
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable my-service
sudo systemctl start my-service
```

---

## 8. Practice Tasks

1. Processes:
   - Use `ps aux | head` and identify at least 5 system services.  
   - Use `top` and find which processes use the most memory.
2. Jobs:
   - Run `sleep 300 &` and verify with `jobs`.  
   - Start `sleep 100`, press `Ctrl + Z`, then use `bg` and `fg`.
3. systemd:
   - Check status of `ssh` or another common service on your system.  
   - Restart it and watch logs with `journalctl -u servicename -f`.  
   - Find your default target with `systemctl get-default`.

Next: **Linux 05 – Networking & SSH**.
