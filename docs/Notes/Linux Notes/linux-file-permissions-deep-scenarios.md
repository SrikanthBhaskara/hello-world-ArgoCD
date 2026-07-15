# Linux File Permissions Deep Scenarios

## 1. Why File Permissions Matter So Much

Linux permission issues are some of the most common real-world failures in:
- application startup
- log writing
- SSH access
- cron execution
- script automation
- shared directory usage
- secret and certificate handling

Good interview line:

"Permissions are both a security boundary and an operational dependency. If they are too open, you create risk. If they are too restrictive, the application fails."

## 2. Core Permission Mental Model

Every file or directory has:
- owner
- group
- permission bits for owner, group, and others

The basic permission types are:
- `r` for read
- `w` for write
- `x` for execute

For directories:
- read means list contents
- write means create, delete, or rename entries
- execute means enter or traverse the directory

That directory behavior is often where interview questions get deeper.

## 3. Scenario: Application Cannot Write Log File

### Situation

The application starts but fails when writing logs under `/var/log/myapp`.

### What To Check

- file ownership
- directory ownership
- whether the app user has write permission
- whether parent directory traversal is allowed
- whether log rotation recreated files with wrong ownership

### Strong Answer

"I would check not only the file permission but also the directory permission and ownership chain. Many write failures happen because the application can see the filename but cannot traverse or write into the directory properly."

## 4. Scenario: Script Works for Root but Fails for Service User

### Situation

Running a script with `sudo` works, but the same script fails under `systemd` or cron.

### What To Check

- script owner and execute bit
- directory traversal permissions
- access to config files
- access to output paths
- access to dependent binaries or mounted paths

### Strong Answer

"When something works as root but fails as the service user, I suspect a permissions or environment difference first. Root can hide access problems that will appear immediately under real runtime identity."

## 5. Scenario: User Can Read a File but Cannot Enter the Directory

### Situation

The file permissions look correct, but access still fails.

### Explanation

If the directory lacks execute permission for that user or group, the file may still be unreachable.

### Strong Answer

"Directory execute permission is required for path traversal. So even if the file itself is readable, the user still cannot reach it if the directory path is not traversable."

## 6. Scenario: File Can Be Viewed but Not Modified

### Situation

A user can open a file but cannot save changes.

### What To Check

- file write permission
- file owner and group
- whether the file is immutable
- whether the directory allows replacement or rename behavior

### Command Checks

```bash
ls -l file.txt
lsattr file.txt
```

### Strong Answer

"I would verify write permission first, then check ownership and any immutable attribute because Linux permission issues are not always only about the basic `rwx` bits."

## 7. Scenario: Shared Directory for Multiple Users

### Situation

Multiple users need to collaborate in one directory, but ownership becomes inconsistent.

### Better Design

- use a shared group
- set directory group ownership correctly
- use the setgid bit on the directory

### Example

```bash
chgrp devteam /shared/project
chmod 2775 /shared/project
```

### Why This Matters

The setgid bit on a directory helps new files inherit the directory's group, which keeps collaboration cleaner.

## 8. Scenario: SSH Key Authentication Fails Due to Permissions

### Situation

SSH public key auth is configured, but login still fails.

### What To Check

- `~/.ssh` permissions
- `authorized_keys` permissions
- file ownership
- parent home directory write permissions

### Common Expectations

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Strong Answer

"SSH is very sensitive to insecure permission settings. If key files or `.ssh` directories are too open, SSH may reject them to avoid unsafe trust paths."

## 9. Scenario: Cron Job Cannot Execute Script

### Situation

The script exists, but cron does not run it successfully.

### What To Check

- execute bit on script
- ownership
- access to files used by the script
- directory traversal
- whether interpreter path is accessible

### Strong Answer

"For cron failures I check both execution rights and runtime file access, because cron often exposes permission and path assumptions that are hidden in interactive shell execution."

## 10. Scenario: Web Server Gets Permission Denied for Static Files

### Situation

Nginx or Apache returns permission denied even though the file is present.

### What To Check

- file read permission
- directory execute permission
- parent path traversal
- correct web server user ownership or group access
- SELinux or MAC layer if enabled

### Strong Answer

"A web server usually needs read permission on the file and execute permission through every directory in the path. If either is missing, the content may exist but still be inaccessible."

## 11. Scenario: New Files Get Wrong Group Ownership

### Situation

Team members create files in a shared directory, but group ownership varies by user.

### Fix Direction

Use:
- shared group ownership
- setgid directory bit

### Example

```bash
chmod 2775 /shared/teamdir
```

### Operational Value

This avoids access surprises in shared operational directories.

## 12. Special Permission Bits

### setuid

Runs the executable with the file owner's privileges.

### setgid

Runs with the file group's privileges or enforces group inheritance on directories.

### sticky bit

Commonly used on shared directories like `/tmp` so users cannot delete each other's files.

### Example

```bash
ls -ld /tmp
```

You often see:

```text
drwxrwxrwt
```

## 13. Scenario: Users Can Delete Each Other's Files in Shared Directory

### Situation

A shared writable directory allows unintended deletion.

### Better Design

Use sticky bit where appropriate.

### Example

```bash
chmod +t /shared/dropbox
```

### Strong Answer

"The sticky bit is useful on shared writable directories when users need to create files there but should not be able to remove each other's content."

## 14. ACLs Matter Too

Traditional Unix permissions are sometimes not flexible enough.

Access Control Lists help when:
- one extra user needs access
- group ownership alone is not enough
- shared directory rules need more precision

### Example

```bash
setfacl -m u:appuser:rwx /data/app
getfacl /data/app
```

### Strong Answer

"ACLs are useful when standard owner-group-other permissions are too coarse for the access model required."

## 15. Scenario: Deployment Succeeds but App Cannot Read Config

### Situation

The config file exists, but the application fails on startup.

### What To Check

- owner/group of config
- read permission for service user
- directory traversal permission
- whether config was created by root during deployment

### Strong Answer

"This often happens when deployment automation creates config as root, but the runtime service uses a non-root account. I compare deployment identity and runtime identity directly."

## 16. Scenario: Secret File Is Too Open

### Situation

A credential or private key file is readable by too many users.

### Risk

- credential exposure
- failed security checks
- service rejection in some tools like SSH

### Fix Direction

Restrict:
- owner
- permissions
- parent directory access

### Good Practice

```bash
chmod 600 secret.key
```

## 17. Commands You Should Know for Permission Troubleshooting

```bash
ls -l
ls -ld /path/to/dir
namei -l /path/to/file
id username
stat file.txt
getfacl file.txt
lsattr file.txt
```

### Why `namei -l` Is Strong

It shows permissions across each directory component in a path, which is extremely useful for traversal problems.

## 18. Strong Interview Statements

- "File access problems often come from directory traversal permission, not only file permission."
- "If something works for root but not for the service user, I suspect identity or permission mismatch first."
- "Shared directories often need group ownership discipline and sometimes the setgid bit."
- "Sticky bit and ACLs solve different access problems than simple `chmod`."
- "Permission troubleshooting should include owner, group, bits, path traversal, and sometimes SELinux or file attributes."
