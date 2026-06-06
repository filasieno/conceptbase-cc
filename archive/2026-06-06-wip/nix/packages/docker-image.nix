# OCI image for ConceptBase.cc server trial (linux64).
{ lib, dockerTools, conceptbase, jdk11 }:

dockerTools.buildImage {
  name = "conceptbase-cc";
  tag = conceptbase.version;

  copyToRoot = [
    conceptbase
    (lib.getBin jdk11)
  ];

  config = {
    Cmd = [ "${conceptbase}/cbserver" "-port" "4001" "-d" "MYDB" ];
    Entrypoint = [ "${conceptbase}/docker-entrypoint.sh" ];
    ExposedPorts = { "4001/tcp" = { }; };
    Env = [
      "CB_HOME=${conceptbase}"
      "PATH=${conceptbase}/bin:${conceptbase}:${lib.getBin jdk11}/bin:/bin"
      "LD_LIBRARY_PATH=${conceptbase}/linux64/lib"
    ];
    WorkingDir = "/var/lib/conceptbase/data";
    Volumes = { "/var/lib/conceptbase/data" = { }; };
  };
}
