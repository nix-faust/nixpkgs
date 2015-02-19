{ stdenv
, coreutils
, fetchgit
}:

let

  version = "8-1-2015";

  appls = "lib/faust/faust2appls";

in stdenv.mkDerivation rec {

  name = "faust-${version}";

  src = fetchgit {
    url = git://git.code.sf.net/p/faudiostream/code;
    rev = "4db76fdc02b6aec8d15a5af77fcd5283abe963ce";
    sha256 = "f1ac92092ee173e4bcf6b2cb1ac385a7c390fb362a578a403b2b6edd5dc7d5d0";
  };

  # Passthru some variables so other derivations can refer to them.
  #
  # ${faust.version}.
  #
  # ${faust}/${faust.appls} is a dir in which the unwrapped faust2appl
  # scripts are placed.
  passthru = {
    inherit appls version;
  };

  preConfigure = ''
    makeFlags="$makeFlags prefix=$out"

    # The faust makefiles use 'system ?= $(shell uname -s)' but nix
    # defines 'system' env var, so undefine that so faust detects the
    # correct system.
    unset system
  '';

  # Move all faust2* scripts into 'lib/faust/faust2appls' since they
  # won't run properly without additional paths setup.
  #
  # TODO: They are included in this package, but it might be better to
  # exclude them here and include them only in each specific
  # faust2alsa, etc.
  postInstall = ''
    mkdir "$out/${appls}"
    mv "$out"/bin/faust2* "$out/${appls}"
  '';

  postFixup = ''
    # For each faust2appl script, change so 'faustpath' and
    # 'faustoptflags' will be found by absolute paths.
    #
    # TODO: I noticed only some faust2appl scripts use these. The others
    # may need different modifications.
    for prog in "$out/${appls}"/*; do
      substituteInPlace "$prog" \
        --replace ". faustpath" ". '$out/bin/faustpath'" \
        --replace ". faustoptflags" ". '$out/bin/faustoptflags'"
    done

    # Set faustpath explicitly.
    substituteInPlace "$out"/bin/faustpath \
      --replace "/usr/local /usr /opt /opt/local" "$out"

    # Normally, I'd use makeWrapper to prefix the PATH variable with
    # ${coreutils}/bin, however 'faustoptflags' is 'source'd into
    # other faust scripts and not used as an executable, so patch
    # 'uname' usage directly.
    substituteInPlace "$out"/bin/faustoptflags \
      --replace uname "${coreutils}/bin/uname"
  '';

  meta = with stdenv.lib; {
    description = "A functional programming language for realtime audio signal processing";
    longDescription = ''
      FAUST (Functional Audio Stream) is a functional programming
      language specifically designed for real-time signal processing
      and synthesis. FAUST targets high-performance signal processing
      applications and audio plug-ins for a variety of platforms and
      standards.
      The Faust compiler translates DSP specifications into very
      efficient C++ code. Thanks to the notion of architecture,
      FAUST programs can be easily deployed on a large variety of
      audio platforms and plugin formats (jack, alsa, ladspa, maxmsp,
      puredata, csound, supercollider, pure, vst, coreaudio) without
      any change to the FAUST code.
      This package has just the compiler. Install faust for the full
      set of faust2somethingElse tools.
    '';
    homepage = http://faust.grame.fr/;
    downloadPage = http://sourceforge.net/projects/faudiostream/files/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.magnetophon ];
  };

}
