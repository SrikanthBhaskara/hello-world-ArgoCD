# Linux Senior 5 to 7 Years Production Interview Guide

This guide helps turn Linux answers from command knowledge into operations and incident ownership answers.

---

## What Strong Linux Answers Should Include

- real operational use
- debugging sequence
- impact awareness
- security and permission thinking
- safe recovery strategy

---

## 1. Permissions

Do not stop at rwx definitions.

Explain:

- file vs directory semantics
- ownership and group design
- ACL use cases
- why root-only testing can hide real permission problems

### Strong line

"If a service user cannot read a file, I check not only the file permissions but also the directory traversal permissions and ownership chain."

---

## 2. Services and systemd

Strong answers include:

- unit lifecycle
- restart behavior
- logs
- dependency failures
- environment and permissions impact

### Debugging flow

- `systemctl status`
- `journalctl -u service`
- service user and file access
- config syntax
- dependent resource availability

---

## 3. Disk and Memory Incidents

Senior answers should cover:

- symptom vs root cause
- whether the issue is capacity, leak, or burst
- safe cleanup vs risky deletion
- recovery verification

---

## 4. Networking and DNS

Explain:

- local interface vs routing vs DNS vs firewall
- why ping success does not prove app availability
- where TCP, DNS, or policy boundaries can fail

### Strong line

"I separate the problem into name resolution, route reachability, port listening, and application response instead of calling it only a network issue."

---

## 5. Safe Linux Changes

Before changing production Linux systems:

- understand service impact
- confirm rollback or recovery path
- avoid destructive cleanup without verification
- keep logs and evidence
- prefer small reversible changes
