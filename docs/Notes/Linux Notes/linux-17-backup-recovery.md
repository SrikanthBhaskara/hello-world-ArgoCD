# Linux 17 – Backup, Recovery & Disaster Planning

## 0. Goal of This Note

- Master backup strategies and tools (tar, rsync, dd).  
- Implement automated backup solutions.  
- Learn disaster recovery procedures.  
- Understand snapshot technologies (LVM, Btrfs).  
- Plan for business continuity.

---

## 1. Backup Fundamentals

### 1.1 Backup Types

| Type | Description | Pros | Cons | Recovery Time |
|------|-------------|------|------|---------------|
| **Full** | Complete copy of all data | Simple, fast restore | Large storage, slow | Fast |
| **Incremental** | Only changed since last backup | Minimal storage/time | Complex restore (need all) | Slowest |
| **Differential** | Changed since last full | Balance storage/restore | Growing size | Moderate |
| **Snapshot** | Point-in-time copy | Very fast, space-efficient | Needs storage features | Fastest |
| **Mirror** | Real-time sync | Always current | No history, hardware cost | Instant |

### 1.2 Backup Strategy (3-2-1 Rule)

- **3** copies of data
- **2** different media types
- **1** offsite copy

**Example:**
- Original: Production server
- Copy 1: Local backup drive
- Copy 2: Network storage
- Copy 3: Cloud storage (offsite)

### 1.3 What to Backup

**Critical directories:**
```bash
/home/                           # user data
/etc/                            # configurations
/var/www/                        # web content
/var/lib/mysql/                  # databases (use dump, not files!)
/root/                           # root user data
/opt/                            # third-party apps
/srv/                            # service data
```

**Don't backup:**
```bash
/proc/                           # virtual filesystem
/sys/                            # virtual filesystem
/dev/                            # device files
/tmp/                            # temporary files
/run/                            # runtime data
```

---

## 2. tar – Tape Archive

### 2.1 Creating Archives

```bash
# Basic tar
tar -cvf backup.tar /home/user   # create archive
# c = create, v = verbose, f = file

# Compressed archives
tar -czf backup.tar.gz /home/user    # gzip (fast, moderate compression)
tar -cjf backup.tar.bz2 /home/user   # bzip2 (slow, better compression)
tar -cJf backup.tar.xz /home/user    # xz (slowest, best compression)

# Auto-detect compression by extension
tar -czf backup.tar.gz /home/user
tar -caf backup.tar.gz /home/user    # auto-compress (same)

# Exclude files
tar -czf backup.tar.gz --exclude='*.log' --exclude='temp/*' /home/user

# Exclude from file
echo "*.log" > exclude.txt
echo "temp/*" >> exclude.txt
tar -czf backup.tar.gz --exclude-from=exclude.txt /home/user

# Preserve permissions
tar -czpf backup.tar.gz /home/user   # p = preserve permissions

# Add timestamp to filename
tar -czf backup-$(date +%Y%m%d).tar.gz /home/user
```

### 2.2 Extracting Archives

```bash
# List contents
tar -tzf backup.tar.gz           # list gzip archive
tar -tf backup.tar               # list uncompressed

# Extract
tar -xzf backup.tar.gz           # extract all
tar -xzf backup.tar.gz -C /restore/  # extract to directory

# Extract specific files
tar -xzf backup.tar.gz home/user/file.txt

# Extract to stdout
tar -xzf backup.tar.gz -O file.txt > output.txt
```

### 2.3 Incremental Backups with tar

```bash
# First: Full backup
tar -czf full-backup-$(date +%Y%m%d).tar.gz -g snapshot.snar /home/user

# Later: Incremental backups
tar -czf inc-backup-$(date +%Y%m%d).tar.gz -g snapshot.snar /home/user

# Restore: Apply full, then all incrementals in order
tar -xzf full-backup-20230101.tar.gz -g /dev/null
tar -xzf inc-backup-20230102.tar.gz -g /dev/null
tar -xzf inc-backup-20230103.tar.gz -g /dev/null
```

---

## 3. rsync – Remote Sync

### 3.1 Basic Usage

```bash
# Local copy
rsync -av /source/ /destination/
# a = archive (preserve permissions, timestamps, etc.)
# v = verbose

# Common options
rsync -avz /source/ /destination/    # z = compress during transfer
rsync -avh /source/ /destination/    # h = human-readable sizes
rsync -av --progress /source/ /destination/  # show progress
rsync -av --dry-run /source/ /destination/   # test run

# Important: Trailing slash matters!
rsync -av /source/ /dest/        # copies contents OF source to dest
rsync -av /source /dest/         # copies source directory INTO dest
```

### 3.2 Remote Backup with rsync

```bash
# Push to remote
rsync -avz /local/path/ user@remote:/remote/path/

# Pull from remote
rsync -avz user@remote:/remote/path/ /local/path/

# Use SSH key
rsync -avz -e "ssh -i ~/.ssh/id_rsa" /local/ user@remote:/backup/

# Custom SSH port
rsync -avz -e "ssh -p 2222" /local/ user@remote:/backup/
```

### 3.3 Advanced rsync

**Exclude files:**
```bash
rsync -av --exclude='*.log' --exclude='temp/' /source/ /dest/

# Exclude from file
rsync -av --exclude-from=exclude.txt /source/ /dest/
```

**Delete on destination:**
```bash
rsync -av --delete /source/ /dest/   # mirror: delete extra files
rsync -av --delete-after /source/ /dest/  # delete after transfer
```

**Bandwidth limit:**
```bash
rsync -av --bwlimit=1000 /source/ /dest/  # 1000 KB/s
```

**Backup script example:**
```bash
#!/bin/bash
# backup.sh

SOURCE="/home/user/"
DEST="/backup/user/"
LOGFILE="/var/log/backup.log"

rsync -avz \
    --delete \
    --exclude='*.tmp' \
    --exclude='Cache/' \
    --log-file="$LOGFILE" \
    "$SOURCE" "$DEST"

if [ $? -eq 0 ]; then
    echo "$(date): Backup successful" >> "$LOGFILE"
else
    echo "$(date): Backup failed" >> "$LOGFILE"
    exit 1
fi
```

### 3.4 rsync for Incremental Backups

```bash
# Daily backups with hardlinks (saves space)
#!/bin/bash
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backup"
LATEST="$BACKUP_DIR/latest"

rsync -av --delete \
    --link-dest="$LATEST" \
    /home/user/ \
    "$BACKUP_DIR/$DATE/"

# Update latest symlink
rm -f "$LATEST"
ln -s "$DATE" "$LATEST"
```

---

## 4. dd – Disk Imaging

### 4.1 Disk/Partition Cloning

```bash
# Clone entire disk
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress
# if = input file (source)
# of = output file (destination)
# bs = block size (4M is good for performance)
# status=progress = show progress

# Clone partition
sudo dd if=/dev/sda1 of=/dev/sdb1 bs=4M status=progress

# Create disk image file
sudo dd if=/dev/sda of=/backup/disk.img bs=4M status=progress

# Compress on-the-fly
sudo dd if=/dev/sda bs=4M status=progress | gzip > /backup/disk.img.gz

# Restore from compressed image
gunzip -c /backup/disk.img.gz | sudo dd of=/dev/sda bs=4M status=progress
```

### 4.2 Partition Table Backup

```bash
# Backup MBR (first 512 bytes)
sudo dd if=/dev/sda of=mbr-backup.img bs=512 count=1

# Restore MBR
sudo dd if=mbr-backup.img of=/dev/sda bs=512 count=1

# Backup GPT partition table
sudo sgdisk --backup=gpt-backup.img /dev/sda

# Restore GPT
sudo sgdisk --load-backup=gpt-backup.img /dev/sda
```

**Warning:** `dd` is dangerous! Double-check `if=` and `of=` before running.

---

## 5. Database Backups

### 5.1 MySQL/MariaDB

**Logical backup (SQL dump):**
```bash
# Single database
mysqldump -u root -p dbname > dbname-backup.sql

# All databases
mysqldump -u root -p --all-databases > all-databases.sql

# With routines and triggers
mysqldump -u root -p --all-databases --routines --triggers > full-backup.sql

# Compressed
mysqldump -u root -p dbname | gzip > dbname-backup.sql.gz

# Restore
mysql -u root -p dbname < dbname-backup.sql
gunzip < dbname-backup.sql.gz | mysql -u root -p dbname
```

**Automated backup script:**
```bash
#!/bin/bash
# mysql-backup.sh

USER="backup_user"
PASS="password"
BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

mysqldump -u $USER -p$PASS --all-databases | gzip > "$BACKUP_DIR/all-databases-$DATE.sql.gz"

# Keep only last 7 days
find "$BACKUP_DIR" -type f -mtime +7 -delete

# Cron: Daily at 2 AM
# 0 2 * * * /usr/local/bin/mysql-backup.sh
```

### 5.2 PostgreSQL

```bash
# Single database
pg_dump dbname > dbname-backup.sql
pg_dump -U postgres dbname | gzip > dbname-backup.sql.gz

# All databases
pg_dumpall > all-databases.sql

# Restore
psql dbname < dbname-backup.sql
```

---

## 6. Snapshot Technologies

### 6.1 LVM Snapshots

```bash
# Create snapshot (see Linux 11 for details)
sudo lvcreate -L 5G -s -n lv_mysql_snap /dev/vg_data/lv_mysql

# Mount snapshot
sudo mkdir /mnt/snap
sudo mount -o ro /dev/vg_data/lv_mysql_snap /mnt/snap

# Backup from snapshot
sudo tar -czf /backup/mysql-$(date +%Y%m%d).tar.gz -C /mnt/snap .

# Remove snapshot
sudo umount /mnt/snap
sudo lvremove /dev/vg_data/lv_mysql_snap
```

### 6.2 Btrfs Snapshots

```bash
# Create snapshot
sudo btrfs subvolume snapshot /home /home-snapshot-$(date +%Y%m%d)

# List snapshots
sudo btrfs subvolume list /

# Delete snapshot
sudo btrfs subvolume delete /home-snapshot-20230101

# Restore from snapshot
sudo btrfs subvolume delete /home
sudo btrfs subvolume snapshot /home-snapshot-20230101 /home
```

### 6.3 ZFS Snapshots

```bash
# Create snapshot
sudo zfs snapshot tank/data@backup-$(date +%Y%m%d)

# List snapshots
sudo zfs list -t snapshot

# Restore (rollback)
sudo zfs rollback tank/data@backup-20230101

# Clone snapshot (writable copy)
sudo zfs clone tank/data@backup-20230101 tank/data-clone

# Destroy snapshot
sudo zfs destroy tank/data@backup-20230101
```

---

## 7. Automated Backup Solutions

### 7.1 Bacula (Enterprise Backup)

**Features:**
- Client-server architecture
- Network backups
- Advanced scheduling
- Catalog database

**Components:**
- Director: Manages backups
- Storage Daemon: Writes to media
- File Daemon: Installed on clients
- Console: Admin interface

### 7.2 Duplicity (Encrypted Backups)

```bash
# Install
sudo apt install duplicity

# Backup to local directory
duplicity /home/user file:///backup/user

# Backup to S3
duplicity /home/user s3://s3.amazonaws.com/bucket-name

# Incremental backup (automatic)
duplicity /home/user file:///backup/user

# Restore
duplicity restore file:///backup/user /restore/

# List backups
duplicity collection-status file:///backup/user
```

### 7.3 Borgbackup (Deduplication)

```bash
# Install
sudo apt install borgbackup

# Initialize repository
borg init --encryption=repokey /path/to/repo

# Create backup
borg create /path/to/repo::backup-$(date +%Y%m%d) /home/user

# List archives
borg list /path/to/repo

# Restore
borg extract /path/to/repo::backup-20230101

# Prune old backups
borg prune /path/to/repo --keep-daily=7 --keep-weekly=4 --keep-monthly=6
```

### 7.4 restic (Modern Backup)

```bash
# Install
sudo apt install restic

# Initialize repository
restic init --repo /backup/repo

# Backup
restic -r /backup/repo backup /home/user

# List snapshots
restic -r /backup/repo snapshots

# Restore
restic -r /backup/repo restore latest --target /restore/

# Forget old snapshots
restic -r /backup/repo forget --keep-daily 7 --keep-weekly 4 --prune
```

---

## 8. Disaster Recovery Procedures

### 8.1 System Recovery Plan

**1. Prepare recovery media:**
```bash
# Create bootable USB with SystemRescue or Ubuntu Live
# Download ISO, create with:
sudo dd if=ubuntu-22.04-live-server.iso of=/dev/sdb bs=4M status=progress
```

**2. Document system:**
```bash
# Save package list
dpkg --get-selections > package-list.txt      # Debian/Ubuntu
rpm -qa > package-list.txt                    # RHEL/Fedora

# Save partition layout
sudo fdisk -l > partitions.txt
sudo blkid > blkid.txt

# Save network config
ip addr > network-config.txt
```

**3. Recovery steps:**
```bash
# 1. Boot from recovery media
# 2. Partition disks (matching original)
# 3. Mount filesystems
# 4. Restore from backup
# 5. Reinstall bootloader
# 6. Reboot
```

### 8.2 GRUB Recovery

```bash
# Boot into GRUB rescue mode, then:
grub rescue> ls                              # list partitions
grub rescue> set root=(hd0,1)                # set boot partition
grub rescue> set prefix=(hd0,1)/boot/grub
grub rescue> insmod normal
grub rescue> normal

# After booting, reinstall GRUB:
sudo update-grub
sudo grub-install /dev/sda
```

### 8.3 Single User Mode

```bash
# At GRUB menu:
# 1. Press 'e' to edit boot entry
# 2. Find line starting with 'linux'
# 3. Add 'single' or 'init=/bin/bash' at the end
# 4. Press Ctrl+X or F10 to boot

# Mount root as read-write
mount -o remount,rw /

# Reset root password
passwd root

# Reboot
exec /sbin/init
```

---

## 9. Testing Backups

### 9.1 Verification

```bash
# Test tar archive integrity
tar -tzf backup.tar.gz > /dev/null
echo $?                          # 0 = success

# Test restore to temp location
mkdir /tmp/restore-test
tar -xzf backup.tar.gz -C /tmp/restore-test
diff -r /original /tmp/restore-test

# Test rsync dry run
rsync -avn /backup/ /restore/    # n = dry-run

# MD5 checksums
md5sum backup.tar.gz > backup.md5
md5sum -c backup.md5             # verify
```

### 9.2 Recovery Drills

**Schedule regular tests:**
- Monthly: Restore random files
- Quarterly: Full system restore to VM
- Annually: Complete disaster recovery drill

**Document:**
- Recovery time objective (RTO)
- Recovery point objective (RPO)
- Actual recovery times
- Issues encountered

---

## 10. Cloud Backup Solutions

### 10.1 rclone (Cloud Sync)

```bash
# Install
sudo apt install rclone

# Configure (interactive)
rclone config

# Sync to cloud
rclone sync /local/path remote:bucket/path

# Backup script
rclone sync /home/user gdrive:backup/user --exclude='*.tmp'
```

### 10.2 AWS S3

```bash
# Install AWS CLI
sudo apt install awscli

# Configure
aws configure

# Sync to S3
aws s3 sync /local/path s3://bucket-name/path/

# Backup script
aws s3 sync /home/user s3://my-backup-bucket/user/ --delete
```

---

## 11. Practice Exercises

1. **Basic backups:**
   - Create tar archive of /etc
   - Extract specific file from archive
   - Create compressed incremental backups

2. **rsync:**
   - Set up daily rsync backup with cron
   - Test recovery from rsync backup
   - Implement rotation (keep 7 days)

3. **Database:**
   - Create MySQL dump
   - Automate with cron
   - Test restore to new database

4. **Snapshots:**
   - Create LVM snapshot
   - Backup from snapshot
   - Test restore procedure

5. **Disaster recovery:**
   - Document full system
   - Create recovery plan
   - Test restore to VM

**Congratulations!** You've completed the comprehensive Linux learning materials covering beginner to advanced topics. Continue practicing and exploring!

---

## Recommended Next Steps

1. **Certifications:**
   - CompTIA Linux+ or LPIC-1 (fundamentals)
   - RHCSA/RHCE (enterprise Linux)
   - LFCS/LFCE (Linux Foundation)

2. **Specializations:**
   - Kubernetes & container orchestration
   - Cloud platforms (AWS, Azure, GCP)
   - DevOps & CI/CD pipelines
   - Security & penetration testing

3. **Practice:**
   - Set up home lab
   - Contribute to open source
   - Build personal projects
   - Join Linux communities

Happy Learning! 🐧
