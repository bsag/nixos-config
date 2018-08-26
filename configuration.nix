# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # This gets your audio output and input (mic) working
  boot.extraModprobeConfig = ''
    options libata.force=noncq
    options resume=/dev/sda5
    options snd_hda_intel index=0 model=intel-mac-auto id=PCH
    options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
    options snd_hda_intel model=mbp101
    options hid_apple fnmode=2
  '';
 
  # networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # CLI tools
    acpi psmisc xorg.xmodmap xorg.xev xsensors light
    neofetch wget scrot
    # ranger stuff
    ranger 
    file # to determine file types
    w3m # preview images
    highlight # syntax highlighting
    # Editors
    vim
    mutt
    git
    # shell
    zsh oh-my-zsh
    termite kitty rxvt_unicode-with-plugins
    # UI stuff
    dmenu rofi compton sxhkd 
    dunst libnotify # both required for notifications, with service below
    redshift
    polybar pango
    # X11
    firefox feh nitrogen
    qutebrowser
    qt5.qtwebengine
    zathura # PDF viewer
    xscreensaver xclip xorg.xev
    tlp # power managment
  ];

  fonts = {
	fontconfig.enable = true;
	fontconfig.hinting.autohint = true;
	fontconfig.antialias = true;
	enableFontDir = true;
	enableCoreFonts = true;
	enableGhostscriptFonts = true;
	fonts = with pkgs; [
		fira
		fira-code
		fira-mono
		ibm-plex
		overpass
		terminus_font_ttf
		nerdfonts
		source-code-pro
		font-awesome_5
		opensans-ttf
		roboto
		ubuntu_font_family
		];
	};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  
  # zsh/oh-my-zsh config
  programs = {
	bash.enableCompletion = true;
	zsh = {
		enable = true;
		enableAutosuggestions = true;
		ohMyZsh.enable = true;
		ohMyZsh.theme = "agnoster";
		shellAliases = {
			l = "ls -alh";
			ll = "ls -l";
			ls = "ls --color=tty";
			mkdir = "mkdir -p";
			};
		promptInit = "";
		};
	light.enable = true; # control backlight without sudo
	man.enable = true;
	qt5ct.enable = true;
  };
  
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Set environment variables that will work in all shells
  environment.interactiveShellInit = ''
	export XDG_CONFIG_HOME="$HOME/.config"
	export QT_QPA_CONFIG_HOME="qt5ct"
	BASE16_SHELL="$HOME/.config/base16-shell/"
	[ -n "$PS1" ] && \
		[ -s "$BASE16_SHELL/profile_helper.sh" ] && \
			eval "$("$BASE16_SHELL/profile_helper.sh")"
	export EDITOR=vim
	export VISUAL=vim
	export BROWSER=qutebrowser
 	'';		

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.tlp.enable = true; # tlp power management

  # DBUS services for things like Dunst
  services.dbus.socketActivated = true;

  # Enable the X11 windowing system.
  services.xserver = {
	enable = true;
	windowManager.bspwm.enable = true;
	dpi = 96;
	layout = "us";
	xkbOptions = "lv3:ralt_alt,terminate:ctrl_alt_bksp";
	xkbVariant = "mac";
        # Configure the macbook's touchpad
        libinput = {
		enable = true;
		tapping = true;
		clickMethod = "clickfinger";
		naturalScrolling = true;
        };
  };

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };
  users.extraUsers.bsag = {
	name = "bsag";
	group = "users";
	extraGroups = [
		"wheel" "disk" "audio" "video" "networkmanager" "systemd-journal"
	];
	createHome = true;
	home = "/home/bsag";
	shell = "/run/current-system/sw/bin/zsh";
  };

  # Services
  systemd.user.services."dunst" = {
	enable = true;
	description = "";
	wantedBy = [ "default.target" ];
	serviceConfig.Restart = "always";
	serviceConfig.RestartSec = 2;
	serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
