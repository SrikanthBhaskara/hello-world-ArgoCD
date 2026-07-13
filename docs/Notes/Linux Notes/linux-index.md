# Linux A–Z Study Index

Use this index to navigate all your Linux notes. Start at 00 and move through sequentially, or jump to any topic you need.

---

## Core Fundamentals (Start Here)

- **00** – [Overview & Getting Started](linux-00-overview.md)  
  - What Linux is, architecture, distros, WSL setup, shells
- **01** – [Shell & Terminal Basics](linux-01-shell-basics.md)  
  - Commands, navigation, history, wildcards, quoting, redirection intro
- **02** – [Filesystem & Storage](linux-02-filesystem-storage.md)  
  - FHS, paths, links, mounts, disk usage, partitions, fstab
- **03** – [Users, Groups & Permissions](linux-03-users-permissions.md)  
  - User management, chmod, chown, sudo, special bits, ACLs
- **04** – [Processes, Jobs & systemd](linux-04-processes-systemd.md)  
  - Process management, signals, jobs, systemd services, boot process
- **05** – [Networking & SSH](linux-05-networking-ssh.md)  
  - IP config, DNS, SSH, scp, rsync, basic troubleshooting
- **06** – [Bash Scripting & Automation](linux-06-scripting-automation.md)  
  - Variables, loops, functions, error handling, cron, real scripts
- **07** – [Security, Performance & Troubleshooting](linux-07-security-performance.md)  
  - Security basics, SSH hardening, firewall, monitoring, systematic debugging

---

## Advanced Topics (08-17)

- **08** – [Advanced Text Processing & Regular Expressions](linux-08-advanced-text-processing.md)  
  - grep/sed/awk mastery, regex deep dive, JSON/CSV processing
- **09** – [Advanced Networking & Firewalls](linux-09-advanced-networking.md)  
  - TCP/IP deep dive, iptables, nftables, packet capture, advanced troubleshooting
- **10** – [Package Management & Build Systems](linux-10-package-management.md)  
  - apt/dnf/pacman in depth, compiling from source, dependency management
- **11** – [Storage Management & LVM](linux-11-storage-lvm.md)  
  - Partitioning (fdisk/parted/gdisk), filesystems (ext4/XFS/Btrfs), LVM, RAID, quotas
- **12** – [Kernel, Modules & System Tuning](linux-12-kernel-tuning.md)  
  - Kernel modules, sysctl, performance tuning, CPU/memory/I/O optimization
- **13** – [Containers, Docker & Virtualization](linux-13-containers-virtualization.md)  
  - Docker complete guide, Dockerfile, docker-compose, KVM/QEMU, containers vs VMs
- **14** – [Web Servers (Apache & Nginx)](linux-14-web-servers.md)  
  - Apache/Nginx configuration, virtual hosts, SSL/TLS, reverse proxy, security
- **15** – [Git & Version Control](linux-15-git-version-control.md)  
  - Git fundamentals, branching/merging, workflows, GitHub/GitLab, best practices
- **16** – [System Monitoring & Logging](linux-16-monitoring-logging.md)  
  - Monitoring tools, systemd journal, rsyslog, log analysis, Prometheus/Grafana
- **17** – [Backup, Recovery & Disaster Planning](linux-17-backup-recovery.md)  
  - Backup strategies (tar/rsync/dd), snapshots, automated solutions, disaster recovery

---

## Desktop & Application Topics (18-21)

- **18** – [Graphical Interfaces & Desktop Environments](linux-18-graphical-interfaces.md)  
  - X11 vs Wayland, GNOME/KDE/Xfce, window managers, display managers, GUI configuration, theming
- **19** – [Text Editors Mastery](linux-19-text-editors.md)  
  - vim complete guide (modes, commands, plugins), nano for quick edits, emacs basics, editor workflows
- **20** – [Printing with CUPS](linux-20-printing-cups.md)  
  - CUPS setup, lp/lpr commands, print queue management, network printing, troubleshooting
- **21** – [Linux Foundation, Philosophy & Principles](linux-21-foundation-philosophy.md)  
  - History of Unix/Linux, Linux Foundation, open source licenses, Unix philosophy, community contribution

---

## LFCS Certification Topics (22-24)

- **22** – [SELinux & Mandatory Access Control](linux-22-selinux-mac.md)  
  - DAC vs MAC, SELinux modes (enforcing/permissive/disabled), contexts and labels, policies and booleans  
  - Troubleshooting denials (ausearch, audit2why, audit2allow), creating custom policies  
  - AppArmor comparison, security best practices
- **23** – [Advanced System Administration](linux-23-advanced-sysadmin.md)  
  - Autofs (automatic filesystem mounting), LDAP authentication (SSSD), time synchronization (chrony/NTP)  
  - SSL certificate management (openssl, Let's Encrypt), systemd timers vs cron
- **24** – [Advanced Networking Topics](linux-24-advanced-networking.md)  
  - Network bonding (LACP, active-backup), bridging (KVM bridges), static routing, policy-based routing  
  - NAT/MASQUERADE, DNAT port forwarding, IPv6 configuration  
  - Reverse proxy and load balancing (Nginx, HAProxy)

---

## Expert-Level Topics (25-29)

- **25** – [Database Administration (MySQL & PostgreSQL)](linux-25-database-administration.md)  
  - MySQL/MariaDB installation, configuration (my.cnf), user management, security best practices  
  - Database operations, backup/restore (mysqldump, automated scripts), performance tuning (EXPLAIN, OPTIMIZE, indexes)  
  - Master-slave replication setup, monitoring and troubleshooting  
  - PostgreSQL installation, configuration (postgresql.conf, pg_hba.conf), user/role management  
  - PostgreSQL backup/restore (pg_dump, pg_dumpall, pg_restore), performance tuning (EXPLAIN ANALYZE, VACUUM, REINDEX)  
  - PostgreSQL streaming replication, security best practices

- **26** – [Kubernetes Fundamentals & Container Orchestration](linux-26-kubernetes-fundamentals.md)  
  - Kubernetes architecture (control plane, worker nodes), installation (minikube, kubeadm)  
  - kubectl command mastery (get, describe, create, delete, apply, logs, exec, port-forward)  
  - Pods (single/multi-container, YAML manifests), Deployments (replicas, rolling updates, rollback)  
  - Services (ClusterIP, NodePort, LoadBalancer), ConfigMaps, Secrets  
  - Namespaces, resource management (requests/limits), labels and selectors  
  - Troubleshooting (Pending, CrashLoopBackOff, ImagePullBackOff), security best practices

- **27** – [Ansible Automation & Configuration Management](linux-27-ansible-automation.md)  
  - Ansible architecture (agentless, SSH-based), installation, inventory management  
  - Ad-hoc commands (ping, command, shell, copy, apt, service, setup facts)  
  - Playbooks (YAML structure, variables, conditionals, loops, handlers)  
  - Templates (Jinja2), Roles (directory structure, ansible-galaxy)  
  - Real-world examples (LAMP stack, security hardening, Docker deployment)  
  - Best practices (project organization, Ansible Vault encryption)

- **28** – [Samba & Cross-Platform File Sharing](linux-28-samba-file-sharing.md)  
  - Samba/SMB/CIFS (Windows-Linux file sharing), installation, smb.conf configuration  
  - Share types (public, private, homes, group), Samba user management  
  - Accessing shares (smbclient, mount -t cifs, Windows mapping)  
  - Security (authentication modes, SMB3 encryption, audit logging), troubleshooting (testparm, SELinux)  
  - NFS (Network File System) server/client setup, /etc/exports, NFSv4 Kerberos security  
  - SFTP chroot jails, vsftpd configuration

- **29** – [Advanced Security & PSIRT Toolkit](linux-29-advanced-security.md)  
  - LUKS disk encryption (cryptsetup, auto-mount with /etc/crypttab, key management)  
  - VPN configuration (OpenVPN setup, WireGuard modern VPN)  
  - Security auditing (Lynis system audit, OpenSCAP compliance scanning with CIS/PCI-DSS/HIPAA/STIG)  
  - Vulnerability scanning (Nmap scripts, OpenVAS/GVM, Nikto web scanner)  
  - Intrusion detection (OSSEC host-based IDS, Fail2Ban advanced configuration)  
  - Log analysis and centralized logging, security monitoring scripts  
  - PSIRT best practices (security hardening checklist, incident response workflow, forensic data collection)

---

---

## Career Preparation & Practical Application (30-34)

- **30** – [Hands-On Lab Exercises](linux-30-hands-on-labs.md)  
  - 30 comprehensive hands-on labs (Beginner 1-10, Intermediate 11-20, Advanced 21-30)  
  - System navigation, user/permission management, text processing, process management, networking  
  - LVM storage management, SSH hardening, web server configuration (Apache+SSL)  
  - Kubernetes deployment (3-tier apps), Ansible automation, database replication, security audits  
  - Each lab includes: objective, scenario, tasks, verification, complete solutions, troubleshooting

- **31** – [Linux Certification Roadmap](linux-31-certification-roadmap.md)  
  - Complete certification guide from beginner to expert level  
  - **Beginner**: LPI Linux Essentials, CompTIA Linux+ (exam objectives, 8-12 week study plans, practice questions)  
  - **Intermediate**: LFCS, RHCSA (detailed exam domains, 10-16 week study plans, must-master commands, practice exams)  
  - **Advanced**: RHCE, CKA, CKAD (Kubernetes certifications)  
  - **Specialized**: CKS (Kubernetes Security), GIAC Security+  
  - Study plans mapped to documentation files, exam tips, time management strategies, certification paths for 4 career tracks

- **32** – [Real-World Linux Scenarios](linux-32-real-world-scenarios.md)  
  - 25 production scenarios Linux administrators face daily  
  - **System Admin**: Disk space crisis, system won't boot, runaway processes, memory leaks, user login issues  
  - **Networking**: Website down, slow network, DNS failures, SSH broken, firewall blocking traffic  
  - **Security**: Suspected server compromise (complete incident response), SELinux blocking apps, unauthorized access  
  - **Performance**: Database slow queries, high load investigation, disk I/O bottlenecks, bandwidth saturation  
  - **Disaster Recovery**: Accidental deletion, failed updates, corrupted filesystems, RAID failures, complete recovery  
  - Each scenario: symptoms, troubleshooting steps, multiple solutions, prevention strategies

- **33** – [Linux Command Cheat Sheet](linux-33-command-cheat-sheet.md)  
  - Complete command reference organized by category (basic to expert level)  
  - File & Directory Operations, User & Permission Management, Process Management, System Information  
  - Networking (ip, ss, ping, curl, dig, nmcli), Package Management (apt/dnf/yum/rpm)  
  - Text Processing (grep/sed/awk/cut/sort/uniq), Disk & Storage (fdisk, lvm, mkfs, mount, RAID)  
  - systemd Service Management, Security & Firewall (firewalld/ufw/iptables, SELinux)  
  - Monitoring & Performance (top/htop, iostat, sar, iotop, tcpdump)  
  - Compression & Archives, Bash Scripting, Advanced Administration (cron, systemd timers, tuning)  
  - Quick reference: Top 20 daily commands, Top 15 troubleshooting, LFCS/RHCSA essentials

- **34** – [Linux Interview Preparation](linux-34-interview-preparation.md)  
  - Comprehensive Q&A for all Linux-related roles (beginner to expert level)  
  - **Linux System Administrator**: 15 questions (fundamentals, troubleshooting, LVM, boot process, performance analysis)  
  - **DevOps Engineer**: CI/CD implementation, secret management, Infrastructure as Code, containerization  
  - **Site Reliability Engineer (SRE)**: High availability, incident response, SLA management, monitoring, automation  
  - **Database Administrator**: MySQL/PostgreSQL administration, replication, backup/restore, performance tuning  
  - **Security Engineer / PSIRT**: Security breach investigation (complete forensic workflow), hardening, compliance  
  - **Cloud Engineer**: AWS/Azure/GCP Linux deployments, networking, IAM, cost optimization  
  - Each answer includes: detailed explanations, commands, real-world examples, best practices, common pitfalls  
  - Interview success tips, role-specific focus areas, communication strategies

---

## Quick Reference

- **[linux-notes.md](linux-notes.md)** – Original compact beginner→pro reference (single file)

---

## How to Use These Notes

1. **Complete beginners**: Start at 00, work through to 07 in order
2. **Some Linux experience**: Review 00-02, then focus on gaps
3. **Preparing for sysadmin work**: Focus on 03-05, 07, 09-11
4. **Scripting/automation focus**: Deep dive 06, 08
5. **LFCS certification**: Cover all topics 00-24 systematically, then use **31** (certification roadmap) for exam-specific preparation
6. **DevOps/SRE roles**: Focus on 13 (containers), 26 (Kubernetes), 27 (Ansible), 14 (web servers), **30** (hands-on labs), **34** (interviews)
7. **Database administrators**: Deep dive 25, plus 11 (storage), 16 (monitoring), 17 (backups), **32** (real-world scenarios)
8. **Security professionals/PSIRT**: Master 29, 22 (SELinux), 07 (security basics), 09 (firewalls), **32** (incident response), **34** (security interviews)
9. **Advanced users/Linux experts**: Complete all topics 00-34 for complete industry expertise
10. **Job seekers/Career preparation**: Use **30** (hands-on labs), **31** (certifications), **32** (scenarios), **33** (command reference), **34** (interviews)

**Practical Application Path**:
1. **Learn** theory from files 00-29 (technical knowledge)
2. **Practice** with files 30, 32 (hands-on labs, real-world scenarios)
3. **Certify** using file 31 (certification roadmap with study plans)
4. **Reference** file 33 (command cheat sheet for quick lookup)
5. **Interview** with file 34 (Q&A preparation for all roles)

Each file has practice exercises at the end. Do them before moving to the next topic.

✅ **Complete Career-Ready Package**: This documentation (35 files, 50,000+ lines) provides everything needed to go from Linux beginner to expert, ace certifications (LFCS, RHCSA, CKA), handle production scenarios, and land jobs in Linux Administration, DevOps, SRE, Database Administration, Security/PSIRT, and Cloud Engineering roles.

As you learn, feel free to add your own examples, commands, and notes into these files or create new ones and link them here.
