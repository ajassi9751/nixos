{writeShellScriptBin, bash}:
writeShellScriptBin "sup" ''
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
		nixos-rebuild switch --upgrade --flake /etc/nixos#system	
		exit 0
	fi
''
