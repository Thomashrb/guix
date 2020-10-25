(use-modules
 (gnu)
 (gnu packages shells)
 (gnu packages databases)
 ;; Import nonfree linux module.
 (nongnu packages linux)
 (nongnu system linux-initrd))

(use-service-modules desktop networking ssh xorg docker databases)

(define my-keyboard-layout
  (keyboard-layout "no" "nodeadkeys" #:options '("ctrl:nocaps")))

(operating-system
 ;; Use nonfree firmware and drivers
 (kernel linux)
 (initrd microcode-initrd)
 (firmware
  (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "Europe/Brussels")
 (keyboard-layout my-keyboard-layout)
 (host-name "guix")
 (users
  (cons*
   (user-account
    (name "bbsl")
    (comment "Bbsl")
    (shell #~(string-append #$zsh "/bin/zsh"))
    (group "users")
    (home-directory "/home/bbsl")
    (supplementary-groups
     '("wheel" "netdev" "audio" "video" "docker")))
   %base-user-accounts))
 (packages
  (append
   (list
    ;; desktop
    ;;; fonts
    (specification->package "xset")
    (specification->package "xlsfonts")
    (specification->package "fontconfig")
    (specification->package "font-terminus")
    (specification->package "font-inconsolata")
    ;;; wm
    (specification->package "i3-wm")
    (specification->package "i3status")
    (specification->package "dmenu")
    (specification->package "rofi")
    (specification->package "lemonbar")
    (specification->package "bspwm")
    (specification->package "sxhkd")
    (specification->package "lxrandr")
    ;; media
    (specification->package "lynx")
    (specification->package "firefox")
    ;; terms
    (specification->package "zsh")
    (specification->package "zsh-autosuggestions")
    (specification->package "st")
    (specification->package "alacritty")
    ;; editors
    (specification->package "tmux")
    (specification->package "emacs")
    (specification->package "vim")
    ;; develop
    (specification->package "docker")
    (specification->package "docker-cli")
    (specification->package "flatpak")
    (specification->package "elixir")
    (specification->package "erlang")
    (specification->package "openjdk")
    (specification->package "rust")
    (specification->package "gcc-toolchain")
    (specification->package "make")
    ;; tools
    (specification->package "xrdb")
    (specification->package "setxkbmap")
    (specification->package "tree")
    (specification->package "acpi")
    (specification->package "the-silver-searcher")
    (specification->package "curl")
    (specification->package "wget")
    (specification->package "ispell")
    (specification->package "git")
    (specification->package "nss-certs"))
   %base-packages))
 (services
  (append
   (list
    (service docker-service-type)
    (service openssh-service-type)
    (service postgresql-service-type
             (postgresql-configuration
              (postgresql postgresql-11)
              (config-file
               (postgresql-config-file
                (hba-file
                 (plain-file "pg_hba.conf"
                             "
local	all	all                 trust
host	all	all	127.0.0.1/32    trust
host	all	all	::1/128         md5"))))))

    (set-xorg-configuration
     (xorg-configuration
      (keyboard-layout my-keyboard-layout))))
   %desktop-services))
 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (target "/boot/efi")
   (keyboard-layout my-keyboard-layout)))
 (swap-devices
  (list "/dev/sda2"))
 (file-systems
  (cons*
   (file-system
    (mount-point "/boot/efi")
    (device
     (uuid "FADC-D519" 'fat32))
    (type "vfat"))
   (file-system
    (mount-point "/")
    (device
     (uuid "da1c3b89-23eb-4d5d-9f34-02f4a10550cd"
           'ext4))
    (type "ext4"))
   %base-file-systems)))
