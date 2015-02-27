{ faust
, gtk
, jack2
, opencv
}:

faust.wrapWithBuildEnv {

  appl = "faust2jack";

  propagatedBuildInputs = [
    gtk
    jack2
    opencv
  ];

}
