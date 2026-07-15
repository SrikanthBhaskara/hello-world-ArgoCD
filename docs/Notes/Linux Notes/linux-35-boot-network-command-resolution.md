# Linux Boot, Low-Level Networking, and Command Resolution

This note fills roadmap topics that were previously covered only indirectly across multiple Linux notes. It focuses on:

- Linux boot flow and boot loaders
- ARP/RARP and low-level networking foundations
- DHCP, routing, and DNS flow
- Command lookup and `$PATH` resolution

---

## 1. Linux Boot Flow

### End-to-end startup sequence

1. **Power on**
   - CPU resets and firmware starts.

2. **Firmware stage**
   - **BIOS** uses legacy boot flow.
   - **UEFI** uses EFI boot entries and usually boots from an EFI System Partition.

3. **Boot loader stage**
   - Most Linux systems use **GRUB2**.
   - The boot loader selects a kernel and usually loads an `initramfs` image too.

4. **Kernel stage**
   - The kernel initializes memory, CPU features, drivers, and core subsystems.
   - It mounts the initial temporary root filesystem from `initramfs`.

5. **initramfs stage**
   - Loads drivers needed to reach the real root filesystem.
   - Handles storage discovery such as LVM, RAID, encrypted disks, or special root devices.

6. **Real root filesystem mount**
   - The system switches from the temporary initramfs environment to the actual root filesystem.

7. **PID 1 starts**
   - On modern Linux, this is usually **systemd**.
   - systemd starts targets, services, sockets, mounts, timers, and dependencies.

8. **System reaches target**
   - Common targets:
   - `multi-user.target` for non-GUI systems
   - `graphical.target` for GUI systems

### Important interview statement

A strong answer is: Linux boot is firmware -> boot loader -> kernel -> initramfs -> real root filesystem -> PID 1 (`systemd`) -> services and target.

---

## 2. BIOS vs UEFI

### BIOS

- Older boot model
- Usually associated with **MBR**
- More limited partition and boot metadata handling

### UEFI

- Modern firmware standard
- Usually associated with **GPT**
- Boots EFI binaries from the **EFI System Partition**
- More flexible and more common in current systems

### MBR vs GPT

| Item | MBR | GPT |
|---|---|---|
| Style | Legacy | Modern |
| Partition count | Limited | More flexible |
| Typical pairing | BIOS | UEFI |
| Metadata resilience | Lower | Better |

---

## 3. GRUB2 Boot Loader Basics

### What GRUB does

- Presents boot menu
- Loads kernel and initramfs
- Passes boot parameters to the kernel
- Can boot multiple kernels or operating systems

### Common GRUB paths

- BIOS style configs often involve `/boot/grub2/` or `/boot/grub/`
- UEFI systems often use `/boot/efi/EFI/`
- Main config commonly appears as:
  - `/boot/grub2/grub.cfg`
  - or `/boot/grub/grub.cfg`

### Common admin commands

```bash
cat /proc/cmdline
ls /boot
ls /boot/efi
grep GRUB /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
update-grub
```

### Common boot troubleshooting situations

#### System drops to GRUB prompt

- GRUB config may be missing or disk mapping changed
- Root filesystem UUID may have changed
- Boot entry may point to the wrong partition

#### Kernel panic during boot

- Wrong root filesystem
- Missing initramfs driver support
- Broken storage mapping
- Corrupt kernel/initramfs

#### System enters emergency mode

- Broken `/etc/fstab`
- Missing mount device
- Filesystem corruption
- Failed critical service dependency

### Practical checks

```bash
journalctl -b
journalctl -b -1
systemctl --failed
lsblk -f
cat /etc/fstab
```

---

## 4. initramfs and Why It Matters

`initramfs` is the temporary userspace used early in boot before the real root filesystem is ready.

It is important when:

- root filesystem is on LVM
- root filesystem is on software RAID
- root filesystem is encrypted
- extra storage drivers are needed before mount

If initramfs is broken or missing required drivers, the system may fail before the real root filesystem is mounted.

---

## 5. Low-Level Networking Foundations

### Ethernet vs IP

- **Ethernet** works at the frame and MAC-address level on the local network
- **IP** works at the logical addressing and routing level across networks

### MAC address

- Hardware or interface-level address used inside a local segment

### IP address

- Logical address used for routing traffic across networks

### Why both matter

When a host wants to talk to another host in the same subnet, it needs the target MAC address to place traffic on the wire.

---

## 6. ARP and RARP

### ARP

**Address Resolution Protocol** maps an IPv4 address to a MAC address on the local network.

Example flow:

1. Host wants to reach `192.168.1.20`
2. It checks ARP cache
3. If no entry exists, it broadcasts an ARP request
4. Target host replies with its MAC address
5. Source host stores that in ARP cache

Useful commands:

```bash
ip neigh
arp -n
ping 192.168.1.20
tcpdump -n -i eth0 arp
```

### RARP

**Reverse ARP** was used historically to map MAC to IP, but modern environments usually use **DHCP** instead.

Interview answer:

ARP is still operationally relevant; RARP is mostly historical.

---

## 7. DHCP Flow

### Purpose

DHCP dynamically assigns:

- IP address
- subnet mask
- default gateway
- DNS server

### Basic DHCP sequence

Often remembered as **DORA**:

1. **Discover**
2. **Offer**
3. **Request**
4. **Acknowledge**

### Practical checks

```bash
ip addr
ip route
nmcli device show
journalctl -u NetworkManager
```

---

## 8. IP Routing Basics

### Key idea

Routing decides **where traffic goes next**.

### Local subnet traffic

- Sent directly after ARP resolution

### Remote subnet traffic

- Sent to the **default gateway**

### Useful commands

```bash
ip route
ip route get 8.8.8.8
ss -tulnp
traceroute google.com
```

### Interview explanation

If DNS works but traffic still fails, the issue may be routing, firewall, or remote endpoint reachability rather than name resolution.

---

## 9. DNS Resolution Flow

### Typical flow

1. Application asks system resolver
2. Resolver may check `/etc/hosts`
3. Resolver checks configured DNS server
4. DNS server returns IP
5. Client connects to the returned IP

### Useful files and commands

```bash
cat /etc/resolv.conf
cat /etc/hosts
dig google.com
nslookup google.com
getent hosts google.com
```

### Important distinction

- `ping 8.8.8.8` success but `ping google.com` failure usually indicates DNS issue
- both failing may indicate routing, firewall, network, or upstream issue

---

## 10. Command Resolution and `$PATH`

### How the shell resolves a command

When you type a command, the shell often checks in this order:

1. alias
2. shell function
3. shell builtin
4. executable found in `$PATH`

### `$PATH`

`$PATH` is a colon-separated list of directories the shell searches for executables.

Example:

```bash
echo $PATH
```

If `/usr/local/bin` appears before `/usr/bin`, the shell finds executables in `/usr/local/bin` first.

### Useful lookup commands

```bash
echo $PATH
which java
type java
command -v java
whereis java
```

### Difference between lookup commands

| Command | Best use |
|---|---|
| `which` | Quick executable lookup |
| `type` | Shows alias, function, builtin, or file |
| `command -v` | Reliable shell-friendly lookup |
| `whereis` | Finds binary, source, and man paths |

### Common interview scenario

#### Same command name behaves differently for different users

Possible causes:

- different `$PATH`
- alias in shell profile
- shell function overriding command
- different installed binary versions

Checks:

```bash
echo $PATH
type kubectl
command -v kubectl
alias
env | sort
```

---

## 11. Quick Troubleshooting Patterns

### Boot issue

```bash
journalctl -b
systemctl --failed
lsblk -f
cat /etc/fstab
```

### DNS issue

```bash
ping 8.8.8.8
ping google.com
dig google.com
cat /etc/resolv.conf
```

### Route issue

```bash
ip addr
ip route
ip route get 1.1.1.1
traceroute 1.1.1.1
```

### Command path issue

```bash
echo $PATH
type python
command -v python
whereis python
```

---

## 12. Interview-Ready Summary

### Short answer

Linux boot starts in BIOS or UEFI, moves to GRUB, loads the kernel and initramfs, mounts the real root filesystem, and then `systemd` starts services. At the network layer, ARP resolves IP-to-MAC on the local subnet, DHCP assigns IP configuration, routing decides the next hop, and DNS resolves names to IPs. For commands, the shell resolves aliases, functions, builtins, and then executables through `$PATH`.

### Better answer

In Linux, I think in layers. For boot, I trace firmware, boot loader, kernel, initramfs, root filesystem, and `systemd`. For networking, I separate local delivery, routing, and DNS resolution. For shell issues, I check whether the command is an alias, function, builtin, or binary and then confirm the actual executable using `type` or `command -v`. That approach helps me diagnose boot failures, DNS issues, route problems, and path conflicts quickly.
