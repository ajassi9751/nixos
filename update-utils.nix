{writeShellScriptBin, bash}:
writeShellScriptBin "sup" ''
	# Collect garbage
	if [[ "$1" == "help" ]]; then
		echo -e "Arguments:\nhelp - display a helpful help message\ngc - run garbage collection\nboot - create a boot entry instead of switching\nnu - switch to a new configuration without updating\notherwise unrecognized arguments are used to update more inputs than just nixpkgs-unstable and nixpkgs-stable and no arguments updates and switches"
		exit 0
	elif [[ "$1" == "gc" ]]; then
		nix-collect-garbage -d
		exit 0
	fi
	# Should change for specific premissions
	# Make sure we are root
	if [[ $(whoami) != "root" ]]; then
		echo "This script was not executed as root, try again"
		exit 1
	fi
	# If you just want to update
	if [[ -z "$1" ]]; then
		cd /etc/nixos
		nix flake update nixpkgs-unstable nixpkgs-stable --commit-lock-file
		nixos-rebuild switch --upgrade --flake /etc/nixos#system
		exit 0
	# Create a boot entry instead of switching
	elif [[ "$1" == "boot" ]]; then
		cd /etc/nixos
		nix flake update nixpkgs-unstable nixpkgs-stable --commit-lock-file
		nixos-rebuild boot --upgrade --flake /etc/nixos#system
		exit 0
	# Stands for no update, doesn't update the packages, just switches
	elif [[ "$1" == "nu" ]]; then
		nixos-rebuild switch --flake /etc/nixos#system
	# Update any additional inputs
	else
		cd /etc/nixos
		nix flake update nixpkgs-unstable nixpkgs-stable "$@" --commit-lock-file
		nixos-rebuild switch --upgrade --flake /etc/nixos#system
		exit 0
	fi
''
