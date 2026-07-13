# Linux 02 – Filesystem & Storage

## 0. Goal of This Note

- Understand Linux directory layout (FHS).  
- Work confidently with paths, links, and disk usage.  
- Get a first look at devices, partitions, mounts, and fstab.

---

## 1. Paths & Directory Layout

### 1.1 Absolute vs Relative Paths

- **Absolute**: start from `/`.
  - `/home/user/docs/report.txt`  
- **Relative**: from current directory.
  - `docs/report.txt`, `../backup`

Specials:

- `.` – current directory.  
- `..` – parent directory.  
- `~` – your home directory.

### 1.2 FHS – Filesystem Hierarchy Standard

Key directories (you should know these by heart over time):

- `/` – root of everything.  
- `/home` – home directories of normal users.  
- `/root` – home of root user.  
- `/bin` – essential user commands (ls, cp, mv, etc.).  
- `/sbin` – essential system commands (fsck, mount, etc.).  
- `/usr` – “user” programs (larger tree of apps and libraries).  
- `/var` – variable data (logs, spool, cache).  
- `/tmp` – temporary files.  
- `/etc` – system‑wide configuration.  
- `/dev` – device files.  
- `/proc`, `/sys` – virtual files exposing kernel & process info.

Commands to explore:

```bash
ls /
ls /etc
ls /var
ls /home
```

---

## 2. Links: Hard vs Soft (Symbolic)

### 2.1 Hard Links

- Another name for the same inode (same file content on disk).  
- Must be on same filesystem.  
- Deleting one name does **not** delete the data if other hard links exist.

Create a hard link:

```bash
touch original.txt
ln original.txt hardlink.txt
```

Check with `ls -li` (shows inode numbers).

### 2.2 Symbolic (Soft) Links

- Special file that points to another path (like a shortcut).  
- Can cross filesystems.  
- If the target is deleted, the symlink becomes broken.

Create a soft link:

```bash
ln -s /path/to/realfile shortcut
```

Examples:

```bash
ln -s /etc/hosts hosts-link
ls -l hosts-link
```

---

## 3. Disk Usage & Free Space

### 3.1 df – Filesystem Free Space

```bash
df -h                  # human-readable
```

Shows mounted filesystems, their size, used, available, and mountpoint.

### 3.2 du – Directory/ File Usage

```bash
du -sh *               # size of items in current dir
du -sh /var/log        # size of /var/log
```

Useful patterns:

```bash
du -sh .               # total size of current directory
du -sh /home/*         # size per home directory
```

---

## 4. Devices, Partitions & Mounts (Intro)

### 4.1 Devices and Partitions

- Block devices are visible under `/dev`.  
- Disk devices: `/dev/sda`, `/dev/sdb`, …  
- Partitions: `/dev/sda1`, `/dev/sda2`, etc.

View block devices:

```bash
lsblk
```

You’ll see hierarchy: disk → partitions → mountpoints.

### 4.2 Mounting

Linux uses a **single unified tree**; devices are “mounted” into directories.

View mounts:

```bash
mount
findmnt
```

Manual mount example (USB drive as `/dev/sdb1`):

```bash
sudo mkdir -p /mnt/usb
sudo mount /dev/sdb1 /mnt/usb
ls /mnt/usb
sudo umount /mnt/usb
```

Be careful: always unmount before unplugging removable drives.

### 4.3 /etc/fstab (Overview)

- Config file listing filesystems to mount at boot.  
- Each line has: device, mountpoint, fstype, options, dump, pass.

Example line:

```text
UUID=xxxx-xxxx  /data  ext4  defaults  0  2
```

You generally:

1. Create filesystem.  
2. Get UUID via `blkid`.  
3. Add entry to `/etc/fstab`.  
4. Test with `sudo mount -a`.

This is advanced; don’t edit `fstab` on production machines until you understand it well.

---

## 5. Filesystem Types (Brief)

Common ones:

- `ext4` – default on many distros.  
- `xfs` – used by RHEL/CentOS.  
- `btrfs` – modern features (snapshots, checksumming).  
- `vfat`, `ntfs` – Windows/USB interoperability.

Checking filesystem type:

```bash
lsblk -f
```

---

## 6. Practice Tasks

1. Explore the filesystem:
   - From `/`, inspect `/etc`, `/var`, `/home`, `/dev`, `/proc`.  
   - Note what kind of files you see in each.
2. Links:
   - Create `original.txt` with some text.  
   - Make both a hard link (`ln`) and symlink (`ln -s`).  
   - Delete `original.txt` and see what happens to each link.
3. Disk usage:
   - Use `df -h` to find which filesystem is almost full or almost empty.  
   - Use `du -sh /var/log` to see log space usage.
4. Mounts (if you have a removable drive):
   - Plug in a USB stick.  
   - Find it with `lsblk`.  
   - Mount it under `/mnt/usb`, list its files, then unmount.

When comfortable, proceed to **Linux 03 – Users, Permissions & sudo**.
