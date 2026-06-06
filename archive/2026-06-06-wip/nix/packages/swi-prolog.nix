# SWI-Prolog 6.6.6 — pinned, cached separately from ConceptBase sources.
{ lib, stdenv, fetchurl, pkg-config, autoconf, curl, chrpath, which, bash
, zlib, openssl, ncurses, readline, gmp, libarchive, libuuid, libjpeg, libXpm
, libXft, libXt, unixODBC, libxcrypt, gnumake
}:

stdenv.mkDerivation rec {
  pname = "swi-prolog";
  version = "6.6.6";

  src = fetchurl {
    url = "https://www.swi-prolog.org/download/stable/src/pl-${version}.tar.gz";
    sha256 = "0vcrfskm2hyhv30lxr6v261myb815jc3bgmcn1lgsc9g9qkvp04z";
  };

  nativeBuildInputs = [
    pkg-config autoconf curl chrpath which bash gnumake
  ];

  buildInputs = [
    zlib openssl ncurses readline gmp libarchive libuuid
    libjpeg libXpm libXft libXt unixODBC libxcrypt
  ];

  postPatch = ''
    # Configure compiles+executes probe binaries; use return 0 so probes link without exit().
    substituteInPlace src/configure \
      --replace-fail 'exit(0);' 'return 0;' \
      --replace-fail 'exit (0);' 'return 0;'

    # If all probes fail, fall back instead of aborting (Nix builder edge cases).
    substituteInPlace src/configure \
      --replace-fail 'as_fn_error $? "Cannot find a build system compiler"' \
      'CC_FOR_BUILD=''${CC_FOR_BUILD-gcc}'

    patchShebangs scripts
  '';

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    cp build.templ build
    substituteInPlace build --replace-fail 'PREFIX=$HOME' "PREFIX=$out${"\n"}export DISABLE_PKGS=\"jpl xpce\""
    substituteInPlace build --replace-fail "MAKE=make" "MAKE='make --jobs=''${NIX_BUILD_CORES:-1}'"
    patchShebangs build scripts
    chmod +x build
    bash ./build
    runHook postBuild
  '';

  postInstall = ''
    arch=$(uname -m)
    libdir="$out/lib/swipl-${version}/lib/$arch-linux"
    ln -sf "$out/bin/swipl" "$out/bin/pl"
    ln -sf "$out/bin/swipl-ld" "$out/bin/plld"
    ln -sf "$libdir/libswipl.a" "$libdir/libpl.a"
  '';

  meta = with lib; {
    description = "SWI-Prolog 6.6.6 (ConceptBase-compatible)";
    homepage = "https://www.swi-prolog.org/";
    license = licenses.mit;
    platforms = platforms.x86_64;
  };
}
