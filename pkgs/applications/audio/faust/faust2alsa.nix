{ faust
, alsaLib
, atk
, cairo
, fontconfig
, freetype
, gdk_pixbuf
, glib
, gtk
, pango
}:

faust.mkFaust2Appl {

  appl = "faust2alsa";

  propagatedBuildInputs = [
    alsaLib
    atk
    cairo
    fontconfig
    freetype
    gdk_pixbuf
    glib
    gtk
    pango
  ];

}
