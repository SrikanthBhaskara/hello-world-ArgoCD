# Linux Process Internals, Resource Controls, and Container Runtimes

This note fills roadmap topics that were previously only partially explicit:

- process forking internals
- `ulimit` and resource limits
- `cgroups`
- container runtime architecture beyond just Docker commands

---

## 1. Process Lifecycle Fundamentals

### What is a process?

A process is a running program with:

- its own PID
- memory mappings
- file descriptors
- environment
- scheduling state

### Common lifecycle

1. process is created
2. it runs in user and kernel mode as needed
3. it may create child processes
4. it exits
5. parent collects exit status

---

## 2. `fork`, `exec`, and `wait`

These are the core ideas behind process creation in Unix-like systems.

### `fork`

- creates a child process
- child gets a new PID
- child begins as a near copy of the parent

### `exec`

- replaces the current process image with a new program
- PID stays the same for that process after `exec`

### `wait`

- parent collects the child exit status
- prevents zombies when used correctly

### Interview-ready explanation

A very common model is: parent `fork`s, child `exec`s the target program, parent `wait`s or otherwise handles the child lifecycle.

---

## 3. Parent, Child, Zombie, and Orphan Processes

### Parent process

- process that created another process

### Child process

- process created by a parent

### Zombie process

- child has already exited
- parent has not yet collected its exit status
- still appears in process table until reaped

### Orphan process

- parent exits before child
- child gets adopted by PID 1, usually `systemd`

### Useful commands

```bash
ps -ef
ps -el
pstree -p
top
```

### What to say in interviews

A zombie is not a running process consuming CPU. It is an exited child whose metadata is still waiting to be collected by the parent.

---

## 4. Signals and Graceful Shutdown

### Common signals

| Signal | Meaning |
|---|---|
| `SIGTERM` | polite termination request |
| `SIGKILL` | forced kill, cannot be ignored |
| `SIGHUP` | reload or terminal disconnect semantics |
| `SIGINT` | interrupt, often from `Ctrl+C` |
| `SIGSTOP` | pause execution |
| `SIGCONT` | continue paused process |

### Good production practice

- prefer `SIGTERM` first
- use `SIGKILL` only if the process does not stop cleanly

---

## 5. Scheduling and Priorities

### Niceness

- lower nice value means higher scheduling priority
- higher nice value means lower scheduling priority

Useful commands:

```bash
nice -n 10 command
renice 5 -p 1234
ps -eo pid,ni,comm
```

### Interview point

Nice values influence scheduling preference, but they are not the only factor in total performance problems.

---

## 6. `ulimit` and Resource Limits

`ulimit` controls per-shell or per-process resource ceilings.

### Common limits

- max open files
- max user processes
- core file size
- stack size
- virtual memory

### Soft vs hard limits

- **soft limit**: current enforced limit that a user can usually lower or raise up to the hard limit
- **hard limit**: upper ceiling generally requiring elevated privilege to increase

### Useful commands

```bash
ulimit -a
ulimit -n
cat /proc/$$/limits
```

### Common production scenario

Application fails with `too many open files`.

Checks:

```bash
ulimit -n
cat /proc/<pid>/limits
lsof -p <pid> | wc -l
```

### Configuration paths

- `/etc/security/limits.conf`
- `/etc/security/limits.d/`
- systemd service overrides may also matter

---

## 7. cgroups

### What cgroups do

**Control groups** let Linux account for and limit resource usage for a set of processes.

They are used for:

- CPU control
- memory limits
- I/O throttling
- process counting

### Why they matter

cgroups are one of the key building blocks behind containers and resource isolation.

### Interview explanation

Namespaces isolate what a process can see. cgroups limit how much resource that process can consume.

---

## 8. Namespaces vs cgroups

### Namespaces

Give isolated views for things such as:

- PID space
- network interfaces
- mount points
- hostname
- users

### cgroups

Limit and account for resource usage.

### Quick memory phrase

- **namespaces** = isolation
- **cgroups** = control

---

## 9. Container Runtime Stack

### High-level view

Containers are not magic VMs. They are Linux processes with isolation and resource control.

### Typical stack

1. Docker CLI or another client
2. Docker Engine or orchestration layer
3. container runtime manager such as **containerd**
4. low-level runtime such as **runc**
5. Linux kernel features such as namespaces and cgroups

### Important components

#### Docker Engine

- developer-friendly platform
- builds images
- runs containers
- manages networking, volumes, and CLI workflows

#### containerd

- container runtime manager
- handles image transfer, storage, lifecycle, task management

#### runc

- low-level OCI runtime
- actually creates the container process using Linux primitives

#### CRI-O

- Kubernetes-focused container runtime implementation
- works through Kubernetes Container Runtime Interface expectations

---

## 10. OCI and Why It Matters

### OCI

The **Open Container Initiative** standardizes:

- image format
- runtime behavior

This matters because different runtimes can still work with compatible images and runtime expectations.

### Interview answer

OCI makes containers portable across compatible runtimes by standardizing image and runtime specifications.

---

## 11. Docker vs containerd vs CRI-O

| Component | Main role |
|---|---|
| Docker | developer platform and workflow |
| containerd | runtime manager and lifecycle engine |
| runc | low-level OCI runtime |
| CRI-O | Kubernetes-native runtime option |

### Practical takeaway

If Docker is removed from a Kubernetes node, containers can still run because Kubernetes can talk to containerd or CRI-O directly.

---

## 12. How Kubernetes Fits In

### Old mental model

- people used Docker as the visible container tool everywhere

### Better modern model

- **kubelet** talks to a runtime through the **CRI**
- runtime may be **containerd** or **CRI-O**
- low-level runtime still uses Linux kernel features

### Good interview statement

Kubernetes does not need the Docker CLI itself. It needs a compatible runtime stack on the node.

---

## 13. Practical Troubleshooting Scenarios

### Too many open files

```bash
ulimit -n
cat /proc/<pid>/limits
lsof -p <pid> | wc -l
```

### Process stuck or defunct

```bash
ps -ef | grep defunct
pstree -p
ps -o pid,ppid,state,cmd -p <pid>
```

### Memory pressure in containerized workload

```bash
free -m
top
cat /sys/fs/cgroup/memory.current
cat /sys/fs/cgroup/memory.max
```

### CPU throttling or constrained workload

```bash
top
ps -eo pid,ni,comm
cat /sys/fs/cgroup/cpu.max
```

### Need to know what runtime is on a node

```bash
crictl info
ps -ef | grep -E 'containerd|crio'
kubectl get node -o wide
```

---

## 14. Interview-Ready Summary

### Short answer

Linux process creation is based on `fork`, `exec`, and `wait`. Resource limits can be enforced with `ulimit` and cgroups. Containers use Linux namespaces for isolation and cgroups for resource control, and runtimes like containerd or CRI-O manage container execution.

### Better answer

I think of Linux process and container internals in layers. At the process layer, a parent can fork a child, the child can exec a new program, and the parent should wait to avoid zombies. At the control layer, `ulimit` applies per-process limits such as open files, while cgroups enforce structured CPU and memory controls for groups of processes. At the container layer, Docker is mostly the developer-facing platform, containerd is the runtime manager, runc is the low-level OCI runtime, and Kubernetes usually interacts with a runtime like containerd or CRI-O through CRI. That model helps me troubleshoot process leaks, file descriptor exhaustion, and container resource issues more clearly.
