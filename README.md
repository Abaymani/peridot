# PERIDOT(s)

Personal 'WIP' dotfiles for Arch/Hyprland using Quickshell.

## TODO

### Quickshell Widgets & Applets
**Topbar**
- [x] datetime display
- [x] Workspaces widget
- [x] MPRIS widget
- [ ] Network widget
- [ ] Resource monitor 
- [x] Update(s) widget
- [ ] Volume controls
- [x] Active window title
- [ ] [Workspace overview / alt-tab](https://www.windowslatest.com/wp-content/uploads/2020/07/Alt-Tab-with-browser-tabs.jpg)

**Calendar**
- [ ] Simple calendar view
- [ ] Google calendar / ical integration

**Misc.**
- [ ] Notification center
- [ ] Launcher (Rofi/Wofi replacement)
- [ ] Unified settings app
- [ ] On-screen Keyboard

### Scripts & Utils
- [ ] Screenshot utility
- [ ] Brightness utility
- [ ] Battery utility
- [ ] Matugen dark/light choice *(currently always dark)*

### Other
- [ ] Lockscreen / wlogout
- [ ] Greeter themeing

___

## Theming
Matugen is used extensively for theming. Some dependencies are required for GTK and Qt apps to apply themes correctly.

#### GTK
```
pacman -S adw-gtk-theme
```

#### Qt
```
yay -S breeze-icons breeze-gtk qt6ct-kde qt5ct-kde darkly-bin
```
> [!CAUTION]
> Qt apps may display dark text on dark backgrounds when using dark themes.

___

Since I don't have an install script (yet) and have multiple setups, here are all the packages I use. **Some are hard-referenced or assumed by scripts**.

**Packages:**

7zip
adw-gtk-theme
awww
base
base-devel
bibata-cursor-theme-bin
breeze-gtk
breeze-icons
cmake
darkly-bin
fastfetch
ffmpegthumbnailer
firefox
fish
figlet
flatpak
font-manager
frameworkintegration
fzf
git
gnome-calculator
gnome-text-editor
grim
gum
htop
hyprland
hyprpicker
iwd
jq
kitty
linux
linux-firmware
linux-headers
loupe
man-db
matugen
mesa-utils
mpv
nano
nautilus
ncdu
neovim
network-manager-applet
networkmanager
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
ntfs-3g
nvidia-580xx-dkms
nvidia-settings
nwg-displays
nwg-look
obs-studio
openssh
pavucontrol
pipewire-pulse
polkit-kde-agent
qbittorrent
qt5ct
qt6ct
quickshell
sddm
slurp
smartmontools
starship
sudo
swaync
sysstat
tldr
ttc-iosevka
unrar
unzip
uwsm
visual-studio-code-bin
vulkan-tools
waypaper-git
wget
wlr-randr
wofi
xclip
yay
yay-debug
yazi