# Linux 22 – SELinux & Mandatory Access Control (MAC)

## 0. Goal of This Note

- Understand Mandatory Access Control (MAC) vs Discretionary Access Control (DAC).
- Master SELinux modes, contexts, and policies.
- Learn to troubleshoot SELinux denials with audit logs.
- Configure SELinux booleans and create custom policies.
- Compare SELinux with AppArmor.

---

## 1. Access Control Models

### 1.1 DAC vs MAC

**DAC (Discretionary Access Control)**:
- **Standard Linux permissions** (rwx, chmod, chown)
- **Owner controls access** to their files
- Problem: If a process is compromised, it has all the owner's permissions
- Example: Apache running as `www-data` can access all files owned by `www-data`

**MAC (Mandatory Access Control)**:
- **System-wide security policy** that users cannot override
- **Every process and file has a security context**
- Access decisions based on security policy rules, not ownership
- Even root cannot bypass MAC without changing the policy
- Example: Apache can only access files labeled as `httpd_sys_content_t`

### 1.2 SELinux Overview

**SELinux (Security-Enhanced Linux)**:
- Developed by NSA, integrated into Linux kernel
- Provides MAC enforcement
- Default in RHEL, CentOS, Fedora, Rocky Linux
- Labels every process and file with a security context
- Policy rules define what labeled processes can access

**SELinux Subjects and Objects**:
- **Subject**: Process (e.g., Apache, SSH daemon)
- **Object**: File, directory, port, socket
- **Policy**: Rules defining subject access to objects

---

## 2. SELinux Modes

### 2.1 Three Operating Modes

**1. Enforcing**:
```bash
# SELinux actively enforces security policy
# Denies access based on policy rules
# Logs all denials to /var/log/audit/audit.log
```

**2. Permissive**:
```bash
# SELinux policy loaded but NOT enforced
# Logs what WOULD be denied (for testing)
# Useful for troubleshooting and policy development
```

**3. Disabled**:
```bash
# SELinux completely turned off
# No policy loaded or enforced
# Requires reboot to re-enable
```

### 2.2 Check and Change SELinux Mode

**Check current mode:**
```bash
getenforce                          # Current mode
sestatus                            # Detailed status
sestatus -v                         # Verbose with contexts
```

**Output example:**
```
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

**Temporarily change mode** (until reboot):
```bash
sudo setenforce 0                   # Permissive
sudo setenforce 1                   # Enforcing
```

**Permanently change mode** (requires reboot):
```bash
# Edit /etc/selinux/config
sudo vi /etc/selinux/config

# Change SELINUX= line
SELINUX=enforcing    # or permissive, or disabled

# Reboot
sudo reboot
```

**Warning**: Changing from disabled → enforcing requires full filesystem relabeling:
```bash
# After changing config from disabled to enforcing
sudo touch /.autorelabel
sudo reboot
# System will relabel all files on next boot (takes time)
```

---

## 3. SELinux Contexts (Labels)

### 3.1 Understanding Context Format

Every file, process, and object has a context:
```
user:role:type:level
```

**Example file context:**
```bash
ls -Z /var/www/html/index.html
# Output:
system_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html
│         │        │                   │
│         │        │                   └─ MLS level (multi-level security)
│         │        └───────────────────── Type (most important)
│         └────────────────────────────── Role
└──────────────────────────────────────── User
```

**Example process context:**
```bash
ps -eZ | grep httpd
# Output:
system_u:system_r:httpd_t:s0       1234  ?  00:00:05 httpd
```

### 3.2 SELinux Context Components

**User** (usually `system_u` or `unconfined_u`):
- Maps Linux user to SELinux user
- Rarely modified directly

**Role** (usually `object_r` for files, `system_r` for daemons):
- Intermediate layer in RBAC (Role-Based Access Control)
- Links users to types

**Type** (most critical):
- **Type Enforcement**: Core of SELinux policy
- Process type: `httpd_t`, `sshd_t`, `mysqld_t`
- File type: `httpd_sys_content_t`, `ssh_home_t`
- Policy rules specify which process types can access which file types

**Level** (MLS - Multi-Level Security):
- Used in high-security environments (government)
- Format: `s0` or `s0:c0.c1023`
- Usually not needed in standard setups

### 3.3 View SELinux Contexts

**Files and directories:**
```bash
ls -Z /etc/httpd/conf/httpd.conf
ls -lZ /var/www/html/
find /var/www -Z                    # recursive
```

**Processes:**
```bash
ps -eZ                              # all processes
ps -eZ | grep httpd                 # specific service
ps auxZ                             # detailed with contexts
```

**Ports:**
```bash
semanage port -l                    # list all port contexts
semanage port -l | grep http        # HTTP ports
```

**Users:**
```bash
semanage login -l                   # Linux user → SELinux user mapping
semanage user -l                    # SELinux users
```

### 3.4 Set SELinux Contexts

**Temporarily change context** (lost on relabel):
```bash
sudo chcon -t httpd_sys_content_t /var/www/html/index.html
sudo chcon -R -t httpd_sys_content_t /var/www/html/
sudo chcon --reference=/var/www/html/file1.html /var/www/html/file2.html
```

**Permanently change context**:
```bash
# Use semanage to set policy (survives relabel)
sudo semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
sudo restorecon -Rv /web            # apply the policy
```

**Restore default contexts:**
```bash
sudo restorecon -v /var/www/html/index.html
sudo restorecon -Rv /var/www/html/  # recursive
```

**Relabel entire filesystem:**
```bash
sudo touch /.autorelabel
sudo reboot
```

---

## 4. SELinux Policies

### 4.1 Policy Types

**Targeted** (default on RHEL/CentOS):
- Confines only specific high-risk services (Apache, SSH, MySQL, etc.)
- Most processes run unconfined
- Good balance of security and usability

**MLS (Multi-Level Security)**:
- Military-grade security with classification levels
- Very restrictive
- Rarely used outside government

**Minimum**:
- Minimal confinement
- Seldom used

Check current policy:
```bash
sestatus | grep "Loaded policy"
# Output: Loaded policy name: targeted
```

### 4.2 SELinux Policy Packages

Policies are modular:
```bash
# List installed policy modules
semodule -l

# Install a policy module
sudo semodule -i mypolicy.pp

# Remove a policy module
sudo semodule -r mypolicy

# Disable a policy module
sudo semodule -d mypolicy

# Enable a policy module
sudo semodule -e mypolicy
```

### 4.3 SELinux Booleans

**Booleans** allow runtime policy customization without recompiling.

**List all booleans:**
```bash
getsebool -a                        # all booleans
getsebool -a | grep httpd           # HTTP-related
semanage boolean -l                 # with descriptions
```

**Common Apache booleans:**
```bash
httpd_can_network_connect --> off   # Allow HTTP to connect to network
httpd_enable_homedirs --> off       # Serve files from home dirs
httpd_use_nfs --> off               # Serve files from NFS
```

**Get boolean value:**
```bash
getsebool httpd_can_network_connect
# Output: httpd_can_network_connect --> off
```

**Set boolean temporarily:**
```bash
sudo setsebool httpd_can_network_connect on
```

**Set boolean permanently:**
```bash
sudo setsebool -P httpd_can_network_connect on
# -P = persistent across reboots
```

**Real-world example**:
```bash
# Problem: Apache can't connect to database
# Solution: Enable network connectivity
sudo setsebool -P httpd_can_network_connect_db on

# Problem: Apache can't read NFS-mounted files
sudo setsebool -P httpd_use_nfs on
```

---

## 5. Troubleshooting SELinux Denials

### 5.1 Audit Logs

SELinux denials are logged to:
```bash
/var/log/audit/audit.log            # auditd log
/var/log/messages                   # if auditd not running
journalctl -xe                      # systemd journal
```

**Denial log example:**
```
type=AVC msg=audit(1612345678.123:456): avc:  denied  { write } for  pid=1234
comm="httpd" name="index.html" dev="sda1" ino=789012
scontext=system_u:system_r:httpd_t:s0
tcontext=system_u:object_r:user_home_t:s0
tclass=file permissive=0
```

**Key fields:**
- `denied { write }`: Denied action
- `comm="httpd"`: Process name
- `scontext=...httpd_t`: Source context (process)
- `tcontext=...user_home_t`: Target context (file)
- `tclass=file`: Object class

### 5.2 Troubleshooting Tools

**ausearch** - Search audit logs:
```bash
# Recent denials
sudo ausearch -m avc -ts recent

# Denials in last hour
sudo ausearch -m avc -ts today

# Denials for specific service
sudo ausearch -m avc -c httpd

# Denials since boot
sudo ausearch -m avc -ts boot
```

**audit2why** - Explain why denial happened:
```bash
sudo ausearch -m avc -ts recent | audit2why

# Output example:
type=AVC msg=audit(...): avc:  denied  { write } ...
    Was caused by:
        Missing type enforcement (TE) allow rule.
        You can use audit2allow to generate a loadable module to allow this access.
```

**audit2allow** - Generate policy from denials:
```bash
# Show what rules would fix denials
sudo ausearch -m avc -ts recent | audit2allow

# Output:
#============= httpd_t ==============
allow httpd_t user_home_t:file write;

# Generate a policy module
sudo ausearch -m avc -ts recent | audit2allow -M mypolicy
# Creates mypolicy.te (source) and mypolicy.pp (compiled)

# Install the policy module
sudo semodule -i mypolicy.pp
```

**sealert** (requires setroubleshoot):
```bash
# Install on RHEL/CentOS
sudo dnf install setroubleshoot-server

# Analyze denials with suggestions
sudo sealert -a /var/log/audit/audit.log

# Real-time monitoring
sudo tail -f /var/log/messages | grep sealert
```

### 5.3 Common Troubleshooting Workflow

**Step 1: Reproduce the problem**
```bash
# Example: Apache can't read /web/index.html
curl http://localhost/index.html
# Error: 403 Forbidden
```

**Step 2: Check SELinux denials**
```bash
sudo ausearch -m avc -ts recent
# Or
sudo grep "denied" /var/log/audit/audit.log | tail -n 20
```

**Step 3: Analyze with audit2why**
```bash
sudo ausearch -m avc -ts recent | audit2why
```

**Step 4: Choose solution**

**Option A: Fix file context** (most common):
```bash
ls -Z /web/index.html
# Wrong: system_u:object_r:default_t:s0

# Correct it:
sudo semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
sudo restorecon -Rv /web
```

**Option B: Enable boolean**:
```bash
# If audit2why suggests a boolean
sudo setsebool -P httpd_enable_homedirs on
```

**Option C: Create custom policy** (last resort):
```bash
sudo ausearch -m avc -ts recent | audit2allow -M myhttp
sudo semodule -i myhttp.pp
```

**Step 5: Test**
```bash
curl http://localhost/index.html
# Should work now
```

---

## 6. Real-World Scenarios

### 6.1 Apache Serving Custom Directory

**Problem**: Apache can't serve files from `/web`

**Solution**:
```bash
# 1. Check current context
ls -Z /web/
# Shows: default_t or admin_home_t (wrong)

# 2. Set correct context permanently
sudo semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
sudo restorecon -Rv /web

# 3. Verify
ls -Z /web/
# Should show: httpd_sys_content_t

# 4. Test
curl http://localhost/mypage.html
```

### 6.2 Apache Connecting to Remote Database

**Problem**: Apache can't connect to MySQL on remote host

**Check denial**:
```bash
sudo ausearch -m avc -c httpd | grep connect
```

**Solution**:
```bash
# Enable network database connections
sudo setsebool -P httpd_can_network_connect_db on

# Or broader network access
sudo setsebool -P httpd_can_network_connect on
```

### 6.3 SSH on Non-Standard Port

**Problem**: SSHD won't start on port 2222

**Solution**:
```bash
# 1. Check current allowed ports
sudo semanage port -l | grep ssh
# Output: ssh_port_t tcp 22

# 2. Add custom port
sudo semanage port -a -t ssh_port_t -p tcp 2222

# 3. Verify
sudo semanage port -l | grep ssh
# Output: ssh_port_t tcp 22, 2222

# 4. Restart SSH
sudo systemctl restart sshd
```

### 6.4 NFS Home Directories

**Problem**: Users can't access NFS-mounted home directories

**Solution**:
```bash
# Enable NFS home directory support
sudo setsebool -P use_nfs_home_dirs on

# Also ensure correct context on NFS server
# On NFS server:
sudo semanage fcontext -a -t home_root_t "/export/home(/.*)?"
sudo restorecon -Rv /export/home
```

---

## 7. Creating Custom SELinux Policies

### 7.1 When to Create Custom Policy

- Audit2allow suggests it
- Running custom/third-party software
- Standard contexts don't fit your setup
- After testing in permissive mode

### 7.2 Policy Module Creation Process

**Step 1: Collect denials**
```bash
# Switch to permissive temporarily
sudo setenforce 0

# Reproduce all functionality of your app
# This generates audit logs for all accesses

# Collect denials
sudo ausearch -m avc -ts today > denials.txt
```

**Step 2: Generate policy module**
```bash
# Create policy from denials
sudo audit2allow -M myapp < denials.txt

# This creates:
# myapp.te (Type Enforcement source file)
# myapp.pp (Compiled policy module)
```

**Step 3: Review the policy**
```bash
cat myapp.te

# Example output:
module myapp 1.0;

require {
    type httpd_t;
    type user_home_t;
    class file { read open };
}

#============= httpd_t ==============
allow httpd_t user_home_t:file { read open };
```

**Step 4: Install policy module**
```bash
sudo semodule -i myapp.pp

# Verify installation
sudo semodule -l | grep myapp
```

**Step 5: Re-enable enforcing and test**
```bash
sudo setenforce 1
# Test your application
```

### 7.3 Advanced Policy Development

For complex policies, use `sepolicy`:
```bash
# Generate policy template
sepolicy generate --application /usr/local/bin/myapp

# Creates skeleton policy files for manual editing
```

---

## 8. AppArmor (Alternative to SELinux)

### 8.1 AppArmor Overview

**AppArmor**:
- Default on Ubuntu, Debian, SUSE
- Simpler than SELinux
- Path-based (not label-based)
- Profiles instead of policies
- Easier to learn but less flexible

### 8.2 AppArmor Modes

**Enforce**:
- Profile actively enforces restrictions

**Complain**:
- Like SELinux permissive, logs violations

**Disable**:
- Profile not loaded

### 8.3 Basic AppArmor Commands

```bash
# Check status
sudo aa-status

# List profiles
sudo aa-status | grep profiles

# Set profile to enforce mode
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox

# Set profile to complain mode
sudo aa-complain /etc/apparmor.d/usr.bin.firefox

# Disable profile
sudo ln -s /etc/apparmor.d/usr.bin.firefox /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/usr.bin.firefox

# Reload all profiles
sudo systemctl reload apparmor
```

### 8.4 AppArmor Profile Example

Location: `/etc/apparmor.d/`

Example profile for custom app:
```bash
# /etc/apparmor.d/usr.local.bin.myapp

#include <tunables/global>

/usr/local/bin/myapp {
  #include <abstractions/base>

  # Allow reading config
  /etc/myapp/** r,

  # Allow writing to log
  /var/log/myapp/** rw,

  # Allow network
  network inet stream,

  # Deny everything else
}
```

Load profile:
```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.local.bin.myapp
```

### 8.5 SELinux vs AppArmor Comparison

| Feature | SELinux | AppArmor |
|---------|---------|----------|
| **Approach** | Label-based | Path-based |
| **Complexity** | High | Low |
| **Flexibility** | Very flexible | Moderate |
| **Default on** | RHEL, CentOS, Fedora | Ubuntu, Debian, SUSE |
| **Learning curve** | Steep | Gentle |
| **Integration** | Deep kernel integration | Kernel module |
| **Policy format** | Type Enforcement | Text profiles |
| **Best for** | Enterprise, high security | Desktop, simplicity |

---

## 9. SELinux Best Practices

1. **Never disable SELinux permanently** in production
   - Use permissive mode for troubleshooting
   - Fix issues, then return to enforcing

2. **Use semanage, not chcon** for permanent changes
   - `chcon` is temporary
   - `semanage` + `restorecon` is persistent

3. **Check audit logs first** before creating policies
   - Often it's a boolean or wrong context
   - Custom policies should be last resort

4. **Test in permissive mode** before deploying policies
   - Collect all denials
   - Generate comprehensive policy

5. **Use booleans** instead of custom policies when possible
   - `getsebool -a` to find relevant booleans
   - Booleans are tested and supported

6. **Document custom policies**
   - Why it was created
   - What it allows
   - When it can be removed

7. **Regularly update policy packages**
   - `sudo dnf update selinux-policy`
   - New policies for new software

8. **Monitor audit logs** for unexpected denials
   - Set up alerts
   - Investigate anomalies

---

## 10. Practice Exercises

1. **SELinux basics:**
   - Check current SELinux mode
   - Temporarily switch to permissive, then back to enforcing
   - Permanently change mode in config (don't reboot)

2. **Context management:**
   - Create `/custom-web` directory
   - Try to serve files from Apache (should fail)
   - Fix with proper context using semanage
   - Verify with `ls -Z`

3. **Port configuration:**
   - Change SSH to port 2222 in `/etc/ssh/sshd_config`
   - Try to restart (should fail)
   - Add port 2222 to ssh_port_t
   - Successfully restart SSH

4. **Troubleshooting:**
   - Install Apache and create `/var/www/html/index.html`
   - Move file from `/tmp` (wrong context)
   - Access fails - investigate with ausearch
   - Fix with restorecon

5. **Boolean practice:**
   - Find all httpd-related booleans
   - Try to configure Apache to proxy to backend (fails)
   - Enable `httpd_can_network_connect`
   - Verify proxy works

6. **Custom policy:**
   - Create a simple script in `/usr/local/bin/`
   - Run it and generate denials
   - Create custom policy with audit2allow
   - Install and test

7. **AppArmor (on Ubuntu):**
   - Check AppArmor status
   - Put Firefox in complain mode
   - Check logs for violations
   - Return to enforce mode

---

## 11. Key Takeaways

✅ **SELinux provides mandatory access control** beyond standard permissions  
✅ **Contexts (labels)** are user:role:type:level format  
✅ **Type enforcement** is the core mechanism (httpd_t accessing httpd_sys_content_t)  
✅ **Three modes**: enforcing (active), permissive (logging), disabled  
✅ **Booleans** allow runtime policy tuning without recompiling  
✅ **Troubleshooting workflow**: check audit logs → audit2why → fix context/boolean/policy  
✅ **Use semanage + restorecon** for permanent context changes  
✅ **Never permanently disable SELinux** in production environments  
✅ **AppArmor is simpler** path-based alternative to SELinux  

---

## 12. Additional Resources

- **Red Hat SELinux Guide**: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux
- **SELinux Project**: https://selinuxproject.org/
- **CentOS SELinux Wiki**: https://wiki.centos.org/HowTos/SELinux
- **AppArmor Wiki**: https://gitlab.com/apparmor/apparmor/-/wikis/home
- **Man pages**: `man selinux`, `man semanage`, `man audit2allow`

---

**Next**: Continue to [linux-23-advanced-system-administration.md](linux-23-advanced-sysadmin.md) for autofs, LDAP, time sync, and SSL certificates.

**Previous**: [linux-21-foundation-philosophy.md](linux-21-foundation-philosophy.md) for Linux history and philosophy.

