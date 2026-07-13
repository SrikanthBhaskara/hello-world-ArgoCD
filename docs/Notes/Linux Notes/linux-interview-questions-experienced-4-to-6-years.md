# Linux Interview Questions: Experienced (4 to 6 Years)

## Focus Areas

- production troubleshooting
- security and hardening
- performance tuning
- automation
- containers and Kubernetes fundamentals
- incident response
- architecture and operational maturity

## Production Operations

### 1. How do you approach a production Linux incident systematically?
Short answer:
Identify blast radius, gather facts first, avoid risky changes, and investigate logs, metrics, processes, network, and storage in a structured way.

Better answer:
My first goal is stability, not speed for its own sake. I confirm user impact, scope, and recent changes, then inspect system health data before taking corrective action. I also communicate clearly so the team knows what is being tested and what is still uncertain.

### 2. How do you differentiate app issue vs OS issue vs infrastructure issue?
Short answer:
I separate the problem by layer: application behavior, host behavior, and upstream platform or network behavior.

Better answer:
I start with symptoms and narrow the failing layer. If the process is healthy locally but traffic fails, the issue may be infrastructure or routing. If the process itself is crashing or leaking memory, the issue is more likely inside the app or its runtime.

### 3. What Linux signals and process states matter in real troubleshooting?
Short answer:
Signals like `SIGTERM`, `SIGKILL`, and states such as running, sleeping, zombie, or uninterruptible sleep are important.

Better answer:
Interviewers want to know that you understand process lifecycle. For example, uninterruptible sleep often points to I/O problems, while repeated `SIGKILL` or OOM events may indicate resource pressure rather than a normal app shutdown.

## Performance and Capacity

### 4. How do you investigate high load average?
Short answer:
Check CPU saturation, runnable tasks, I/O wait, and process backlog.

Better answer:
High load does not always mean CPU is maxed out. It can also reflect blocked tasks or storage pressure. I correlate load with CPU usage, run queue, and wait behavior before drawing conclusions.

### 5. How do you investigate memory pressure?
Short answer:
Look at available memory, page cache, swap activity, and OOM events.

Better answer:
I distinguish between healthy cache use and real pressure. The important questions are whether the system is swapping heavily, whether the OOM killer has acted, and whether a specific process is consuming memory abnormally.

### 6. How do you investigate disk I/O bottlenecks?
Short answer:
Use tools such as `iostat`, `iotop`, `vmstat`, and kernel logs.

Better answer:
I try to confirm whether the issue is throughput, latency, queueing, or device errors. Slow disk symptoms often appear as application slowness or stuck processes rather than obvious storage alerts.

### 7. What kinds of kernel or sysctl tuning should be done carefully and why?
Short answer:
Anything affecting memory, networking, file descriptors, or process limits should be changed carefully because the blast radius can be large.

Better answer:
Kernel tuning can improve performance, but careless changes may destabilize the host or hide deeper design issues. I prefer measured changes with rollback clarity and before-and-after validation.

## Security

### 8. How would you harden a Linux host for production?
Short answer:
Minimize exposed services, secure SSH, patch regularly, manage users carefully, restrict privileges, and monitor logs.

Better answer:
I think of hardening in layers: access control, package hygiene, least privilege, network exposure, auditing, and patch management. Good hardening reduces attack surface without making operations impossible.

### 9. What is SELinux and why do teams struggle with it?
Short answer:
SELinux is a mandatory access control system that can block actions even when standard Unix permissions allow them.

Better answer:
Teams often struggle because SELinux issues look like random permission problems unless you know where to inspect contexts, policies, and audit logs. The real skill is not disabling it immediately, but understanding what it is protecting.

### 10. How would you investigate suspected unauthorized access on a Linux server?
Short answer:
Preserve evidence, check auth logs, account changes, running processes, network connections, and recent filesystem changes.

Better answer:
I avoid making uncontrolled changes first. I collect logs and indicators, review login history, privilege escalation events, cron or startup persistence, suspicious binaries, and outbound connections. Evidence handling matters as much as the technical checks.

### 11. What logs and artifacts would you collect first in a security incident?
Short answer:
Authentication logs, `journalctl`, process lists, network connections, recent file changes, cron entries, and privilege or account changes.

Better answer:
I focus first on volatile evidence and timeline building. That often includes active processes, sockets, recent commands, service changes, package changes, and any indicators of persistence.

## Automation and Platform Thinking

### 12. When should a team use shell scripting vs Ansible vs Terraform?
Short answer:
Use shell for small host-level automation, Ansible for configuration management, and Terraform for infrastructure provisioning.

Better answer:
I choose based on scope and desired state. Shell is flexible but easier to make unsafe, Ansible is strong for repeatable host configuration, and Terraform is best when managing infrastructure resources declaratively.

### 13. What makes an operational script safe in production?
Short answer:
Validation, logging, idempotence where possible, controlled failure handling, and rollback awareness.

Better answer:
A production script should make risky actions explicit, validate targets before acting, and fail in a way operators can understand. Safety matters more than cleverness.

### 14. How do you review a shell script for safety?
Short answer:
Check variable quoting, path assumptions, error handling, privileges, destructive commands, and logging.

Better answer:
I also review whether the script depends on implicit environment state, whether it can operate on the wrong target, and whether rerunning it could create damage or drift.

## Containers and Kubernetes-Adjacent Linux

### 15. Why do strong Linux fundamentals matter for Kubernetes troubleshooting?
Short answer:
Because Kubernetes problems often reduce to Linux process, filesystem, networking, or permission behavior underneath.

Better answer:
Kubernetes abstracts infrastructure, but containers still depend on Linux primitives such as namespaces, cgroups, mounts, DNS, sockets, and file permissions. Strong Linux understanding makes cluster debugging faster and more accurate.

### 16. What Linux areas commonly affect container behavior?
Short answer:
Cgroups, namespaces, filesystem permissions, networking, DNS, and mounts.

Better answer:
When a container behaves differently across environments, the root cause is often in one of those areas rather than in the application code itself.

### 17. How would you troubleshoot a container that works locally but fails in a cluster?
Short answer:
Compare runtime config, image tag, env vars, secrets, filesystem permissions, networking, probes, and resource limits.

Better answer:
Local success only proves the image can run in one context. Cluster failure may come from missing config, different security context, bad secret injection, insufficient resources, or service or ingress wiring.

## Advanced Scenarios

### 18. A server is reachable by IP but not by hostname. What do you check?
Short answer:
Check DNS resolution, resolver config, search domains, `/etc/hosts`, and network path to DNS servers.

Better answer:
That symptom usually narrows the issue to name resolution rather than raw connectivity. I compare the hostname lookup path on a working system and the failing one.

### 19. A pod reports disk permission issues on a mounted volume. What Linux concepts help explain it?
Short answer:
Unix ownership, file modes, UID/GID mapping, mount permissions, and security context behavior.

Better answer:
In Kubernetes, many volume-permission issues are still classic Linux ownership problems. I check the container user, mounted path ownership, `fsGroup`, read-only flags, and whether the storage backend preserves expected permissions.

### 20. A system reboots after a bad config change. How do you recover and prevent recurrence?
Short answer:
Boot into recovery if needed, revert the bad change, validate the fix, and add safer change control.

Better answer:
After recovery, I focus on why the change bypassed validation. Good prevention includes config testing, staged rollout, backups, and peer review for high-risk host changes.

### 21. A node shows packet loss under load. How do you investigate?
Short answer:
Check interface errors, saturation, queue drops, CPU pressure, routing path, and related application traffic patterns.

Better answer:
Packet loss under load may be network, kernel, driver, or host-resource related. I correlate traffic spikes with interface counters, system load, and application behavior to isolate the pressure point.

### 22. A service is healthy locally but broken behind a reverse proxy. What layers do you check?
Short answer:
Check the app listener, proxy config, upstream routing, headers, TLS, timeouts, and health-check expectations.

Better answer:
I debug from the backend outward. If the app works on localhost, the issue is often bind address, upstream target, host header handling, TLS termination, or proxy timeout behavior rather than the process itself.

## What to Revise Before Interview

- incident handling
- performance troubleshooting
- SELinux and security basics
- shell safety
- Linux and containers relationship
- monitoring and log investigation
