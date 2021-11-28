(use-modules
 (gnu)
 (gnu packages shells)
 (gnu packages databases)
 ;; Import nonfree linux module.
 (nongnu packages linux)
 (nongnu system linux-initrd)
 ((gnu services audio) #:select (mpd-service-type mpd-configuration mpd-output)))

(use-service-modules desktop networking ssh xorg docker databases)

(define username "bbsl")
(define hostname "guix")
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
 (host-name hostname)
 (users
  (cons*
   (user-account
    (name username)
    (shell #~(string-append #$fish "/bin/fish"))
    (group "users")
    (home-directory (string-append "/home/" username))
    (supplementary-groups
     '("wheel" "netdev" "audio" "video" "docker")))
   %base-user-accounts))
 (packages
  (append
   (list
    ;; desktop
    ;;; fonts
    (specification->package "font-terminus")
    (specification->package "font-inconsolata")
    ;;; wm
    (specification->package "i3-wm")
    (specification->package "i3status")
    (specification->package "rofi")
    (specification->package "lemonbar")
    (specification->package "dmenu")
;;    (specification->package "bspwm")
;;    (specification->package "sxhkd")
    (specification->package "lxrandr")
    ;; media
    (specification->package "lynx")
    (specification->package "firefox")
    (specification->package "alsa-utils")
    ;; terms
    (specification->package "fish")
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
    (specification->package "gcc-toolchain")
    (specification->package "make")
    ;; tools
    (specification->package "tree")
    (specification->package "acpi")
    (specification->package "the-silver-searcher")
    (specification->package "ripgrep")
    (specification->package "curl")
    (specification->package "wget")
    (specification->package "ispell")
    (specification->package "git")
    (specification->package "nss-certs"))
    (specification->package "mc"))
   %base-packages))
 (services
  (append
   (list
    (service docker-service-type)
    (service openssh-service-type)
    ;; music and mpd directories has to be created
    (service mpd-service-type
             (mpd-configuration
              (user username)
              (music-dir "~/music")
              (playlist-dir "~/.config/mpd/playlists")
              (db-file "~/.config/mpd/database")
              (state-file "~/.config/mpd/state")
              (sticker-file "~/.config/mpd/sticker.sql")
              (outputs
               (list (mpd-output
                      (type "alsa"))))))
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
   (targets (list "/boot/efi"))
   (keyboard-layout my-keyboard-layout)))
 (file-systems
  (cons*
   (file-system
    (mount-point "/boot/efi")
    (device
     (uuid "9035-4876" 'fat32))
    (type "vfat"))
   (file-system
    (mount-point "/")
    (device
     (uuid "3efe3cfc-1705-4395-86c7-0e90d397f5de"
           'ext4))
    (type "ext4"))
   %base-file-systems)))
