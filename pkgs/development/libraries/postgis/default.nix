args@{fetchurl, composableDerivation, stdenv, perl, libxml2, postgresql, geos, proj, flex, gdal, pkgconfig, file, ...}:

  /*

  ### NixOS - usage:
  ==================

    services.postgresql.extraPlugins = [ (pkgs.postgis.override { postgresql = pkgs.postgresql94; }).v_2_1_4 ];


  ### important Postgis implementation details:
  =============================================

    Postgis provides a shared library implementing many operations. They are
    exposed to the Postgres SQL interpreter by special SQL queries eg:

      CREATE FUNCTION [...]
              AS '[..]liblwgeom', 'lwhistogram2d_in' LANGUAGE 'C' IMMUTABLE STRICT; -- WITH (isstrict);

   where liblwgeom is the shared library.
   Postgis < 1.5 used absolute paths, in NixOS $libdir is always used.

   Thus if you want to use postgresql dumps which were created by non NixOS
   systems you have to adopt the library path.


   ### TODO:
   =========
   the bin commands to have gtk gui:
  */


let
  pgDerivationBase = composableDerivation.composableDerivation {} ( fix :

  let version = fix.fixed.version; in {

    name = "postgis-${version}";

    src = fetchurl {
      url = "http://postgis.refractions.net/download/postgis-${fix.fixed.version}.tar.gz";
      inherit (fix.fixed) sha256;
    };

    # don't pass these vars to the builder
    removeAttrs = ["hash" "sql_comments" "sql_srcs"];

    preConfigure = ''
      configureFlags="--datadir=$out/share --datarootdir=$out/share --bindir=$out/bin"
      makeFlags="PERL=${perl}/bin/perl datadir=$out/share pkglibdir=$out/lib bindir=$out/bin"
    '';

    # create aliases for all commands adding version information
    postInstall = ''

      sql_srcs=$(for sql in ${builtins.toString fix.fixed.sql_srcs}; do echo -n "$(find $out -iname "$sql") "; done )

      for prog in $out/bin/*; do # */
        ln -s $prog $prog-${version}
      done

      cp -r doc $out
    '';

    buildInputs = [libxml2 postgresql geos proj perl];

    sql_comments = "postgis_comments.sql";

    meta = {
      description = "Geographic Objects for PostgreSQL";
      homepage = "http://postgis.refractions.net";
      license = stdenv.lib.licenses.gpl2;
      maintainers = [stdenv.lib.maintainers.marcweber];
      platforms = stdenv.lib.platforms.linux;
    };
  });

  pgDerivationBaseNewer = pgDerivationBase.merge (fix: {
    src = fetchurl {
      url = "http://download.osgeo.org/postgis/source/postgis-${builtins.toString fix.fixed.version}.tar.gz";
      inherit (fix.fixed) sha256;
    };
  });

in rec {

  v_2_1_4 = pgDerivationBaseNewer.merge ( fix : {
    version = "2.1.4";
    sha256 = "1z00n5654r7l38ydkn2grbwl5gg0mravjwxfdipp7j18hjiw4wyd";
    sql_srcs = ["postgis.sql" "spatial_ref_sys.sql"];
    builtInputs = [gdal pkgconfig];
    dontDisableStatic = true;
    preConfigure = ''
      sed -i 's@/usr/bin/file@${file}/bin/file@' configure
      configureFlags="$configureFlags --with-gdalconfig=${gdal}/bin/gdal-config"
    '';
    postConfigure = ''
      sed -i "s|@mkdir -p \$(DESTDIR)\$(PGSQL_BINDIR)||g ;
              s|\$(DESTDIR)\$(PGSQL_BINDIR)|$prefix/bin|g
              " \
          "raster/loader/Makefile";
      sed -i "s|\$(DESTDIR)\$(PGSQL_BINDIR)|$prefix/bin|g
              " \
          "raster/scripts/python/Makefile";
    '';
  });

}