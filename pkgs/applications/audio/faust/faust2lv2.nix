{ faust
, lv2
}:

faust.wrapWithBuildEnv {

  appl = "faust2lv2";

  propagatedBuildInputs = [ lv2 ];

}
