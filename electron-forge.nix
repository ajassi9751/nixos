{yarn, fetchFromGithub, stdenv}:
stdenv.mkDerivation rec {
	pname = "electron-forge";
	version = "7.11.1";
	src = fetchFromGithub {
		owner = "electron";
		repo = "forge";
		rev = "v${version}";
		hash = "";
	};
}
