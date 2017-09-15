{ native }:
let
  nixpkgs = native.nixpkgs;

  arch = "x86_64";

  host = "${arch}-apple-darwin15";

  os = "macos";

  compiler = "clang";

  exe_suffix = "";

  clang_version = "5.0.0";

  clang_src = nixpkgs.fetchurl {
    url = "https://llvm.org/releases/${clang_version}/cfe-${clang_version}.src.tar.xz";
    sha256 = "0w09s8fn3lkn6i04nj0cisgp821r815fk5b5fjn97xrd371277q1";
  };

  llvm_src = nixpkgs.fetchurl {
    url = "https://llvm.org/releases/${clang_version}/llvm-${clang_version}.src.tar.xz";
    sha256 = "1nin64vz21hyng6jr19knxipvggaqlkl2l9jpd5czbc4c2pcnpg3";
  };

  osxcross = ./osxcross;

  sdk = ./macsdk.tar.xz;

  cctools_src = nixpkgs.fetchurl {
    url = "https://github.com/tpoechtrager/cctools-port/archive/22ebe72.tar.gz";
    sha256 = "1pmn2iyw00ird3ni53wl05p3lm3637jyfmq393fx59495wnyxpgf";
  };

  cctools = native.make_derivation {
    name = "cctools";
    builder = ./cctools_builder.sh;
    src = cctools_src;
    configure_flags = "--target=${host}";
    native_inputs = [ nixpkgs.clang ];
  };

  xar_src = nixpkgs.fetchurl {
    url = "https://github.com/downloads/mackyle/xar/xar-1.6.1.tar.gz";
    sha256 = "0ghmsbs6xwg1092v7pjcibmk5wkyifwxw6ygp08gfz25d2chhipf";
  };

  xar = native.make_derivation {
    name = "xar";
    builder = ./xar_builder.sh;
    src = xar_src;
    native_inputs = [
      nixpkgs.libxml2.dev
      nixpkgs.openssl.dev
      nixpkgs.zlib.dev
      nixpkgs.pkgconfig
    ];
  };

  clang = native.make_derivation {
    name = "clang";
    builder = ./clang_builder.sh;
    version = clang_version;
    src = clang_src;
    inherit llvm_src;
    patches = [ ./clang_megapatch.patch ];
    native_inputs = [ nixpkgs.python2 ];
    cmake_flags =
      "-DCMAKE_BUILD_TYPE=Release " +
      # "-DCMAKE_BUILD_TYPE=Debug " +
      "-DLLVM_ENABLE_ASSERTIONS=OFF";
  };

  toolchain = native.make_derivation {
    name = "mac-toolchain";
    builder = ./builder.sh;
    inherit host osxcross sdk;
    native_inputs = [ clang cctools xar ];
  };

  cmake_toolchain = import ../cmake_toolchain {
    cmake_system_name = "Darwin";
    inherit nixpkgs host;
  };

  crossenv = {
    # Target info variables.
    inherit host arch os compiler exe_suffix;

    # Cross-compiling toolchain.
    inherit toolchain;
    toolchain_inputs = [ toolchain ];

    # Build tools and variables to support them.
    inherit cmake_toolchain;

    # nixpkgs: a wide variety of programs and build tools.
    inherit nixpkgs;

    # Some native build tools made by nixcrpkgs.
    inherit native;

    inherit clang cctools xar;

    make_derivation = import ../make_derivation.nix nixpkgs crossenv;
  };
in
  crossenv
