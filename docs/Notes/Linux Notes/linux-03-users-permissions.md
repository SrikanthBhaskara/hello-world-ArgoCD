# Linux 03 – Users, Groups, Permissions & sudo

## 0. Goal of This Note

- Understand user and group concepts.  
- Read and change file permissions.  
- Use `sudo` safely and understand why root is powerful.

---

## 1. Users & Groups

Every process runs as a **user** and belongs to one or more **groups**.

Check your identity:

```bash
whoami
id
groups
```

Important files:

- `/etc/passwd` – basic user info (name, UID, default shell, home).  
- `/etc/group` – group definitions.  
- `/etc/shadow` – password hashes (root-only).

View them:

```bash
cat /etc/passwd
cat /etc/group
sudo cat /etc/shadow   # only with sudo/root
```

User IDs (UIDs):

- 0 – root (superuser).  
- 1–999 (or similar) – system users.  
- 1000+ – normal logins (on many distros).

---

## 2. File Ownership & Permissions

Use `ls -l` to inspect permissions:

```bash
ls -l
-rwxr-x--- 1 alice dev  4096 Feb  1 12:00 script.sh
```

Fields:

- Column 1: `-rwxr-x---`
  - 1st char: type (`-` file, `d` directory, `l` symlink…).  
  - Next 3: owner perms (rwx).  
  - Next 3: group perms (r-x).  
  - Last 3: others perms (---).
- Column 3: owning user (`alice`).  
- Column 4: owning group (`dev`).

Permission bits:

- `r` – read.  
- `w` – write.  
- `x` – execute (or “can enter” for directories).

---

## 3. chmod – Change Permissions

Two styles: symbolic and numeric.

### 3.1 Symbolic Mode

```bash
chmod u+x script.sh       # add execute for user
chmod g-w file.txt        # remove write from group
chmod o-r file.txt        # remove read from others
chmod a+r file.txt        # give read to everyone
```

- `u` – user (owner).  
- `g` – group.  
- `o` – others.  
- `a` – all (u,g,o).

Operators:

- `+` – add.  
- `-` – remove.  
- `=` – set exactly.

### 3.2 Numeric Mode

Each group of 3 bits is a number:

- `r` = 4, `w` = 2, `x` = 1.  
- Add them for each of user, group, others.

Examples:

- `7` (4+2+1) = `rwx`.  
- `6` (4+2) = `rw-`.  
- `5` (4+1) = `r-x`.  
- `4` = `r--`.

Typical modes:

```bash
chmod 755 script.sh   # rwx r-x r-x
chmod 644 file.txt    # rw- r-- r--
chmod 700 secret      # rwx --- --- (only owner)
```

---

## 4. chown & chgrp – Change Ownership

Usually only root can change ownership.

```bash
sudo chown bob file.txt         # change owner to bob
sudo chown bob:dev file.txt     # change owner and group
sudo chgrp dev shared.txt       # change group only
```

Avoid using `chown` recursively on entire system trees unless you know exactly what you’re doing – it can break the system.

---

## 5. Special Permission Bits (Overview)

Advanced, but important for real admin work:

- **setuid (s)** on files: run as file owner.  
- **setgid (s)** on files/dirs: run as group / new files inherit group.  
- **sticky bit (t)** on dirs: only owner can delete own files.

Examples you already use:

- `/usr/bin/passwd` often has setuid so normal users can change their password.  
- `/tmp` has sticky bit so users can’t delete each other’s files.

Check with `ls -l`:

- `-rwsr-xr-x` – setuid bit (`s` instead of `x` on user).  
- `drwxrws---` – setgid on directory.  
- `drwxrwxrwt` – sticky bit on directory (note `t`).

---

## 6. sudo & root – Admin Privileges

### 6.1 Why sudo?

- Direct `root` login is risky; any mistake can break the system.  
- `sudo` lets normal users run specific commands with elevated rights, logged.

Use:

```bash
sudo command         # run once as root
sudo -i              # root shell (if allowed)
```

You’ll be prompted for **your** password, not root’s.

### 6.2 sudoers & Groups

Config file:

- `/etc/sudoers` – **never** edit directly; use `visudo`.  
- Usually membership in `sudo` or `wheel` group grants sudo rights.

Check your groups:

```bash
groups
```

If you see `sudo` or `wheel`, you probably can use `sudo`.

---

## 7. Creating & Managing Users (Admin)

Typical commands (may vary by distro):

```bash
sudo adduser alice           # debian/ubuntu-style
sudo useradd -m alice        # low-level (may need passwd afterwards)

sudo passwd alice            # set/change password
sudo usermod -aG sudo alice  # add alice to sudo group (Ubuntu)

sudo deluser alice           # remove user (Debian/Ubuntu)
sudo userdel -r alice        # low-level delete + remove home
```

Group management:

```bash
sudo groupadd dev
sudo usermod -aG dev alice
sudo gpasswd -d alice dev
```

After changing group membership, user may need to log out and back in to see changes.

---

## 8. Practical Permission Patterns

### 8.1 Shared Project Directory

Goal: two users share files in `/srv/project` so that:

- Both can read/write each other’s files.  
- New files automatically belong to a shared group.

Steps (high-level):

1. Create group `project`.  
2. Add users to it.  
3. Set group ownership and permissions.  
4. Use setgid bit.

Example:

```bash
sudo groupadd project
sudo usermod -aG project alice
sudo usermod -aG project bob

sudo mkdir -p /srv/project
sudo chown root:project /srv/project
sudo chmod 2775 /srv/project   # 2 = setgid bit
```

Now new files in `/srv/project` will belong to group `project`.

### 8.2 Private Directories

For private stuff:

```bash
chmod 700 ~/private
```

- Only you (owner) can read/write/execute.

---

## 9. Practice Tasks

1. Inspection:
   - Run `id` and write down your UID, primary GID, and groups.  
   - Check the permissions of your home directory and one other directory.
2. Permissions:
   - Create `perms-demo.txt`.  
   - Change its mode to `600`, `644`, `755`, and watch how `ls -l` changes.  
   - Make a directory `secret` (mode `700`) and try to list it from another user account (if available).
3. sudo:
   - If your account has sudo, run `sudo -v` (update credentials).  
   - Check `sudo whoami` (should print `root`).  
   - Use `sudo` to read `/etc/shadow` (then close, don’t leave it around).

Next: **Linux 04 – Processes, Jobs & systemd**.
