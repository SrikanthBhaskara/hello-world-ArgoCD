# Linux Troubleshooting Scenarios With Ideal Answers

## 1. Service Is Down but the Server Is Reachable

### Scenario

The host is reachable through SSH, but the application is down.

### Ideal Answer

I would first check whether the service process is running, then inspect `systemctl status`, logs, startup command, and dependency failures. A reachable server does not mean the service itself is healthy.

## 2. System Is Slow but CPU Looks Fine

### Scenario

Users report slowness, but CPU usage is low.

### Ideal Answer

I would check memory pressure, swap usage, disk I/O wait, load average, and network latency. Low CPU does not rule out bottlenecks; the issue may be disk, memory reclaim, or waiting on dependencies.

## 3. Disk Space Suddenly Fills Up

### Scenario

A system runs out of disk space unexpectedly.

### Ideal Answer

I would identify which filesystem is full, then inspect large directories, log growth, temporary files, and whether deleted-but-still-open files are consuming space. After stabilizing space, I would look for the reason the growth was not controlled earlier.

## 4. Application Works for Root but Fails for the Service User

### Scenario

Manual execution as root works, but the managed service fails.

### Ideal Answer

That usually points to permissions, environment, or path differences. I would compare user identity, file access, working directory, environment variables, and whether the service user can read config, write needed paths, or execute required binaries.

## 5. SSH Login Suddenly Stops Working

### Scenario

Remote access fails, and admins cannot log in normally.

### Ideal Answer

I would check whether the host is reachable at network level first, then inspect the SSH service state, firewall path, key permissions, authentication settings, and recent config changes. SSH issues often come from service state, config mistakes, or access-path controls rather than only credential errors.

## 6. DNS Lookup Fails but IP Connectivity Works

### Scenario

The system can reach an IP directly, but hostnames fail.

### Ideal Answer

That usually isolates the problem to name resolution. I would check resolver configuration, DNS server reachability, `resolv.conf` or resolver service behavior, and whether the issue affects only one process or the whole host.

## 7. Process Keeps Restarting

### Scenario

A service is constantly restarting under `systemd`.

### Ideal Answer

I would inspect `systemctl status`, journal logs, exit codes, startup dependencies, and whether the process is crashing immediately or being killed by an external condition. Restart loops often point to config, secret, path, or dependency problems.

## 8. Host Is Reachable but One Port Is Not

### Scenario

The machine responds to ping or SSH, but the application port is unreachable.

### Ideal Answer

I would check whether the process is listening on the expected port, whether it is bound to the right interface, and whether firewall or reverse proxy rules block the path. Then I would move outward to network and load-balancer layers if needed.

## 9. A Cron Job Does Not Run as Expected

### Scenario

A scheduled task appears not to execute.

### Ideal Answer

I would verify the schedule syntax, the correct user context, script permissions, environment assumptions, and output or logging behavior. Cron failures are often caused by path or environment differences compared to interactive shell execution.

## 10. Application Cannot Write Files

### Scenario

The app starts but fails when writing output.

### Ideal Answer

I would inspect file and directory ownership, permissions, mount options, available disk space, and whether the service user has the correct access path. Many file-write failures are permission or mount issues rather than app logic issues.

## 11. Memory Usage Keeps Growing

### Scenario

The system becomes unstable over time because memory usage keeps rising.

### Ideal Answer

I would identify which process or process group is growing, then check whether it is true memory leak behavior, cache growth, or workload pressure. I would also watch swap usage and whether the kernel starts invoking OOM behavior.

## 12. A Config Change Was Made but Nothing Improved

### Scenario

An engineer updated a config file, but behavior did not change.

### Ideal Answer

I would verify whether the right file was changed, whether the service was reloaded or restarted, and whether another configuration source overrides it. In Linux systems, a valid config edit is not helpful if the running process never consumes it.

## 13. The Host Reboots but a Mount Is Missing

### Scenario

A filesystem works manually but does not appear after reboot.

### Ideal Answer

I would inspect the mount definition, `fstab` correctness, device naming, dependencies, and whether the system can discover the storage at boot time. Boot-order or config syntax mistakes are common here.

## 14. Logs Are Too Noisy to Be Useful

### Scenario

There is a lot of log volume, but it is hard to identify the real issue.

### Ideal Answer

I would narrow by service, time window, severity, and correlation with the incident start. Good troubleshooting is often about reducing noise and isolating the smallest useful log boundary first.

## 15. Linux Host Is Fine but User Traffic Still Fails

### Scenario

The system appears healthy from host metrics, but users see service errors.

### Ideal Answer

I would move beyond host health and inspect application logs, service routing, reverse proxy behavior, DNS, TLS, and downstream dependency calls. A healthy server does not guarantee a healthy end-to-end path.

## 16. Performance Drops After a Deployment

### Scenario

A release went live and the host becomes slower.

### Ideal Answer

I would compare process count, memory profile, open files, log volume, and system resource patterns before and after the release. Deployment-related performance issues often come from changed runtime behavior rather than a sudden infrastructure fault.

## 17. A Script Works Manually but Fails in Automation

### Scenario

Running a script by hand succeeds, but the scheduled or automated version fails.

### Ideal Answer

I would compare execution user, PATH, current working directory, required environment variables, file permissions, and whether the script relies on interactive shell behavior that automation does not provide.

## 18. Recovery Took Too Long

### Scenario

The issue was fixed eventually, but operational recovery was slow.

### Ideal Answer

I would review whether the delay came from weak observability, unclear ownership, poor runbooks, slow rollback, or missing automation. Slow recovery is often a systems and process issue, not just a one-time human delay.
