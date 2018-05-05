{ stdenv, fetchFromGitHub, ApplicationServices, Carbon, Cocoa
, withTiling ? false
, withBorder ? false
, withFfm ? false
}
:
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "chunkwm";

  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "chunkwm";
    rev = "v${version}";
    sha256 = "0bj704dpvsjhxbg07nm1bipijd3lcvhm83vsscidpbgp21rv6gzp";
  };

  buildInputs = [ ApplicationServices Carbon Cocoa ];

  buildPhase = ''
    make install BUILD_FLAGS="-O2 -std=c++11 -Wall -Wno-deprecated"
    cd src/chunkc
    make
    cd ../../
  '' + optionalString withTiling ''
    cd src/plugins/tiling
    make install
    cd ../../../
  '' + optionalString withBorder ''
    cd src/plugins/border
    make install
    cd ../../../
  '' + optionalString withFfm ''
    cd chunkwm/src/plugins/ffm
    make install
    cd ../../../
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/plugins
    mkdir -p $out/Library/LauchAgents

    cp bin/chunkwm $out/bin
    cp src/chunkc/bin/chunkc $out/bin
    cp ${./org.nixos.chunkwm.plist} $out/Library/LauchAgents
    substituteInPlace $out/Library/LaunchDaemons/org.nixos.chunkwm.plist --subst-var out
  '' + optionalString withTiling ''
     cp plugins/tiling.so $out/plugins
  '' + optionalString withBorder ''
     cp plugins/border.so $out/plugins
  '' + optionalString withFfm ''
     cp plugins/ffm.so $out/plugins
  '';

  meta = {
    description = "Tiling window manager for macOS based on plugin architecture";
    longDescription = ''
      chunkwm is a tiling window manager for macOS that uses a plugin architecture, successor to kwm. It represents windows as the leaves of a binary tree, and supports binary space partitioned, monocle and floating desktops.
    '';
    homepage = "https://github.com/koekeishiya/chunkwm";
    license = stdenv.lib.licenses.mit;
    maintainers = [ maintainers.periklis ];
    platforms = platforms.darwin;
  };
}
