# Builder for 'faust2appl' scripts, such as faust2alsa. These scripts
# run faust to generate cpp code, then invoke the compiler to build
# the code. This builder wraps these scripts in parts of the stdenv
# such that when the scripts are called outside any nix build, they
# behave as if they were running inside a nix build in terms of
# compilers and paths being configured.

# This function takes some packages as arguments and returns a second
# function.

{ stdenv
, faust
, makeWrapper
, pkgconfig }:

# The second function takes two args: the appl name (e.g.
# 'faust2alsa') and an optional list of propagatedBuildInputs. It
# returns a derivation that contains only the bin/${appl} script,
# wrapped up so that it will run as if it was inside a nix build with
# those build inputs.
#
# The build input 'faust' is automatically added to the propagatedBuildInputs.

{ appl
, propagatedBuildInputs ? [ ]
}:

stdenv.mkDerivation {

  name = "${appl}-${faust.version}";

  phases = [ "installPhase" "fixupPhase" ];

  buildInputs = [ makeWrapper pkgconfig ];

  propagatedBuildInputs = [ faust ] ++ propagatedBuildInputs;

  installPhase = ''
    # This exports parts of the stdenv, including gcc-wrapper, so that
    # faust2${appl} will build things correctly. For example, rpath is
    # set so that compiled binaries link to the libs inside the nix
    # store (run 'ldd' on the compilation result)
    makeWrapper "${faust}/${faust.appls}/${appl}" "$out/bin/${appl}" \
      --prefix PATH : "$PATH" \
      --prefix PKG_CONFIG_PATH : "$PKG_CONFIG_PATH" \
      --set NIX_CFLAGS_COMPILE "\"$NIX_CFLAGS_COMPILE\"" \
      --set NIX_LDFLAGS "\"$NIX_LDFLAGS\""
  '';

}
