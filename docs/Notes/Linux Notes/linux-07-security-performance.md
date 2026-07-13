# Linux 07 – Security, Performance & Troubleshooting

## 0. Goal of This Note

- Learn core security practices for Linux.  
- Understand basic performance monitoring.  
- Follow a structured troubleshooting approach.

---

## 1. Security Fundamentals

### 1.1 Principle of Least Privilege

- Use **normal user** for daily work.  
- Use `sudo` only when needed.  
- Avoid logging in as `root` directly, especially over SSH.

### 1.2 Updates & Patching

Keep system updated:

Debian/Ubuntu:

```bash
sudo apt update
sudo apt upgrade
```

RHEL/Fedora:

```bash
sudo dnf update
```

### 1.3 SSH Hardening (Server Side)

Edit `/etc/ssh/sshd_config` (with sudo):

Key recommendations (on servers you control):

- Disable root login:
  ```text
  PermitRootLogin no
  ```
- Prefer key-based auth:
  ```text
  PasswordAuthentication no   # only if keys are set up
  ```
- Change default port (optional, minor protection):
  ```text
  Port 2222
  ```

Apply changes:

```bash
sudo systemctl restart sshd   # or ssh on some distros
```

### 1.4 Firewall Basics

On Ubuntu (ufw):

```bash
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw enable
```

On RHEL/Fedora (firewalld):

```bash
sudo firewall-cmd --state
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload
```

### 1.5 File & Log Security

- Use correct permissions on sensitive files (e.g., `chmod 600` for private keys).  
- Monitor `/var/log/auth.log` or `/var/log/secure` for suspicious logins.

---

## 2. Performance Monitoring

### 2.1 High-Level View

```bash
uptime         # load averages
free -h        # memory
```

Load average: 3 numbers for 1, 5, 15 minutes. Roughly how many processes are waiting for CPU.

### 2.2 CPU & Memory – top / htop

```bash
top
```

Look at:

- CPU usage per process.  
- Memory usage (RES, %MEM).

`htop` (if installed) gives nicer interface, color, and filtering.

### 2.3 Disk Usage & I/O

```bash
df -h          # filesystem usage
``` 

If `iostat` is available (from `sysstat` package):

```bash
iostat -xz 1
```

- `%util` near 100% → disk may be a bottleneck.

`vmstat` shows CPU, memory, and I/O:

```bash
vmstat 1
```

### 2.4 Network

- `ss -tulnp` – listening sockets.  
- `iftop` / `nethogs` (if installed) – per-connection bandwidth.

---

## 3. Structured Troubleshooting

### 3.1 General Approach

1. **Define the problem clearly** (what changed? when did it start?).  
2. **Check basics** (power, cables, network, disk space).  
3. **Look for errors in logs**.  
4. **Reproduce and isolate** (small tests, one component at a time).  
5. **Make one change at a time** and re-test.

### 3.2 Common Scenarios

#### A. System Feels Slow

1. Check load & uptime:
   ```bash
   uptime
   ```
2. Check CPU & memory:
   ```bash
   top
   free -h
   ```
3. Check disk space:
   ```bash
   df -h
   ```
4. Look for misbehaving processes using lots of CPU or memory; consider restarting or reconfiguring them.

#### B. Service Not Starting

1. Check service status:
   ```bash
   systemctl status servicename
   ```
2. Check logs:
   ```bash
   journalctl -u servicename -b
   ```
3. Validate config files (for nginx, apache, etc. use their `-t` or `configtest` options).

#### C. Can’t Connect Over Network

Follow this order:

1. `ip a` – do you have an IP?  
2. `ip r` – is there a default route?  
3. `ping gateway` – is local network OK?  
4. `ping 8.8.8.8` – internet reachability.  
5. `ping example.com` – DNS resolution.  
6. `ss -tulnp` – is the server listening on expected port?  
7. Firewall – `ufw` / `firewalld` / security groups.

---

## 4. Logs – Your Best Friend

Systemd journal:

```bash
journalctl                # all logs
journalctl -b             # current boot
journalctl -xe            # last errors with context
journalctl -u ssh         # service specific
```

Traditional log files (varies by distro):

```bash
ls /var/log
sudo tail -f /var/log/syslog      # Debian/Ubuntu
sudo tail -f /var/log/messages    # RHEL/CentOS
sudo tail -f /var/log/auth.log    # auth events
```

Use `grep`, `less`, and `awk` to search within logs.

---

## 5. Basic Hardening Checklist (For Personal Servers)

1. Change default passwords; use strong ones or keys.  
2. Keep system updated.  
3. Restrict SSH (keys only, no root login).  
4. Enable and configure firewall.  
5. Limit services: uninstall or disable what you don’t use.  
6. Use least-privilege for services (dedicated users/groups).  
7. Regularly check logs for unusual activity.

---

## 6. Practice Tasks

1. Security:
   - Check which services are listening on your machine and close/disable those not needed.  
   - If you have an SSH server, configure it to disallow root login.
2. Performance:
   - Run `stress` or a CPU-intensive command (if safe) and watch `top`.  
   - Fill a small test partition close to full and see how `df -h` and system behavior change.
3. Troubleshooting:
   - Break something on purpose on a test system (e.g., wrong path in a service config).  
   - Use `systemctl` and `journalctl` to find and fix the issue.

You now have core knowledge from **beginner to practical admin** level. Keep revisiting these notes and practicing on real systems to move toward true “pro” skills.
