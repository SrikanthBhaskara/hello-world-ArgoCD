# Linux 20 – Printing with CUPS

## 0. Goal of This Note

- Understand CUPS (Common UNIX Printing System).  
- Add and configure printers from CLI and GUI.  
- Use lp, lpr, lpstat commands.  
- Manage print queues and jobs.  
- Configure network printers and troubleshoot.

---

## 1. CUPS Overview

### 1.1 What is CUPS?

**CUPS (Common UNIX Printing System):**
- Modern printing system for Unix-like operating systems
- Developed by Apple (now open source)
- Uses Internet Printing Protocol (IPP)
- Web interface for management
- Supports network and local printers

**Architecture:**
```
┌─────────────────────────────────────┐
│  Application (Firefox, LibreOffice) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Print Dialog / lp command          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  CUPS Scheduler (cupsd)             │
│  - Manages jobs                     │
│  - Converts to printer language     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Backend (USB, Network, etc.)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Printer Hardware                   │
└─────────────────────────────────────┘
```

### 1.2 CUPS Installation

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install cups cups-client

# Enable and start
sudo systemctl enable cups
sudo systemctl start cups
sudo systemctl status cups
```

**Fedora/RHEL:**
```bash
sudo dnf install cups cups-client
sudo systemctl enable cups
sudo systemctl start cups
```

**Arch:**
```bash
sudo pacman -S cups cups-pdf
sudo systemctl enable cups.service
sudo systemctl start cups.service
```

### 1.3 CUPS Configuration Files

```bash
# Main configuration
/etc/cups/cupsd.conf                # CUPS daemon config

# Printer definitions
/etc/cups/printers.conf             # printer configurations

# Default options
/etc/cups/lpoptions                 # system-wide defaults
~/.cups/lpoptions                   # user-specific defaults

# Logs
/var/log/cups/access_log            # access log
/var/log/cups/error_log             # error log
/var/log/cups/page_log              # page log

# PPD files (printer drivers)
/etc/cups/ppd/                      # printer description files
/usr/share/ppd/                     # system PPD files
```

---

## 2. CUPS Web Interface

### 2.1 Accessing Web Interface

```bash
# Default URL
http://localhost:631

# Or
http://127.0.0.1:631

# Allow remote access (edit /etc/cups/cupsd.conf):
sudo cupsctl --remote-admin
sudo cupsctl --share-printers
sudo systemctl restart cups
```

**Web interface sections:**
- **Home**: Overview
- **Administration**: Add printers, manage server
- **Printers**: Manage existing printers
- **Jobs**: View print jobs
- **Help**: Documentation

### 2.2 Adding Printer via Web Interface

1. Go to http://localhost:631
2. Click **Administration** → **Add Printer**
3. Login (requires user in lpadmin group)
4. Select printer connection type:
   - Local Printers: USB
   - Network Printers: IPP, LPD, HTTP
   - Discovered Printers: Auto-detected
5. Choose make and model
6. Set default options
7. Print test page

**Add user to lpadmin group:**
```bash
sudo usermod -aG lpadmin $USER
# Or
sudo adduser $USER lpadmin

# Logout and login for changes to take effect
```

---

## 3. Command-Line Printer Management

### 3.1 Listing Printers

```bash
# List all printers
lpstat -p -d                        # -p: printers, -d: default
lpstat -p                           # all printers only
lpstat -a                           # accepting status
lpstat -s                           # summary (printers, devices, classes)

# Detailed printer info
lpstat -l -p printer-name           # long format for specific printer
lpstat -l                           # long format for all
lpstat -v                           # show device URIs
lpstat -v printer-name              # device URI for specific printer

# Show default printer
lpstat -d                           # default destination
echo $PRINTER                       # environment variable (if set)
lpoptions -d                        # show default with options

# Printer status
lpstat -t                           # all info (comprehensive)
lpstat -r                           # check if CUPS is running
lpstat -h server -p                 # list printers on remote server

# Printer classes
lpstat -c                           # list classes
lpstat -c class-name                # class members

# List available devices (requires root)
sudo lpinfo -v                      # devices (USB, network, etc.)
sudo lpinfo -v --include-schemes all # all device types
sudo lpinfo -v --include-schemes usb # USB devices only
sudo lpinfo -v --include-schemes ipp # IPP devices only
sudo lpinfo -v --exclude-schemes file # exclude file devices

# List available drivers/models
sudo lpinfo -m                      # all models/drivers
sudo lpinfo -m | grep -i hp         # HP drivers only
sudo lpinfo -m | grep -i canon      # Canon drivers
sudo lpinfo --make-and-model "HP LaserJet" -m  # specific model

# Printer capabilities
lpoptions -p printer-name -l        # list all options
lpoptions -p printer-name           # current defaults

# Check printer driver (PPD)
lpinfo -p printer-name              # PPD file path
cat /etc/cups/ppd/printer-name.ppd  # view PPD file
```

### 3.2 Adding Printers (lpadmin)

**USB printer:**
```bash
# Find device URI
sudo lpinfo -v
# Example output: direct usb://HP/LaserJet%201020

# Add printer
sudo lpadmin -p HP_LaserJet \
    -E \
    -v usb://HP/LaserJet%201020 \
    -m drv:///hp/hpijs.drv/hp-laserjet_1020.ppd

# -p: printer name
# -E: enable printer
# -v: device URI
# -m: model/driver (PPD file)

# Set as default
sudo lpadmin -d HP_LaserJet
```

**Network printer (IPP):**
```bash
sudo lpadmin -p Office_Printer \
    -E \
    -v ipp://192.168.1.100/ipp/print \
    -m everywhere

# "everywhere" uses driverless IPP
```

**Network printer (HP JetDirect/9100):**
```bash
sudo lpadmin -p Network_HP \
    -E \
    -v socket://192.168.1.100:9100 \
    -m drv:///hp/hpijs.drv/hp-laserjet_p2055.ppd
```

**Set printer description:**
```bash
sudo lpadmin -p HP_LaserJet -D "HP LaserJet 1020 in Office"
sudo lpadmin -p HP_LaserJet -L "Office Room 205"
```

### 3.3 Modifying Printers

**Enable/Disable printer:**
```bash
sudo cupsenable HP_LaserJet         # enable
sudo cupsdisable HP_LaserJet        # disable
sudo cupsdisable -r "Out of paper" HP_LaserJet  # with reason
sudo cupsdisable -c HP_LaserJet     # cancel jobs while disabling

# Alternative (older syntax)
sudo lpadmin -p HP_LaserJet -E      # enable

# Check if enabled
lpstat -p HP_LaserJet | grep enabled
```

**Accept/Reject jobs:**
```bash
sudo cupsaccept HP_LaserJet         # accept jobs
sudo cupsreject HP_LaserJet         # reject new jobs
sudo cupsreject -r "Maintenance" HP_LaserJet  # with reason

# Alternative syntax
sudo lpadmin -p HP_LaserJet -o printer-is-accepting-jobs=true
sudo lpadmin -p HP_LaserJet -o printer-is-accepting-jobs=false

# Check acceptance status
lpstat -a HP_LaserJet
```

**Pause/Resume printer:**
```bash
# Pause all printing
sudo cupsdisable HP_LaserJet

# Hold jobs without disabling
cupsctl --debug-logging             # enable debug mode

# Resume
sudo cupsenable HP_LaserJet
```

**Modify printer location and description:**
```bash
sudo lpadmin -p HP_LaserJet -L "Building A, Room 205"
sudo lpadmin -p HP_LaserJet -D "HP LaserJet P2055 - Main Office"

# View location/description
lpstat -l -p HP_LaserJet
```

**Change device URI:**
```bash
# Change from USB to network
sudo lpadmin -p HP_LaserJet -v ipp://192.168.1.100/ipp/print

# Change network address
sudo lpadmin -p HP_LaserJet -v socket://192.168.1.101:9100
```

**Change printer driver:**
```bash
# Change to different PPD
sudo lpadmin -p HP_LaserJet -m drv:///hp/hpijs.drv/hp-laserjet_p2055.ppd

# Use driverless IPP Everywhere
sudo lpadmin -p HP_LaserJet -m everywhere

# Use specific PPD file
sudo lpadmin -p HP_LaserJet -P /path/to/printer.ppd
```

**Set default printer:**
```bash
sudo lpadmin -d HP_LaserJet
# Or
lpoptions -d HP_LaserJet            # user default
```

**Set printer options:**
```bash
# Set duplex (two-sided)
sudo lpadmin -p HP_LaserJet -o sides=two-sided-long-edge

# Set default paper size
sudo lpadmin -p HP_LaserJet -o media=Letter

# Set print quality
sudo lpadmin -p HP_LaserJet -o print-quality=high
```

### 3.4 Removing Printers

```bash
sudo lpadmin -x HP_LaserJet         # remove printer
```

---

## 4. Printing Files

### 4.1 lp Command (Standard)

**Basic printing:**
```bash
lp file.txt                         # print to default printer
lp -d HP_LaserJet file.txt          # print to specific printer
lp file1.txt file2.txt file3.txt    # print multiple files
lp -h server file.txt               # print to remote CUPS server
lp -h server:631 file.txt           # remote server with port

# Print from stdin
cat file.txt | lp
echo "Test" | lp
ls -la | lp

# Print with job name/title
lp -t "Quarterly Report" file.pdf
lp -t "Invoice #1234" invoice.pdf

# Silent mode (no output)
lp -q file.txt                      # quiet mode
lp -s file.txt                      # silent
```

**Print options:**
```bash
# Number of copies
lp -n 3 file.txt                    # 3 copies
lp -n 10 file.txt                   # 10 copies

# Page range
lp -P 1-10 file.pdf                 # pages 1 to 10
lp -P 1,3,5-10 file.pdf             # pages 1, 3, and 5-10
lp -P 5- file.pdf                   # page 5 to end
lp -P -10 file.pdf                  # first 10 pages
lp -P 2-5,8,10-15 file.pdf          # multiple ranges

# Duplex (two-sided)
lp -o sides=two-sided-long-edge file.pdf
lp -o sides=two-sided-short-edge file.pdf
lp -o sides=one-sided file.pdf

# Orientation
lp -o landscape file.txt
lp -o portrait file.txt

# Paper size
lp -o media=Letter file.txt
lp -o media=A4 file.txt
lp -o media=Legal file.txt

# Multiple pages per sheet
lp -o number-up=2 file.pdf          # 2 pages per sheet
lp -o number-up=4 file.pdf          # 4 pages per sheet
lp -o number-up=6 file.pdf          # 6 pages per sheet
lp -o number-up=9 file.pdf          # 9 pages per sheet
lp -o number-up=16 file.pdf         # 16 pages per sheet

# Page layout for number-up
lp -o number-up-layout=lrtb         # left-right, top-bottom
lp -o number-up-layout=lrbt         # left-right, bottom-top
lp -o number-up-layout=rltb         # right-left, top-bottom
lp -o number-up-layout=rlbt         # right-left, bottom-top
lp -o number-up-layout=tblr         # top-bottom, left-right
lp -o number-up-layout=tbrl         # top-bottom, right-left
lp -o number-up-layout=btlr         # bottom-top, left-right
lp -o number-up-layout=btrl         # bottom-top, right-left

# Print quality
lp -o print-quality=draft file.txt
lp -o print-quality=normal file.txt
lp -o print-quality=high file.txt
lp -o print-quality=3 file.txt      # draft
lp -o print-quality=4 file.txt      # normal
lp -o print-quality=5 file.txt      # high

# Resolution (DPI)
lp -o Resolution=300dpi file.pdf
lp -o Resolution=600dpi file.pdf
lp -o Resolution=1200dpi file.pdf

# Fit to page
lp -o fit-to-page file.pdf
lp -o scaling=100 file.pdf          # 100% (no scaling)
lp -o scaling=75 file.pdf           # 75% of page
lp -o scaling=150 file.pdf          # 150% (enlarge)
lp -o fitplot file.pdf              # fit to printable area

# Margins
lp -o page-left=36 file.pdf         # left margin (points: 72=1 inch)
lp -o page-right=36 file.pdf        # right margin
lp -o page-top=36 file.pdf          # top margin
lp -o page-bottom=36 file.pdf       # bottom margin

# Color options
lp -o ColorModel=RGB file.pdf
lp -o ColorModel=CMYK file.pdf
lp -o ColorModel=Gray file.pdf      # grayscale
lp -o outputorder=reverse file.pdf  # reverse order (last page first)
lp -o outputorder=normal file.pdf   # normal order

# Collate (for multiple copies)
lp -n 3 -o Collate=True file.pdf    # collate copies
lp -n 3 -o Collate=False file.pdf   # don't collate

# Print mirror image
lp -o mirror file.pdf

# Print in reverse
lp -o outputorder=reverse file.pdf

# Combine options
lp -d HP_LaserJet -n 2 -o sides=two-sided-long-edge -o media=Letter file.pdf
```

**Piped input:**
```bash
echo "Hello World" | lp
cat file.txt | lp
ls -la | lp
```

### 4.2 lpr Command (BSD-style)

```bash
# Similar to lp, BSD compatibility
lpr file.txt
lpr -P HP_LaserJet file.txt         # -P for printer (not -d)
lpr -#3 file.txt                    # 3 copies (not -n)
```

### 4.3 Print with Title/Job Name

```bash
lp -t "Monthly Report" file.pdf
lpr -J "Sales Report" file.pdf
```

---

## 5. Managing Print Jobs

### 5.1 Viewing Jobs

```bash
# List jobs for default printer
lpq                                 # BSD-style queue viewer
lpq -a                              # all queues

# List jobs for specific printer
lpq -P HP_LaserJet
lpq -P HP_LaserJet -l               # long format

# List all jobs (CUPS style)
lpstat -o                           # all jobs
lpstat -o HP_LaserJet               # jobs for specific printer
lpstat -u username                  # user's jobs
lpstat -W completed                 # completed jobs
lpstat -W not-completed             # active jobs
lpstat -W all                       # all jobs (active + completed)

# Detailed job info
lpstat -o -l                        # long format
lpstat -W completed -l              # completed jobs (detailed)
lpstat -o job-id                    # specific job

# Job status with user info
lpstat -o -u username               # specific user's jobs
lpstat -o -u all                    # all users' jobs

# Watch queue in real-time
watch -n 2 lpq                      # update every 2 seconds
watch -n 1 'lpstat -o'

# Count jobs
lpstat -o | wc -l                   # number of jobs
lpstat -o HP_LaserJet | wc -l       # jobs on specific printer

# List job history
lpstat -W completed | head -20      # last 20 completed jobs
lpstat -W completed | grep username # user's completed jobs
```

### 5.2 Canceling Jobs

```bash
# Cancel specific job
cancel job-id                       # e.g., cancel 123
cancel HP_LaserJet-123              # full job ID
lprm job-id                         # BSD style
lprm -P HP_LaserJet job-id          # BSD with printer

# Cancel all jobs for user
cancel -a                           # current user (all printers)
cancel -a -u username               # specific user
cancel -a -u username HP_LaserJet   # user's jobs on specific printer
cancel -u username                  # without -a (same effect)

# Cancel all jobs on printer
cancel -a HP_LaserJet               # all jobs on printer
cancel HP_LaserJet                  # same as above
lprm -P HP_LaserJet -               # BSD style (all jobs)

# Cancel currently printing job
cancel -                            # current job
lprm -                              # BSD style

# Cancel job by host
cancel -h server job-id             # cancel on remote server
cancel -h server:631 job-id         # with port

# Cancel with confirmation
cancel -x job-id                    # cancel without warning

# Purge all jobs from all printers
cancel -a -x                        # purge all
sudo cancel -a -x                   # as admin (for all users)

# Cancel range of jobs
for i in {100..150}; do cancel $i; done  # jobs 100-150
```

### 5.3 Job Priority

```bash
# Set priority (1-100, 50 is default)
lp -q 75 file.txt                   # higher priority (75)
lp -q 100 file.txt                  # highest priority
lp -q 25 file.txt                   # lower priority
lp -q 1 file.txt                    # lowest priority
lp -q 50 file.txt                   # default priority

# Priority with lpr
lpr -p file.txt                     # high priority (BSD)

# Change priority of existing job
lp -i job-id -q 90                  # change to priority 90

# Hold jobs (prevent printing)
lp -H hold file.txt                 # hold immediately
lp -H resume file.txt               # resume held job
lp -H restart file.txt              # restart job

# Hold existing job
lp -i job-id -H hold                # hold
lp -i job-id -H resume              # resume
lp -i job-id -H restart             # restart

# Job holds with times
lp -H hold file.txt                 # indefinite hold
lp -H resume file.txt               # release hold
```

---

## 6. Printer Options and Settings

### 6.1 View Printer Options

```bash
# List all options for printer
lpoptions -p HP_LaserJet -l

# Example output:
# PageSize/Media Size: Letter *A4 Legal A5
# Duplex/2-Sided Printing: *None DuplexNoTumble DuplexTumble
# ColorModel/Color Mode: *RGB CMYK Gray

# Current defaults
lpoptions -p HP_LaserJet
```

### 6.2 Set Default Options

**System-wide (requires root):**
```bash
sudo lpadmin -p HP_LaserJet -o sides=two-sided-long-edge
sudo lpadmin -p HP_LaserJet -o media=A4
```

**User-specific:**
```bash
lpoptions -p HP_LaserJet -o sides=two-sided-long-edge
lpoptions -p HP_LaserJet -o media=A4

# Stored in ~/.cups/lpoptions
```

---

## 7. PDF Virtual Printer

### 7.1 CUPS-PDF Setup

**Install:**
```bash
sudo apt install cups-pdf           # Debian/Ubuntu
sudo dnf install cups-pdf           # Fedora
```

**Configuration:**
```bash
# Config file
sudo vim /etc/cups/cups-pdf.conf

# Default output directory
Out ${HOME}/PDF                     # PDFs saved to ~/PDF

# Or change to:
Out /home/${USER}/Documents/PDF
```

**Print to PDF:**
```bash
lp -d PDF file.txt                  # creates file.pdf in ~/PDF
```

**Find PDF printer:**
```bash
lpstat -p | grep PDF
```

---

## 8. Network Printing

### 8.1 Sharing Printers

**Enable printer sharing:**
```bash
# Via web interface:
# Administration → check "Share printers connected to this system"

# Via command:
sudo cupsctl --share-printers
sudo lpadmin -p HP_LaserJet -o printer-is-shared=true

# Restart CUPS
sudo systemctl restart cups
```

**Firewall rules:**
```bash
# Allow IPP (port 631)
sudo ufw allow 631/tcp
sudo firewall-cmd --permanent --add-service=ipp
sudo firewall-cmd --reload
```

### 8.2 Connecting to Network Printer

**Auto-discovery (Avahi):**
```bash
sudo apt install avahi-daemon
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon

# List discovered printers
lpinfo -v | grep dnssd
```

**Manual network printer:**
```bash
# IPP printer
sudo lpadmin -p Remote_Printer \
    -E \
    -v ipp://print-server.local:631/printers/HP_LaserJet \
    -m everywhere

# Windows shared printer (SMB)
sudo lpadmin -p Windows_Printer \
    -E \
    -v smb://username:password@windowspc/PrinterShareName \
    -m everywhere
```

---

## 9. Troubleshooting

### 9.1 Common Issues

**Printer not detected:**
```bash
# Check USB connection
lsusb                               # list USB devices
lsusb -v                            # verbose
lsusb -t                            # tree view
dmesg | grep -i usb                 # kernel USB messages
dmesg | grep -i printer
dmesg | tail -50                    # recent messages

# Check CUPS status
sudo systemctl status cups
sudo systemctl is-active cups
sudo systemctl is-enabled cups

# Check CUPS is running
lpstat -r                           # scheduler running?
cups-config --version               # CUPS version

# Check device permissions
ls -l /dev/usb/lp0                  # USB parallel port
ls -l /dev/usb/                     # all USB devices
getfacl /dev/usb/lp0                # ACL permissions

# Check user groups
groups                              # current user groups
id                                  # user ID and groups
grep lp /etc/group                  # lp group members
grep lpadmin /etc/group             # lpadmin group

# Reload USB modules
sudo modprobe -r usblp              # remove module
sudo lsmod | grep usblp             # verify removed
sudo modprobe usblp                 # load module
lsmod | grep usblp                  # verify loaded

# Check for device conflicts
sudo fuser /dev/usb/lp0             # what's using device

# Rescan USB devices
sudo udevadm trigger --action=add   # trigger udev scan
sudo udevadm control --reload       # reload udev rules
```

**Jobs stuck in queue:**
```bash
# Check printer status
lpstat -p -d                        # printer status
lpstat -p HP_LaserJet               # specific printer
lpstat -t                           # everything
lpstat -a HP_LaserJet               # accepting jobs?

# Check if printer is idle, processing, or stopped
lpstat -p HP_LaserJet | grep -E 'idle|processing|stopped'

# Enable printer
sudo cupsenable HP_LaserJet
sudo cupsaccept HP_LaserJet

# Check for errors
lpstat -l -p HP_LaserJet

# Cancel all jobs and restart
cancel -a HP_LaserJet               # cancel all jobs
sudo systemctl restart cups         # restart CUPS
sudo systemctl status cups          # verify restarted

# Reset printer
sudo cupsdisable HP_LaserJet
sudo cupsenable HP_LaserJet

# Clear job cache
sudo rm -f /var/cache/cups/job.cache
sudo systemctl restart cups

# Check backend
sudo lpinfo -v | grep -i hp         # HP backends available
ls -l /usr/lib/cups/backend/        # all backends
```

**Check CUPS error log:**
```bash
# View error log
sudo tail -f /var/log/cups/error_log
sudo tail -100 /var/log/cups/error_log
sudo less /var/log/cups/error_log

# Search for errors
sudo grep -i error /var/log/cups/error_log
sudo grep -i fail /var/log/cups/error_log
sudo grep -i warning /var/log/cups/error_log

# Check access log
sudo tail -f /var/log/cups/access_log
sudo grep POST /var/log/cups/access_log  # print jobs

# Check page log
sudo tail -f /var/log/cups/page_log

# Enable debug logging
sudo cupsctl --debug-logging
sudo cupsctl LogLevel=debug
# Print test page
# Check logs
sudo cupsctl --no-debug-logging     # disable after
sudo cupsctl LogLevel=warn          # default level

# Other log levels
sudo cupsctl LogLevel=none
sudo cupsctl LogLevel=error
sudo cupsctl LogLevel=warn
sudo cupsctl LogLevel=info
sudo cupsctl LogLevel=debug
sudo cupsctl LogLevel=debug2        # very verbose

# View current log level
sudo cupsctl | grep LogLevel
grep LogLevel /etc/cups/cupsd.conf

# Rotate logs
sudo logrotate -f /etc/logrotate.d/cups

# Clear old logs
sudo truncate -s 0 /var/log/cups/error_log
sudo truncate -s 0 /var/log/cups/access_log
```

**Permission issues:**
```bash
# Check file permissions
ls -l /etc/cups/printers.conf
ls -l /etc/cups/ppd/
ls -ld /var/spool/cups/
ls -ld /var/cache/cups/

# Fix permissions
sudo chown root:lp /etc/cups/printers.conf
sudo chmod 600 /etc/cups/printers.conf
sudo chown -R root:lp /etc/cups/ppd/
sudo chmod 755 /var/spool/cups/

# Fix SELinux contexts (RHEL/CentOS)
sudo restorecon -Rv /etc/cups
sudo restorecon -Rv /var/spool/cups
sudo setsebool -P cupsd_config_domain_can_write_state on
```

**Network printer issues:**
```bash
# Test connectivity
ping 192.168.1.100
telnet 192.168.1.100 631            # IPP
telnet 192.168.1.100 9100           # JetDirect
nc -zv 192.168.1.100 631            # test IPP port
nc -zv 192.168.1.100 9100           # test JetDirect

# Test IPP URL
ipptool -tv ipp://192.168.1.100/ipp/print get-printer-attributes.test

# DNS resolution
nslookup printer.local
dig printer.local
avahi-browse -a                     # discover network printers

# Firewall check
sudo iptables -L -n | grep 631
sudo firewall-cmd --list-all
sudo ufw status
```

**Driver issues:**
```bash
# Check PPD file
ls -l /etc/cups/ppd/HP_LaserJet.ppd
cupstestppd /etc/cups/ppd/HP_LaserJet.ppd

# Validate PPD
cupstestppd -v /etc/cups/ppd/HP_LaserJet.ppd

# Search for alternative drivers
sudo lpinfo -m | grep -i "HP LaserJet"
apt-cache search printer-driver-hp  # Debian/Ubuntu
dnf search printer-driver            # Fedora/RHEL

# Install additional drivers
sudo apt install printer-driver-hpcups  # HP
sudo apt install printer-driver-gutenprint  # Many printers
sudo dnf install hplip                  # HP Linux Imaging and Printing
```

### 9.2 Test Printer

**Print test page:**
```bash
# From web interface: Printers → HP_LaserJet → Print Test Page

# Command line test page
echo "Test Page - $(date)" | lp
echo "Test Page" | lp -d HP_LaserJet

# Print test page (PostScript)
/usr/lib/cups/backend/testpage | lp

# Print CUPS test page
/usr/share/cups/data/testprint.ps | lp

# Print system info
lpstat -t | lp
uname -a | lp

# Print color test
convert -size 200x200 xc:red red.pdf && lp red.pdf

# Test specific features
lp -o sides=two-sided-long-edge testfile.pdf
lp -o number-up=4 testfile.pdf
```

**Test printer connectivity:**
```bash
# Test network printer
ping -c 4 192.168.1.100
ping printer.local

# Test ports
telnet 192.168.1.100 631            # IPP
telnet 192.168.1.100 9100           # JetDirect
nc -zv 192.168.1.100 631
nc -zv 192.168.1.100 9100

# Test IPP printer
lpinfo -v --include-schemes ipp
ipptool -tv ipp://192.168.1.100/ipp/print get-printer-attributes.test
ipptool ipp://192.168.1.100 -f test.pdf print-job.test

# Test backends
ls -l /usr/lib/cups/backend/
/usr/lib/cups/backend/usb           # list USB printers
/usr/lib/cups/backend/network       # network discovery

# Test filter chain
cups-filter -m application/pdf -o media=letter test.pdf
```

**Diagnostic tools:**
```bash
# CUPS diagnostic
cups-config --version
cups-config --datadir
cups-config --serverbin

# List CUPS variables
cupsctl                             # all settings
cupsctl | grep -i browse
cupsctl | grep -i log

# Printer info utility
CUPS_DEBUG_LOG=/tmp/cups.log lp test.txt
cat /tmp/cups.log

# Backend discovery
sudo /usr/lib/cups/backend/snmp 192.168.1.0/24
sudo /usr/lib/cups/backend/dnssd

# Test PPD file
cupstestppd /etc/cups/ppd/printer.ppd
cupstestppd -v /etc/cups/ppd/printer.ppd

# Check filter
cups-filter -p /etc/cups/ppd/printer.ppd -m application/pdf test.pdf > /tmp/output.ps
```

---

## 10. GUI Printer Management

### 10.1 GNOME Settings

```bash
# Open Settings → Printers
gnome-control-center printers

# Or
system-config-printer               # older tool
```

**Features:**
- Add printer (auto-detection)
- Set default printer
- Configure printer options
- Print test page
- View print queue

### 10.2 KDE Print Settings

```bash
# System Settings → Printers
systemsettings5

# Or KDE Print Management
kde-print-manager
```

---

## 11. Printing from Applications

### 11.1 LibreOffice

```bash
# Print dialog: File → Print (Ctrl+P)
# Options:
# - Select printer
# - Page range
# - Copies
# - Duplex
# - Print to file (PDF)
```

### 11.2 Firefox

```bash
# Print dialog: File → Print (Ctrl+P)
# Or right-click → Print
# Options:
# - Page setup
# - Print preview
# - Save as PDF
```

### 11.3 Command-Line PDF

```bash
# Convert and print
libreoffice --headless --convert-to pdf document.odt
lp document.pdf

# Print without conversion
lp document.odt                     # CUPS auto-converts
```

---

## 12. Advanced CUPS Configuration

### 12.1 CUPS Browsing

**Enable printer browsing:**
```bash
sudo vim /etc/cups/cupsd.conf

# Add:
Browsing On
BrowseLocalProtocols dnssd

# Restart
sudo systemctl restart cups
```

### 12.2 Access Control

**Allow remote admin:**
```bash
sudo vim /etc/cups/cupsd.conf

# Find:
<Location /admin>
  Order allow,deny
  Allow localhost
  Allow 192.168.1.*              # Allow local network
</Location>

sudo systemctl restart cups
```

---

## 13. Practice Exercises

1. **Setup:**
   - Install CUPS
   - Add USB or network printer
   - Print test page from web interface

2. **Command-line printing:**
   - Print text file with lp
   - Print PDF with duplex
   - Print 3 copies of document

3. **Queue management:**
   - Submit multiple print jobs
   - View queue with lpq
   - Cancel specific job

4. **Configuration:**
   - Set default printer
   - Configure default duplex printing
   - Set up CUPS-PDF

5. **Network printing:**
   - Share local printer
   - Connect to network printer
   - Test from another machine

6. **Troubleshooting:**
   - Check CUPS logs
   - Restart stuck queue
   - Re-add printer

---

## Summary

**Essential commands:**
```bash
lpstat -p -d                        # list printers
lp file.txt                         # print file
lp -d printer -n 2 file.pdf         # print 2 copies
lpq                                 # view queue
cancel job-id                       # cancel job
sudo lpadmin -p name -E -v uri -m model  # add printer
```

**Quick reference:**
- Web interface: http://localhost:631
- Config: /etc/cups/cupsd.conf
- Logs: /var/log/cups/
- PPD files: /etc/cups/ppd/

Next: **Linux 21 – Linux Foundation & Philosophy** for understanding Linux principles and history.
