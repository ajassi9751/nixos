{ stdenv, lib, fetchFromGitHub, nodejs, curl, makeWrapper, electron_40, pkgs, python3, jq, libusb1 }:

let
	electron-forge = pkgs.callPackage electron-forge.nix { };
	arch = "x64";
in

stdenv.mkDerivation rec {
	pname = "balena-etcher";
	version = "2.1.4";

	src = fetchFromGitHub {
		owner = "balena-io";
		repo = "etcher";
		rev = "v${version}";
		sha256 = "sha256-JQFdAWT12FdT5Y7XC9UY6D3TLhFG5QjnZhC8PGdK0vc=";
	};

	# If you used yarn2nix, pass packageJSON/yarnNix/yarnLock
	# packageJSON = ./package.json;
	# yarnNix = ./yarn.nix;

	nativeBuildInputs = [ makeWrapper ];

	buildInputs = [ electron_40 python3 libusb1 ];

	buildPhase = ''
		export ELECTRON_SKIP_BINARY_DOWNLOAD=1
		# point electron binary to nix's electron
		export ELECTRON_OVERRIDE_DIST_PATH="${electron_40}/bin"
		export NODE_ENV=production
		npm install --save-dev @electron-forge/cli
		npx electron-forge make --arch="${arch}"
		'';

	installPhase = ''
		mkdir -p $out/bin $out/lib/${pname}
		# copy built GUI (adjust to etcher's build output)
		cp -r dist/* $out/lib/${pname}/
		# wrapper that sets runtime env so electron from nixpkgs is used
		wrapProgram ${electron_40}/bin/electron \
		--set NODE_PATH $out/lib/${pname}/node_modules \
		--set XDG_DATA_DIRS ${electron_40}/share \
		--run-hook "cd $out/lib/${pname}"
		ln -s ${electron_40}/bin/electron $out/bin/etcher
	'';

	meta = with lib; {
		description = "A program to burn iso files to usb drives";
		license = licenses.mit;
		platforms = platforms.linux;
	};
}

