{ pkgs, src }:

let
  inherit (pkgs) callPackage;

  swi-prolog = callPackage ./swi-prolog.nix { };
  cb-make = callPackage ./cb-make.nix { };
  java-deps = callPackage ./java-deps.nix { };

  serverPatches = import ./patches.nix {
    inherit swi-prolog;
    openjdk11 = pkgs.openjdk11;
    clang = pkgs.clang;
  };

  maven-local-repo = callPackage ./maven-local-repo.nix {
    inherit java-deps;
  };

  mkJavaModule = module: artifactId: mavenRepos:
    callPackage ./conceptbase-java-module.nix {
      inherit src module artifactId mavenRepos;
      maven = pkgs.maven;
      jdk11 = pkgs.jdk11;
    };

  java-common = mkJavaModule "common" "conceptbase-java-common" [ maven-local-repo ];
  java-api = mkJavaModule "api" "conceptbase-java-api" [ maven-local-repo java-common ];
  java-telos = mkJavaModule "telos" "conceptbase-java-telos" [ maven-local-repo java-common java-api ];
  java-graph = mkJavaModule "graph" "conceptbase-java-graph" [
    maven-local-repo java-common java-api java-telos
  ];
  java-workbench = mkJavaModule "workbench" "conceptbase-java-workbench" [
    maven-local-repo java-common java-api java-telos java-graph
  ];

  java-distribution = callPackage ./conceptbase-java-distribution.nix {
    inherit src;
    maven = pkgs.maven;
    jdk11 = pkgs.jdk11;
    mavenRepos = [
      maven-local-repo
      java-common
      java-api
      java-telos
      java-graph
      java-workbench
    ];
  };

  conceptbase-server = callPackage ./conceptbase-server.nix {
    inherit src swi-prolog cb-make serverPatches;
    openjdk11 = pkgs.openjdk11;
  };

  conceptbase-clients = callPackage ./conceptbase-clients.nix {
    inherit java-distribution;
    jdk11 = pkgs.jdk11;
  };

  conceptbase = callPackage ./conceptbase.nix {
    inherit src conceptbase-server java-distribution;
    jdk11 = pkgs.jdk11;
  };

  docker-image = callPackage ./docker-image.nix {
    inherit conceptbase;
    jdk11 = pkgs.jdk11;
  };
in
{
  inherit
    swi-prolog
    cb-make
    java-deps
    maven-local-repo
    java-common
    java-api
    java-telos
    java-graph
    java-workbench
    java-distribution
    conceptbase-server
    conceptbase-clients
    conceptbase
    docker-image
    ;
}
