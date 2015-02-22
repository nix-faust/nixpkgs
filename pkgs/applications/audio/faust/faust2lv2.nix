{ faust
, lv2
}:

faust.mkFaust2Appl {

  appl = "faust2lv2";

  propagatedBuildInputs = [ lv2 ];

}
