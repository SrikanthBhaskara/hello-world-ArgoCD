# Linux 11 – Storage Management & LVM

## 0. Goal of This Note

- Master disk partitioning (fdisk, parted, gdisk).  
- Understand and use LVM (Logical Volume Manager).  
- Learn RAID concepts and implementation.  
- Manage filesystems, quotas, and snapshots.

---

## 1. Disk Partitioning Fundamentals

### 1.1 Partition Tables: MBR vs GPT

| Feature | MBR (Master Boot Record) | GPT (GUID Partition Table) |
|---------|-------------------------|---------------------------|
| **Max partitions** | 4 primary (or 3+extended) | 128 partitions |
| **Max disk size** | 2 TB | 9.4 ZB (essentially unlimited) |
| **Boot support** | BIOS | UEFI (also BIOS with compatibility) |
| **Redundancy** | No | Yes (header + backup) |
| **Tools** | fdisk, cfdisk | gdisk, parted |

**When to use what:**
- MBR: Legacy systems, disks < 2TB, BIOS boot
- GPT: Modern systems, large disks, UEFI boot (recommended)

### 1.2 Partitioning with fdisk (MBR)

**View partitions:**
```bash
sudo fdisk -l                    # list all disks
sudo fdisk -l /dev/sda           # specific disk
lsblk                            # tree view of block devices
```

**Partition a disk:**
```bash
sudo fdisk /dev/sdb              # interactive mode

# Inside fdisk:
m        # help
p        # print partition table
n        # new partition
d        # delete partition
t        # change partition type
w        # write changes (BE CAREFUL!)
q        # quit without saving
```

**Example session:**
```bash
sudo fdisk /dev/sdb

n        # new partition
p        # primary
1        # partition number
[Enter]  # default start
+10G     # size: 10GB
t        # change type
1        # partition number
83       # Linux filesystem (or 8e for LVM)
w        # write and exit
```

**After partitioning:**
```bash
sudo partprobe /dev/sdb          # inform kernel of changes
lsblk                            # verify
```

### 1.3 Partitioning with parted (GPT)

```bash
# View
sudo parted /dev/sdb print

# Create GPT table
sudo parted /dev/sdb mklabel gpt

# Create partition
sudo parted /dev/sdb mkpart primary ext4 0% 10GB
sudo parted /dev/sdb mkpart primary ext4 10GB 50GB

# Delete partition
sudo parted /dev/sdb rm 1

# Resize partition (careful!)
sudo parted /dev/sdb resizepart 1 20GB

# Set flags
sudo parted /dev/sdb set 1 boot on
```

**Non-interactive mode:**
```bash
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart primary ext4 0% 100%
```

### 1.4 gdisk (GPT-focused)

```bash
sudo gdisk /dev/sdb

# Similar to fdisk but for GPT
n        # new partition
d        # delete
t        # change type (8300=Linux, 8e00=LVM, ef00=EFI)
w        # write
q        # quit
```

---

## 2. Filesystem Creation & Management

### 2.1 Common Filesystem Types

| Filesystem | Best For | Features |
|------------|----------|----------|
| **ext4** | General Linux use | Mature, journaling, reliable |
| **XFS** | Large files, high performance | Excellent scalability, RHEL default |
| **Btrfs** | Advanced features | Snapshots, compression, checksums |
| **ZFS** | Enterprise storage | Snapshots, RAID-Z, integrity |
| **F2FS** | SSDs | Flash-optimized |
| **NTFS** | Windows interop | Read/write Windows drives |
| **exFAT** | USB drives, cross-platform | No size limits, Windows/Mac/Linux |

### 2.2 Creating Filesystems

```bash
# ext4
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 -L mydata /dev/sdb1          # with label
sudo mkfs.ext4 -m 1 /dev/sdb1               # 1% reserved (default 5%)

# XFS
sudo mkfs.xfs /dev/sdb1
sudo mkfs.xfs -L mydata /dev/sdb1

# Btrfs
sudo mkfs.btrfs /dev/sdb1
sudo mkfs.btrfs -L mydata /dev/sdb1

# FAT32 (for USB)
sudo mkfs.vfat -F 32 /dev/sdb1

# exFAT
sudo mkfs.exfat /dev/sdb1
```

### 2.3 Filesystem Utilities

**Check filesystem:**
```bash
sudo fsck /dev/sdb1              # general check (unmounted!)
sudo e2fsck /dev/sdb1            # ext2/3/4
sudo xfs_repair /dev/sdb1        # XFS

# Force check on next boot
sudo tune2fs -c 1 /dev/sdb1      # check after 1 mount
```

**Tune filesystem:**
```bash
# ext4 tuning
sudo tune2fs -l /dev/sdb1        # show info
sudo tune2fs -L newlabel /dev/sdb1  # change label
sudo tune2fs -m 1 /dev/sdb1      # set reserved blocks to 1%
sudo tune2fs -O ^has_journal /dev/sdb1  # disable journal (not recommended)

# XFS tuning
xfs_info /dev/sdb1               # show info
sudo xfs_admin -L newlabel /dev/sdb1  # change label
```

**Resize filesystem:**
```bash
# ext4 - can grow online, shrink offline
sudo resize2fs /dev/sdb1         # grow to partition size
sudo resize2fs /dev/sdb1 20G     # resize to 20G

# XFS - can only grow, not shrink
sudo xfs_growfs /mountpoint
```

### 2.4 Mounting Filesystems

**Manual mount:**
```bash
sudo mkdir -p /mnt/mydata
sudo mount /dev/sdb1 /mnt/mydata
sudo mount -t ext4 /dev/sdb1 /mnt/mydata   # explicit type

# Mount with options
sudo mount -o rw,noatime /dev/sdb1 /mnt/mydata

# Unmount
sudo umount /mnt/mydata
sudo umount /dev/sdb1
```

**Mount options:**
- `rw` / `ro` - read-write / read-only
- `noatime` - don't update access time (performance)
- `nosuid` - ignore suid/sgid bits (security)
- `noexec` - prevent execution (security)
- `defaults` - rw,suid,dev,exec,auto,nouser,async

**Permanent mounts (/etc/fstab):**
```bash
# /etc/fstab format:
# <device>  <mountpoint>  <type>  <options>  <dump>  <pass>

UUID=xxxx-xxxx  /mnt/mydata  ext4  defaults  0  2
/dev/sdb1       /mnt/backup  xfs   noatime   0  0

# Find UUID
sudo blkid /dev/sdb1
lsblk -f
```

**Test fstab:**
```bash
sudo mount -a                    # mount all from fstab
sudo findmnt --verify            # check fstab syntax
```

---

## 3. LVM (Logical Volume Manager) Complete Guide

### 3.1 LVM Concepts

```
Physical Disk(s) → Physical Volume(s) → Volume Group → Logical Volume(s) → Filesystem

Example:
/dev/sdb (100GB) → PV: /dev/sdb → VG: vg_data → LV: lv_mysql (20GB)
/dev/sdc (100GB) → PV: /dev/sdc ↗                  → LV: lv_web (30GB)
                                                   → LV: lv_backup (50GB)
```

**Benefits:**
- Resize volumes easily
- Snapshots for backups
- Span multiple disks
- Move data between disks online

**Components:**
- **PV (Physical Volume)**: Physical partition or disk
- **VG (Volume Group)**: Pool of PVs
- **LV (Logical Volume)**: Virtual partition from VG
- **PE (Physical Extent)**: Smallest allocatable unit (default 4MB)

### 3.2 Creating LVM Setup

**Step 1: Create Physical Volumes**
```bash
# View
sudo pvdisplay
sudo pvs                         # summary

# Create
sudo pvcreate /dev/sdb
sudo pvcreate /dev/sdc /dev/sdd  # multiple at once

# Remove
sudo pvremove /dev/sdb
```

**Step 2: Create Volume Group**
```bash
# View
sudo vgdisplay
sudo vgs                         # summary

# Create
sudo vgcreate vg_data /dev/sdb
sudo vgcreate vg_data /dev/sdb /dev/sdc  # multiple PVs

# Extend VG (add disk)
sudo vgextend vg_data /dev/sdd

# Reduce VG (remove disk - data must fit without it!)
sudo vgreduce vg_data /dev/sdd

# Remove VG
sudo vgremove vg_data
```

**Step 3: Create Logical Volumes**
```bash
# View
sudo lvdisplay
sudo lvs                         # summary

# Create
sudo lvcreate -L 20G -n lv_mysql vg_data       # 20GB
sudo lvcreate -l 100%FREE -n lv_data vg_data   # use all remaining

# Remove
sudo lvremove /dev/vg_data/lv_mysql
```

**Step 4: Create Filesystem and Mount**
```bash
sudo mkfs.ext4 /dev/vg_data/lv_mysql
sudo mkdir -p /var/lib/mysql
sudo mount /dev/vg_data/lv_mysql /var/lib/mysql

# Add to /etc/fstab
/dev/vg_data/lv_mysql  /var/lib/mysql  ext4  defaults  0  2
```

### 3.3 Resizing LVM

**Extend (grow) Logical Volume:**
```bash
# Add 10GB
sudo lvextend -L +10G /dev/vg_data/lv_mysql

# Use all free space
sudo lvextend -l +100%FREE /dev/vg_data/lv_mysql

# Extend LV and resize filesystem in one command
sudo lvextend -L +10G -r /dev/vg_data/lv_mysql

# Or manually resize filesystem after:
sudo resize2fs /dev/vg_data/lv_mysql     # ext4
sudo xfs_growfs /var/lib/mysql           # XFS
```

**Reduce (shrink) Logical Volume:**
```bash
# DANGER: Can cause data loss! Backup first!
# Only works with ext2/3/4, not XFS

# 1. Unmount
sudo umount /var/lib/mysql

# 2. Check filesystem
sudo e2fsck -f /dev/vg_data/lv_mysql

# 3. Resize filesystem first
sudo resize2fs /dev/vg_data/lv_mysql 15G

# 4. Reduce LV
sudo lvreduce -L 15G /dev/vg_data/lv_mysql

# 5. Remount
sudo mount /dev/vg_data/lv_mysql /var/lib/mysql
```

### 3.4 LVM Snapshots

**Create snapshot:**
```bash
# Create 5GB snapshot of lv_mysql
sudo lvcreate -L 5G -s -n lv_mysql_snap /dev/vg_data/lv_mysql

# View snapshots
sudo lvs
```

**Mount and backup:**
```bash
sudo mkdir /mnt/snap
sudo mount -o ro /dev/vg_data/lv_mysql_snap /mnt/snap
sudo tar -czf /backup/mysql_backup.tar.gz -C /mnt/snap .
sudo umount /mnt/snap
```

**Remove snapshot:**
```bash
sudo lvremove /dev/vg_data/lv_mysql_snap
```

**Merge snapshot (revert to snapshot):**
```bash
# Unmount LV
sudo umount /var/lib/mysql

# Merge
sudo lvconvert --merge /dev/vg_data/lv_mysql_snap

# Remount (snapshot is automatically removed)
sudo mount /dev/vg_data/lv_mysql /var/lib/mysql
```

---

## 4. RAID Overview

### 4.1 RAID Levels

| Level | Name | Min Disks | Usable Space | Redundancy | Performance | Use Case |
|-------|------|-----------|--------------|------------|-------------|----------|
| **RAID 0** | Striping | 2 | 100% | None | Fast R/W | Performance, no backup needed |
| **RAID 1** | Mirroring | 2 | 50% | 1 disk failure | Fast read | OS, critical data |
| **RAID 5** | Parity | 3 | (n-1)/n | 1 disk failure | Good R/W | General servers |
| **RAID 6** | Double Parity | 4 | (n-2)/n | 2 disk failures | Good read | Large arrays |
| **RAID 10** | Mirror+Stripe | 4 | 50% | 1 per mirror | Fast R/W | Databases, VMs |

### 4.2 Software RAID with mdadm

**Create RAID 1:**
```bash
# Install mdadm
sudo apt install mdadm           # Debian/Ubuntu
sudo dnf install mdadm           # Fedora

# Create array
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc

# View status
cat /proc/mdstat
sudo mdadm --detail /dev/md0

# Create filesystem
sudo mkfs.ext4 /dev/md0

# Save config
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# Update initramfs
sudo update-initramfs -u
```

**Create RAID 5:**
```bash
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
```

**Manage RAID:**
```bash
# Add spare
sudo mdadm --add /dev/md0 /dev/sde

# Remove disk
sudo mdadm --fail /dev/md0 /dev/sdc
sudo mdadm --remove /dev/md0 /dev/sdc

# Add replacement
sudo mdadm --add /dev/md0 /dev/sdf

# Stop array
sudo mdadm --stop /dev/md0

# Assemble array
sudo mdadm --assemble /dev/md0 /dev/sdb /dev/sdc
```

---

## 5. Disk Quotas

### 5.1 Setup Quotas

**Install:**
```bash
sudo apt install quota           # Debian/Ubuntu
```

**Enable in /etc/fstab:**
```bash
# Add usrquota,grpquota to options
/dev/sdb1  /home  ext4  defaults,usrquota,grpquota  0  2
```

**Remount:**
```bash
sudo mount -o remount /home
```

**Initialize quota database:**
```bash
sudo quotacheck -cugm /home      # create quota files
sudo quotaon /home               # enable quotas
```

### 5.2 Manage Quotas

**Set quota for user:**
```bash
sudo edquota -u alice

# In editor, set:
# Filesystem  blocks  soft  hard  inodes  soft  hard
# /dev/sdb1   10000   50000 55000  1000   5000  5500
```

**Set quota for group:**
```bash
sudo edquota -g developers
```

**Copy quota:**
```bash
sudo edquota -p alice -u bob     # copy alice's quota to bob
```

**View quotas:**
```bash
quota -u alice                   # user quota
quota -g developers              # group quota
sudo repquota /home              # all quotas
```

**Grace period:**
```bash
sudo edquota -t                  # set grace periods
```

---

## 6. Practice Exercises

1. **Partitioning:**
   - Create GPT partition table on test disk
   - Create 3 partitions of different sizes
   - Format with ext4, XFS, and Btrfs
   - Mount and test

2. **LVM:**
   - Create 2 PVs, 1 VG, 2 LVs
   - Create filesystems and mount
   - Extend one LV by 5GB
   - Create snapshot, modify data, restore

3. **RAID:**
   - Create RAID 1 with 2 disks
   - Test failure (mdadm --fail)
   - Replace failed disk
   - Verify rebuild

4. **Quotas:**
   - Set up quotas on test filesystem
   - Create user with 100MB limit
   - Test by filling disk
   - View quota usage

Next: **Linux 12 – Kernel, Modules & System Tuning** for kernel management.
