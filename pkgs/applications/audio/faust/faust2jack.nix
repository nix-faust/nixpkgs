{ faust
, gtk
, jack2
, opencv
}:

faust.mkFaust2Appl {

  appl = "faust2jack";

  propagatedBuildInputs = [
    gtk
    jack2
    opencv
  ];

}
