# Linux 13 – Containers, Docker & Virtualization

## 0. Goal of This Note

- Understand containerization vs virtualization.  
- Master Docker from basics to production.  
- Learn container orchestration basics (Docker Compose).  
- Understand KVM and QEMU for VMs.  
- Practice LXC/LXD containers.

---

## 1. Containers vs Virtual Machines

### 1.1 Comparison

```
Virtual Machine:
┌─────────────────────────────────┐
│      Application                │
│      ↓                          │
│      Libraries                  │
│      ↓                          │
│      Guest OS (Full Linux)      │
│      ↓                          │
│      Hypervisor (KVM, VMware)   │
│      ↓                          │
│      Host OS                    │
│      ↓                          │
│      Hardware                   │
└─────────────────────────────────┘

Container:
┌─────────────────────────────────┐
│      Application                │
│      ↓                          │
│      Libraries                  │
│      ↓                          │
│      Container Runtime (Docker) │
│      ↓                          │
│      Host OS                    │
│      ↓                          │
│      Hardware                   │
└─────────────────────────────────┘
```

| Feature | Containers | Virtual Machines |
|---------|-----------|------------------|
| **Startup** | Seconds | Minutes |
| **Size** | MBs | GBs |
| **Performance** | Near-native | Overhead from hypervisor |
| **Isolation** | Process-level | Hardware-level |
| **OS** | Shares host kernel | Independent OS |
| **Use Case** | Microservices, apps | Full OS isolation, different kernels |

### 1.2 Container Technologies

- **Docker**: Most popular, easy to use
- **Podman**: Daemonless, rootless alternative to Docker
- **LXC/LXD**: System containers (more VM-like)
- **containerd**: Low-level runtime (used by Docker/Kubernetes)
- **CRI-O**: Container runtime for Kubernetes

---

## 2. Docker Complete Guide

### 2.1 Docker Installation

**Debian/Ubuntu:**
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker                    # or log out/in

# Verify
docker --version
docker run hello-world
```

**RHEL/Fedora:**
```bash
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 2.2 Docker Basics

**Images:**
```bash
# Search for image
docker search nginx

# Pull image
docker pull nginx
docker pull nginx:1.23           # specific version
docker pull ubuntu:22.04

# List images
docker images
docker image ls

# Remove image
docker rmi nginx
docker rmi image-id

# Remove unused images
docker image prune
docker image prune -a            # remove all unused
```

**Containers:**
```bash
# Run container
docker run nginx                 # run and attach
docker run -d nginx              # detached (background)
docker run -d --name web nginx   # with name
docker run -it ubuntu bash       # interactive terminal

# Port mapping
docker run -d -p 8080:80 nginx   # host:container

# Volume mapping
docker run -d -v /host/path:/container/path nginx
docker run -d -v mydata:/data nginx  # named volume

# Environment variables
docker run -d -e "ENV_VAR=value" nginx

# Resource limits
docker run -d --memory="512m" --cpus="1.0" nginx

# List containers
docker ps                        # running only
docker ps -a                     # all (including stopped)

# Start/stop/restart
docker start container_name
docker stop container_name
docker restart container_name

# Remove container
docker rm container_name
docker rm -f container_name      # force remove running container

# Container logs
docker logs container_name
docker logs -f container_name    # follow
docker logs --tail 50 container_name  # last 50 lines

# Execute command in running container
docker exec container_name ls /
docker exec -it container_name bash  # interactive shell

# Copy files
docker cp container_name:/path/file /host/path
docker cp /host/file container_name:/path/

# Container stats
docker stats
docker stats container_name

# Inspect container
docker inspect container_name
```

### 2.3 Building Images with Dockerfile

**Simple Dockerfile:**
```dockerfile
# Dockerfile
FROM ubuntu:22.04

# Metadata
LABEL maintainer="your@email.com"
LABEL description="My custom image"

# Install packages
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy files
COPY index.html /var/www/html/
COPY config /etc/nginx/

# Set working directory
WORKDIR /app

# Environment variables
ENV APP_ENV=production
ENV PORT=8080

# Expose port
EXPOSE 80

# Run command
CMD ["nginx", "-g", "daemon off;"]
```

**Build image:**
```bash
docker build -t myapp:1.0 .
docker build -t myapp:latest -f Dockerfile.prod .
```

**Multi-stage build (smaller images):**
```dockerfile
# Build stage
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Final stage
FROM alpine:3.17
COPY --from=builder /app/myapp /myapp
CMD ["/myapp"]
```

**Dockerfile best practices:**
```dockerfile
# Use specific tags, not :latest
FROM ubuntu:22.04

# Combine RUN commands to reduce layers
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m appuser
USER appuser

# Use COPY instead of ADD (unless extracting archives)
COPY app /app

# Use .dockerignore to exclude files
# Create .dockerignore file:
# .git
# *.log
# node_modules
```

**Build and push:**
```bash
# Tag for registry
docker tag myapp:1.0 username/myapp:1.0

# Login to Docker Hub
docker login

# Push
docker push username/myapp:1.0
```

### 2.4 Docker Volumes

**Types of volumes:**
1. Named volumes (managed by Docker)
2. Bind mounts (host directory)
3. tmpfs mounts (in-memory)

```bash
# Create named volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect volume
docker volume inspect mydata

# Use named volume
docker run -d -v mydata:/data nginx

# Bind mount (host directory)
docker run -d -v /home/user/data:/data nginx
docker run -d -v $(pwd):/app nginx  # current directory

# Read-only mount
docker run -d -v /host/data:/data:ro nginx

# tmpfs (memory, not persisted)
docker run -d --tmpfs /tmp nginx

# Remove volume
docker volume rm mydata

# Remove unused volumes
docker volume prune
```

### 2.5 Docker Networks

**Network types:**
- **bridge**: Default, containers on same host
- **host**: Share host network namespace
- **none**: No networking
- **overlay**: Multi-host networking (Swarm)

```bash
# List networks
docker network ls

# Create network
docker network create mynet
docker network create --driver bridge mybridge

# Run container on network
docker run -d --network mynet --name web nginx

# Connect container to network
docker network connect mynet container_name

# Disconnect
docker network disconnect mynet container_name

# Inspect network
docker network inspect mynet

# Container DNS (containers can resolve each other by name)
docker run -d --network mynet --name web1 nginx
docker run -it --network mynet ubuntu bash
# Inside container:
ping web1                        # resolves to web1 container IP

# Remove network
docker network rm mynet
```

---

## 3. Docker Compose

### 3.1 Installation

Docker Compose V2 (plugin) is included with Docker Desktop and modern installations.

```bash
# Verify
docker compose version

# If not installed (standalone):
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3.2 docker-compose.yml

**Simple example:**
```yaml
version: '3.9'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - frontend

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myapp
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - backend

volumes:
  db-data:

networks:
  frontend:
  backend:
```

**Advanced example (WordPress + MySQL):**
```yaml
version: '3.9'

services:
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    networks:
      - backend

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - ./wp-content:/var/www/html/wp-content
    networks:
      - backend
      - frontend

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - wordpress
    networks:
      - frontend

volumes:
  db_data:

networks:
  frontend:
  backend:
```

### 3.3 Docker Compose Commands

```bash
# Start services
docker compose up                # foreground
docker compose up -d             # detached

# Build images
docker compose build
docker compose up --build        # rebuild and start

# View logs
docker compose logs
docker compose logs -f           # follow
docker compose logs web          # specific service

# List containers
docker compose ps

# Stop services
docker compose stop

# Stop and remove containers
docker compose down
docker compose down -v           # also remove volumes

# Restart services
docker compose restart
docker compose restart web       # specific service

# Execute command
docker compose exec web bash

# Scale services
docker compose up -d --scale web=3
```

---

## 4. KVM & QEMU Virtualization

### 4.1 Check Virtualization Support

```bash
# Check CPU support
egrep -c '(vmx|svm)' /proc/cpuinfo  # >0 means supported
lscpu | grep Virtualization

# Check KVM
lsmod | grep kvm
```

### 4.2 Install KVM

**Debian/Ubuntu:**
```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo usermod -aG libvirt $USER
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

**RHEL/Fedora:**
```bash
sudo dnf install qemu-kvm libvirt virt-install virt-manager
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

### 4.3 Creating VMs

**GUI (virt-manager):**
```bash
virt-manager
```

**CLI (virt-install):**
```bash
# Download ISO
wget http://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso

# Create VM
virt-install \
  --name ubuntu-vm \
  --ram 2048 \
  --disk path=/var/lib/libvirt/images/ubuntu-vm.qcow2,size=20 \
  --vcpus 2 \
  --os-variant ubuntu22.04 \
  --network bridge=virbr0 \
  --graphics none \
  --console pty,target_type=serial \
  --cdrom ubuntu-22.04-live-server-amd64.iso
```

**List available OS variants:**
```bash
osinfo-query os                  # List all
virt-install --os-variant list   # Alternative
```

### 4.4 VM Lifecycle Management

**List VMs:**
```bash
virsh list                       # Running VMs only
virsh list --all                 # All VMs (including stopped)
virsh list --inactive            # Stopped VMs only
```

**Start/Stop VMs:**
```bash
virsh start ubuntu-vm            # Start VM
virsh shutdown ubuntu-vm         # Graceful shutdown (sends ACPI signal)
virsh reboot ubuntu-vm           # Reboot VM
virsh reset ubuntu-vm            # Hard reset
virsh destroy ubuntu-vm          # Force power off (like pulling plug)
virsh suspend ubuntu-vm          # Pause VM (freeze state)
virsh resume ubuntu-vm           # Unpause VM
```

**Autostart on boot:**
```bash
virsh autostart ubuntu-vm        # Enable autostart
virsh autostart ubuntu-vm --disable  # Disable autostart
```

**Delete VM:**
```bash
# Stop VM
virsh destroy ubuntu-vm

# Undefine (remove from libvirt, but keeps disk)
virsh undefine ubuntu-vm

# Undefine and remove storage
virsh undefine ubuntu-vm --remove-all-storage

# Or manually delete disk
sudo rm /var/lib/libvirt/images/ubuntu-vm.qcow2
```

**VM Information:**
```bash
virsh dominfo ubuntu-vm          # General info (memory, CPUs, state)
virsh domblklist ubuntu-vm       # Disk list
virsh domiflist ubuntu-vm        # Network interface list
virsh vcpuinfo ubuntu-vm         # vCPU details
virsh domstats ubuntu-vm         # Performance stats
```

**Console Access:**
```bash
virsh console ubuntu-vm          # Serial console (Ctrl+] to exit)
```

### 4.5 Storage Pools & Volumes

**Storage pools** manage disk images centrally.

**List pools:**
```bash
virsh pool-list --all
# Default pool: /var/lib/libvirt/images
```

**Create directory-based storage pool:**
```bash
# Create directory
sudo mkdir /vm-storage

# Define pool
virsh pool-define-as vm-pool dir --target /vm-storage

# Build and start
virsh pool-build vm-pool
virsh pool-start vm-pool
virsh pool-autostart vm-pool

# Verify
virsh pool-list
virsh pool-info vm-pool
```

**Manage volumes (disk images):**
```bash
# List volumes in pool
virsh vol-list default

# Create new volume (20GB qcow2)
virsh vol-create-as default myvm-disk.qcow2 20G --format qcow2

# Delete volume
virsh vol-delete myvm-disk.qcow2 --pool default

# Volume info
virsh vol-info /var/lib/libvirt/images/ubuntu-vm.qcow2
```

**Clone volume:**
```bash
virsh vol-clone ubuntu-vm.qcow2 ubuntu-vm-clone.qcow2 --pool default
```

### 4.6 Snapshots

**Create snapshot:**
```bash
# Internal snapshot (VM must be qcow2 format)
virsh snapshot-create-as ubuntu-vm snapshot1 "Before updates"

# External snapshot (works with raw/qcow2)
virsh snapshot-create-as ubuntu-vm snapshot2 "Before config change" --disk-only
```

**List snapshots:**
```bash
virsh snapshot-list ubuntu-vm
```

**Snapshot info:**
```bash
virsh snapshot-info ubuntu-vm snapshot1
```

**Revert to snapshot:**
```bash
virsh snapshot-revert ubuntu-vm snapshot1
```

**Delete snapshot:**
```bash
virsh snapshot-delete ubuntu-vm snapshot1
```

### 4.7 Cloning VMs

**Full clone:**
```bash
virt-clone \
  --original ubuntu-vm \
  --name ubuntu-vm-clone \
  --file /var/lib/libvirt/images/ubuntu-vm-clone.qcow2
```

**Clone with new MAC address:**
```bash
virt-clone \
  --original ubuntu-vm \
  --name ubuntu-vm2 \
  --auto-clone
```

### 4.8 Network Configuration

**List networks:**
```bash
virsh net-list --all
# Default network: virbr0 (NAT mode, 192.168.122.0/24)
```

**Network info:**
```bash
virsh net-info default
virsh net-dumpxml default        # XML configuration
```

**Start/stop network:**
```bash
virsh net-start default
virsh net-autostart default
virsh net-destroy default        # Stop network
```

**Create bridge network** (see linux-24 for bridge setup):
```bash
cat > /tmp/bridge.xml << EOF
<network>
  <name>br0</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

virsh net-define /tmp/bridge.xml
virsh net-start br0
virsh net-autostart br0
```

**Attach VM to different network:**
```bash
# Edit VM config
virsh edit ubuntu-vm

# Change network section:
<interface type='network'>
  <source network='br0'/>
</interface>

# Or use command
virsh attach-interface ubuntu-vm network br0 --model virtio --config
```

**DHCP leases:**
```bash
virsh net-dhcp-leases default
```

### 4.9 Resource Management

**Set memory (requires shutdown):**
```bash
# Edit config
virsh edit ubuntu-vm

# Or use command
virsh setmem ubuntu-vm 4G --config
virsh setmaxmem ubuntu-vm 4G --config
```

**Set vCPUs:**
```bash
# Set vCPUs (requires shutdown)
virsh setvcpus ubuntu-vm 4 --config --maximum

# Hot-plug CPU (while running)
virsh setvcpus ubuntu-vm 2 --live
```

**Attach additional disk:**
```bash
# Create new volume
virsh vol-create-as default extra-disk.qcow2 10G --format qcow2

# Attach to VM
virsh attach-disk ubuntu-vm \
  /var/lib/libvirt/images/extra-disk.qcow2 \
  vdb --persistent --subdriver qcow2
```

**Detach disk:**
```bash
virsh detach-disk ubuntu-vm vdb --persistent
```

**CPU pinning (dedicate physical cores):**
```bash
# Pin vCPU 0 to physical CPU 0
virsh vcpupin ubuntu-vm 0 0

# Pin vCPU 1 to physical CPU 1
virsh vcpupin ubuntu-vm 1 1

# View pinning
virsh vcpupin ubuntu-vm
```

### 4.10 VM Monitoring

**Resource usage:**
```bash
# CPU and memory stats
virsh domstats ubuntu-vm

# Block device I/O
virsh domblkstat ubuntu-vm vda

# Network interface stats
virsh domifstat ubuntu-vm vnet0
```

**Real-time monitoring:**
```bash
# Install virt-top (like top for VMs)
sudo apt install virt-top

# Run
virt-top
```

### 4.11 Troubleshooting VMs

**Check VM status:**
```bash
virsh domstate ubuntu-vm
```

**View VM logs:**
```bash
sudo tail -f /var/log/libvirt/qemu/ubuntu-vm.log
```

**Check libvirt daemon:**
```bash
sudo systemctl status libvirtd
sudo journalctl -u libvirtd
```

**VM won't start:**
```bash
# Check XML for errors
virsh dumpxml ubuntu-vm

# Validate XML
virt-xml-validate /etc/libvirt/qemu/ubuntu-vm.xml

# Check permissions
ls -l /var/lib/libvirt/images/

# Check if disk exists
virsh domblklist ubuntu-vm
```

**Network issues:**
```bash
# Check network is active
virsh net-list

# Check bridge
ip link show virbr0
brctl show

# Restart network
virsh net-destroy default
virsh net-start default
```

**Reset VM (if hung):**
```bash
virsh reset ubuntu-vm
```

**Access VM disk from host** (when VM is stopped):
```bash
# Mount qcow2 image
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/ubuntu-vm.qcow2
sudo mount /dev/nbd0p1 /mnt

# Do work...

# Unmount
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0
```

---

## 5. Practice Exercises

1. **Docker basics:**
   - Install Docker
   - Run nginx container with port 8080:80
   - Create custom HTML page and mount it
   - Access from browser

2. **Dockerfile:**
   - Create Dockerfile for Python Flask app
   - Build image
   - Run container
   - Push to Docker Hub

3. **Docker Compose:**
   - Create WordPress + MySQL stack
   - Configure with compose file
   - Deploy and test
   - Backup database volume

4. **KVM:**
   - Install KVM
   - Create Ubuntu VM
   - Configure networking
   - Take snapshot

Next: **Linux 14 – Web Servers & Services** for Apache/Nginx configuration.
