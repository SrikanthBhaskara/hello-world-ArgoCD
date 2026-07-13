# Linux 18 – Graphical Interfaces & Desktop Environments

## 0. Goal of This Note

- Understand X Window System and Wayland.  
- Explore major desktop environments (GNOME, KDE, Xfce, etc.).  
- Configure desktop settings from GUI and CLI.  
- Manage display servers and window managers.  
- Customize and troubleshoot graphical environments.

---

## 1. Display Servers: X11 vs Wayland

### 1.1 X Window System (X11)

**What is X11?**
- Network-transparent windowing system created at MIT in 1984
- Separates client (application) from server (display)
- Still widely used, mature and stable
- Default on many distributions

**Architecture:**
```
┌─────────────────────────────────────┐
│  Applications (X Clients)           │
│  (Firefox, Terminal, etc.)          │
└──────────────┬──────────────────────┘
               │ X Protocol
┌──────────────▼──────────────────────┐
│  X Server (Xorg)                    │
│  - Manages display, keyboard, mouse │
│  - Renders windows                  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Hardware (GPU, Monitor)            │
└─────────────────────────────────────┘
```

**Check if using X11:**
```bash
echo $XDG_SESSION_TYPE              # Output: x11
ps aux | grep Xorg
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

**X11 configuration:**
```bash
# Main config directory
/etc/X11/

# Xorg config
/etc/X11/xorg.conf                  # main config (often auto-generated)
/etc/X11/xorg.conf.d/               # config snippets

# Display info
xdpyinfo                            # detailed display info
xrandr                              # screen resolution/outputs
xwininfo                            # window information (click window)

# Set resolution
xrandr --output HDMI-1 --mode 1920x1080 --rate 60
xrandr --output eDP-1 --auto        # auto-detect best

# Multiple monitors
xrandr --output HDMI-1 --right-of eDP-1
xrandr --output HDMI-1 --above eDP-1
```

### 1.2 Wayland

**What is Wayland?**
- Modern replacement for X11 (development started 2008)
- Simpler protocol, better security
- Better performance, less latency
- Default on Fedora, Ubuntu (recent versions)

**Architecture:**
```
┌─────────────────────────────────────┐
│  Applications (Wayland Clients)     │
└──────────────┬──────────────────────┘
               │ Wayland Protocol
┌──────────────▼──────────────────────┐
│  Wayland Compositor                 │
│  (Mutter, KWin, Weston)             │
│  - Combines window manager + server │
│  - Handles rendering                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Hardware (GPU, Monitor via KMS)    │
└─────────────────────────────────────┘
```

**Check if using Wayland:**
```bash
echo $XDG_SESSION_TYPE              # Output: wayland
echo $WAYLAND_DISPLAY
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type

# Wayland info
weston-info                         # if Weston compositor
```

**Switch between X11 and Wayland:**
```bash
# At login screen (GDM/SDDM), click gear icon
# Select "GNOME on Xorg" or "GNOME" (Wayland)

# Or edit session file
sudo vim /usr/share/xsessions/gnome.desktop    # X11 session
sudo vim /usr/share/wayland-sessions/gnome.desktop  # Wayland session
```

### 1.3 X11 vs Wayland Comparison

| Feature | X11 | Wayland |
|---------|-----|---------|
| **Architecture** | Client-server | Compositor-based |
| **Complexity** | Complex, bloated | Simpler, modern |
| **Security** | Weak (apps can see all windows) | Strong isolation |
| **Performance** | Good, some latency | Better, lower latency |
| **Screen capture** | Easy (any app) | Restricted (requires permission) |
| **Network transparency** | Yes (remote X) | No (by design) |
| **Compatibility** | Excellent | Improving (XWayland for legacy) |
| **Maturity** | Very mature (40+ years) | Maturing (15+ years) |

---

## 2. Desktop Environments

### 2.1 GNOME

**Overview:**
- Modern, elegant, minimal interface
- Default on Ubuntu, Fedora, Debian
- GTK-based
- Resource usage: Medium-Heavy

**Installation:**
```bash
# Debian/Ubuntu
sudo apt install ubuntu-desktop      # Ubuntu's GNOME
sudo apt install gnome-core          # Minimal GNOME
sudo apt install gnome               # Full GNOME

# Fedora
sudo dnf groupinstall "GNOME Desktop Environment"

# Arch
sudo pacman -S gnome gnome-extra
```

**GNOME Shell Extensions:**
```bash
# Install extension support
sudo apt install gnome-shell-extensions
sudo apt install chrome-gnome-shell  # for browser integration

# Popular extensions (install from extensions.gnome.org):
# - Dash to Dock: macOS-like dock
# - Dash to Panel: Windows-like taskbar
# - User Themes: custom themes
# - Clipboard Indicator: clipboard manager
# - Caffeine: prevent screen sleep

# Manage extensions
gnome-extensions list
gnome-extensions enable extension-name@author
gnome-extensions disable extension-name@author
```

**GNOME Settings:**
```bash
# Open settings GUI
gnome-control-center

# Command-line settings (gsettings)
gsettings list-schemas
gsettings list-keys org.gnome.desktop.interface

# Change theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Change wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///path/to/image.jpg'

# Keyboard shortcuts
gsettings list-keys org.gnome.desktop.wm.keybindings

# Tweak tool
sudo apt install gnome-tweak-tool
gnome-tweaks
```

### 2.2 KDE Plasma

**Overview:**
- Highly customizable, feature-rich
- Windows-like interface
- Qt-based
- Resource usage: Medium

**Installation:**
```bash
# Debian/Ubuntu
sudo apt install kde-standard        # Standard KDE
sudo apt install kde-full            # Complete KDE

# Fedora
sudo dnf groupinstall "KDE Plasma Workspaces"

# Arch
sudo pacman -S plasma kde-applications
```

**KDE Settings:**
```bash
# System Settings GUI
systemsettings5

# Command-line settings (kwriteconfig5)
kwriteconfig5 --file kdeglobals --group General --key Name 'Breeze Dark'

# Plasma widgets
# Right-click desktop > Add Widgets

# KDE configuration files
~/.config/kdeglobals                # global KDE settings
~/.config/kwinrc                    # window manager settings
~/.config/plasmarc                  # plasma shell settings
```

### 2.3 Xfce

**Overview:**
- Lightweight, fast, traditional desktop
- Similar to older GNOME 2
- GTK-based
- Resource usage: Light

**Installation:**
```bash
# Debian/Ubuntu
sudo apt install xfce4 xfce4-goodies

# Fedora
sudo dnf groupinstall "Xfce Desktop"

# Arch
sudo pacman -S xfce4 xfce4-goodies
```

**Xfce Settings:**
```bash
# Settings Manager
xfce4-settings-manager

# Individual settings
xfce4-appearance-settings           # themes, icons, fonts
xfce4-display-settings              # monitors
xfce4-keyboard-settings             # keyboard
xfce4-settings-editor               # advanced (like registry)

# Panel configuration
xfce4-panel --preferences

# Configuration files
~/.config/xfce4/
```

### 2.4 Other Desktop Environments

**MATE (GNOME 2 fork):**
```bash
# Lightweight, traditional layout
sudo apt install mate-desktop-environment
```

**Cinnamon (Linux Mint default):**
```bash
# Modern but familiar, Windows-like
sudo apt install cinnamon-desktop-environment
```

**LXQt (Lightweight Qt):**
```bash
# Very lightweight, minimal resources
sudo apt install lxqt
```

**LXDE (Lightweight X11 Desktop):**
```bash
# Ultra-lightweight
sudo apt install lxde
```

**Budgie (Solus OS default):**
```bash
# Modern, elegant
sudo apt install budgie-desktop
```

---

## 3. Window Managers (Advanced)

### 3.1 Tiling Window Managers

**i3 (popular tiling WM):**
```bash
# Install
sudo apt install i3

# Configuration
~/.config/i3/config

# Basic i3 keybindings:
# Mod+Enter: open terminal
# Mod+d: application launcher (dmenu)
# Mod+Shift+q: close window
# Mod+1-9: switch workspace
# Mod+Shift+1-9: move window to workspace
# Mod+h/j/k/l: change focus (vim-style)
```

**Other tiling WMs:**
- **awesome**: Lua-configured, highly customizable
- **bspwm**: Minimalist, controlled via bspc
- **dwm**: Suckless, configured in C
- **xmonad**: Haskell-based, very powerful

### 3.2 Stacking Window Managers

**Openbox (lightweight):**
```bash
sudo apt install openbox
# Right-click desktop for menu
# Configuration: ~/.config/openbox/
```

**Fluxbox:**
```bash
sudo apt install fluxbox
```

---

## 4. Display Managers (Login Screens)

### 4.1 Common Display Managers

**GDM (GNOME Display Manager):**
```bash
sudo apt install gdm3
sudo systemctl enable gdm
sudo systemctl start gdm

# Configuration
/etc/gdm3/
sudo dpkg-reconfigure gdm3          # Debian/Ubuntu
```

**SDDM (Simple Desktop Display Manager - KDE default):**
```bash
sudo apt install sddm
sudo systemctl enable sddm
sudo systemctl start sddm

# Configuration
/etc/sddm.conf
```

**LightDM (lightweight):**
```bash
sudo apt install lightdm
sudo systemctl enable lightdm
sudo systemctl start lightdm

# Greeters (login screen themes)
sudo apt install lightdm-gtk-greeter  # GTK greeter
sudo apt install slick-greeter        # Modern greeter
```

**Switch display manager:**
```bash
sudo dpkg-reconfigure gdm3          # Debian/Ubuntu
sudo systemctl disable gdm
sudo systemctl enable sddm
sudo reboot
```

### 4.2 Auto-login Configuration

**GDM auto-login:**
```bash
sudo vim /etc/gdm3/custom.conf

# Add under [daemon]:
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=username
```

**LightDM auto-login:**
```bash
sudo vim /etc/lightdm/lightdm.conf

# Add under [Seat:*]:
[Seat:*]
autologin-user=username
autologin-user-timeout=0
```

---

## 5. System Configuration from GUI

### 5.1 GNOME Settings

**Accessing System Settings:**
```bash
# Open Settings
gnome-control-center

# Or from terminal:
gnome-control-center wifi           # WiFi settings
gnome-control-center display        # Display settings
gnome-control-center sound          # Sound settings
gnome-control-center privacy        # Privacy settings
gnome-control-center power          # Power settings
```

**Common GUI Configurations:**

**Wi-Fi:**
- Settings → Wi-Fi → Select network → Connect

**Bluetooth:**
- Settings → Bluetooth → Turn On → Pair devices

**Displays:**
- Settings → Displays → Arrange monitors, resolution, scaling

**Printers:**
- Settings → Printers → Add Printer

**Users:**
- Settings → Users → Add/Remove users, change permissions

**Date & Time:**
- Settings → Date & Time → Automatic/Manual timezone

**Power:**
- Settings → Power → Screen timeout, suspend settings

### 5.2 KDE System Settings

```bash
# Open System Settings
systemsettings5

# Categories:
# - Appearance: Themes, colors, icons, fonts
# - Workspace Behavior: Desktop effects, window management
# - Personalization: Notifications, applications
# - Network Settings: Connections, proxy
# - Hardware: Display, power, input devices
# - System Administration: Users, date/time, startup
```

---

## 6. Common GUI Applications

### 6.1 File Managers

**GNOME Files (Nautilus):**
```bash
nautilus                            # open file manager
nautilus /path/to/folder            # open specific folder
nautilus --version
```

**KDE Dolphin:**
```bash
dolphin
```

**Thunar (Xfce):**
```bash
thunar
```

**Connect to network share:**
- Files → Other Locations → Connect to Server
- `smb://server/share` (Windows)
- `sftp://user@host/path` (SSH)

### 6.2 Terminal Emulators

**GNOME Terminal:**
```bash
gnome-terminal
gnome-terminal -- bash -c "htop"    # run command
```

**Konsole (KDE):**
```bash
konsole
```

**Xfce Terminal:**
```bash
xfce4-terminal
```

**Terminator (advanced):**
```bash
sudo apt install terminator
terminator                          # split terminals
```

**Tilix:**
```bash
sudo apt install tilix
```

### 6.3 Text Editors (GUI)

**gedit (GNOME):**
```bash
gedit file.txt
```

**Kate (KDE):**
```bash
kate file.txt
```

**Mousepad (Xfce):**
```bash
mousepad file.txt
```

**VS Code:**
```bash
code file.txt
```

### 6.4 Web Browsers

**Firefox:**
```bash
firefox
firefox --new-tab https://example.com
firefox --private-window             # incognito
```

**Chromium/Chrome:**
```bash
chromium-browser
google-chrome
```

**Other browsers:**
- **Brave**: Privacy-focused
- **Vivaldi**: Feature-rich
- **Opera**: Fast, built-in VPN

### 6.5 Office Applications

**LibreOffice:**
```bash
sudo apt install libreoffice

# Individual apps
libreoffice --writer                # Word processor
libreoffice --calc                  # Spreadsheet
libreoffice --impress               # Presentations
libreoffice --draw                  # Vector graphics
libreoffice --base                  # Database
libreoffice --math                  # Formula editor
```

**ONLYOFFICE:**
```bash
sudo apt install onlyoffice-desktopeditors
```

### 6.6 Multimedia Applications

**Image Viewers:**
```bash
eog image.jpg                       # Eye of GNOME
gwenview image.jpg                  # KDE
ristretto image.jpg                 # Xfce
```

**Image Editors:**
```bash
sudo apt install gimp               # GIMP (Photoshop alternative)
sudo apt install inkscape           # Inkscape (Illustrator alternative)
```

**Video Players:**
```bash
sudo apt install vlc                # VLC
sudo apt install mpv                # MPV (minimal)
totem video.mp4                     # GNOME Videos
```

**Audio Players:**
```bash
rhythmbox                           # GNOME Music
sudo apt install audacious          # Winamp-like
sudo apt install clementine         # Feature-rich
```

---

## 7. Theming and Customization

### 7.1 GTK Themes

**Installing themes:**
```bash
# System-wide
sudo mkdir -p /usr/share/themes
sudo tar -xzf theme.tar.gz -C /usr/share/themes/

# User-specific
mkdir -p ~/.themes
tar -xzf theme.tar.gz -C ~/.themes/

# Apply theme (GNOME)
gsettings set org.gnome.desktop.interface gtk-theme 'Theme-Name'

# Popular themes
sudo apt install arc-theme          # Arc
sudo apt install numix-gtk-theme    # Numix
```

### 7.2 Icon Themes

**Installing icons:**
```bash
# System-wide
sudo mkdir -p /usr/share/icons
sudo tar -xzf icons.tar.gz -C /usr/share/icons/

# User-specific
mkdir -p ~/.icons
tar -xzf icons.tar.gz -C ~/.icons/

# Apply icons (GNOME)
gsettings set org.gnome.desktop.interface icon-theme 'Icon-Name'

# Popular icon themes
sudo apt install papirus-icon-theme
sudo apt install numix-icon-theme
```

### 7.3 Cursor Themes

```bash
# Install cursors
mkdir -p ~/.icons
tar -xzf cursor-theme.tar.gz -C ~/.icons/

# Apply (GNOME)
gsettings set org.gnome.desktop.interface cursor-theme 'Cursor-Name'
```

---

## 8. Troubleshooting Graphical Issues

### 8.1 Graphics Drivers

**Check current driver:**
```bash
lspci -k | grep -A 3 -i "vga\|3d"   # show graphics card and driver
lsmod | grep -i video               # loaded video modules

# NVIDIA
nvidia-smi                          # NVIDIA System Management Interface
```

**Install NVIDIA drivers:**
```bash
# Ubuntu
sudo ubuntu-drivers devices         # list available drivers
sudo ubuntu-drivers autoinstall     # auto-install recommended
# Or manually:
sudo apt install nvidia-driver-525

# Arch
sudo pacman -S nvidia nvidia-utils
```

**Install AMD drivers:**
```bash
# Open source (usually pre-installed)
sudo apt install xserver-xorg-video-amdgpu

# Proprietary AMDGPU-PRO (if needed)
# Download from AMD website
```

**Intel drivers (usually built-in):**
```bash
sudo apt install xserver-xorg-video-intel
```

### 8.2 Fix Broken Desktop

**Restart desktop environment:**
```bash
# GNOME
killall -3 gnome-shell              # restart shell (Wayland)
# Or Alt+F2, type 'r', press Enter  # restart (X11)

# KDE
kquitapp5 plasmashell && kstart5 plasmashell

# Reconfigure X
sudo dpkg-reconfigure xserver-xorg
```

**Reset to defaults:**
```bash
# GNOME
dconf reset -f /org/gnome/
# Or
mv ~/.config/dconf ~/.config/dconf.backup

# KDE
mv ~/.config/plasma* ~/.config/plasma-backup
mv ~/.config/kdedefaults ~/.config/kdedefaults.backup
```

**Boot to console:**
```bash
# At GRUB, add to kernel parameters:
systemd.unit=multi-user.target      # boot to console

# Or after login:
sudo systemctl set-default multi-user.target
sudo reboot

# Return to graphical:
sudo systemctl set-default graphical.target
```

---

## 9. Remote Desktop

### 9.1 VNC (Virtual Network Computing)

**Server setup:**
```bash
# Install
sudo apt install tigervnc-standalone-server

# Start VNC server
vncserver :1 -geometry 1920x1080 -depth 24
# First time: set password

# Stop server
vncserver -kill :1

# Configuration
~/.vnc/xstartup                     # startup script
```

**Client:**
```bash
sudo apt install tigervnc-viewer
vncviewer server-ip:5901            # :1 = port 5901
```

### 9.2 RDP (Windows Remote Desktop Protocol)

**xrdp server:**
```bash
sudo apt install xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Connect from Windows:
# Run 'mstsc', enter Linux IP
```

### 9.3 NoMachine

**Fast, feature-rich remote desktop:**
```bash
# Download from nomachine.com
sudo dpkg -i nomachine_*.deb
sudo systemctl start nxserver
```

---

## 10. Practice Exercises

1. **Display servers:**
   - Check if using X11 or Wayland
   - Switch between them
   - Configure display resolution with xrandr

2. **Desktop environments:**
   - Install a second DE (if GNOME, try Xfce)
   - Switch between DEs at login
   - Compare resource usage (htop)

3. **Customization:**
   - Install and apply a GTK theme
   - Install icon theme
   - Add GNOME extensions or KDE widgets

4. **GUI applications:**
   - Configure WiFi from GUI
   - Add a printer
   - Create user account from Settings

5. **Troubleshooting:**
   - Reset GNOME/KDE to defaults
   - Restart desktop shell
   - Set up VNC for remote access

Next: **Linux 19 – Text Editors Mastery** for vim, nano, and emacs.
