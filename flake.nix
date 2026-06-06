{
  description = "ConceptBase.cc — Linux greenfield build (independent components)";
  # tree-sitter-conceptbase component (grammar)

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      llvmStdenv = pkgs.llvmPackages_latest.stdenv;

      componentSrc = name:
        builtins.path {
          path = ./components/${name};
          name = name;
          filter = _path: _type: true;
        };

      cmakeModulesSrc = builtins.path {
        path = ./components/buildcbutils;
        name = "buildcbutils-src";
        filter = _path: _type: true;
      };

      nixLib = builtins.path {
        path = ./nix;
        name = "libcb-nix";
        filter = _path: _type: true;
      };

      buildcbutils = pkgs.callPackage "${nixLib}/buildcbutils.nix" {
        stdenv = llvmStdenv;
        inherit cmakeModulesSrc;
      };

      libcbArgs = {
        inherit buildcbutils;
        stdenv = llvmStdenv;
      };

      libcbgeneral = pkgs.callPackage "${nixLib}/libcbgeneral.nix" {
        stdenv = llvmStdenv;
        componentSrc = componentSrc "libcbgeneral";
        swi-prolog = pkgs.swi-prolog;
      };

      libcbipc = pkgs.callPackage "${nixLib}/libcbipc.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbipc";
        swi-prolog = pkgs.swi-prolog;
        inherit libcbgeneral;
      });

      libcbtelos = pkgs.callPackage "${nixLib}/libcbtelos.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbtelos";
        swi-prolog = pkgs.swi-prolog;
        inherit libcbgeneral;
      });

      libcbtelosserver = pkgs.callPackage "${nixLib}/libcbtelosserver.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbtelosserver";
        swi-prolog = pkgs.swi-prolog;
        inherit libcbgeneral libcbtelos;
      });

      libcbcos = pkgs.callPackage "${nixLib}/libcbcos.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbcos";
        swi-prolog = pkgs.swi-prolog;
        inherit libcbgeneral;
      });

      libcbc = pkgs.callPackage "${nixLib}/libcbc.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbc";
      });

      libcbcview = pkgs.callPackage "${nixLib}/libcbcview.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbcview";
        inherit libcbc;
      });

      libcbtelosclient = pkgs.callPackage "${nixLib}/libcbtelosclient.nix" (libcbArgs // {
        componentSrc = componentSrc "libcbtelosclient";
      });

      server-repl = pkgs.callPackage "${nixLib}/server-repl.nix" {
        componentSrc = componentSrc "server-repl";
        stdenv = llvmStdenv;
        swi-prolog = pkgs.swi-prolog;
        llvmPackages = pkgs.llvmPackages_latest;
        inherit libcbgeneral libcbipc libcbtelos libcbtelosserver libcbcos;
      };

      grammar-compiler = pkgs.callPackage "${nixLib}/grammar-compiler.nix" {
        stdenv = llvmStdenv;
        componentSrc = componentSrc "grammar-compiler";
        swi-prolog = pkgs.swi-prolog;
      };

      tree-sitter-conceptbase-pkgs = pkgs.callPackage "${nixLib}/tree-sitter-conceptbase.nix" {
        stdenv = llvmStdenv;
        componentSrc = componentSrc "tree-sitter-conceptbase";
        inherit (pkgs) tree-sitter nodejs pkg-config runCommandLocal;
      };

      tree-sitter-conceptbase-lib = tree-sitter-conceptbase-pkgs.library;
      tree-sitter-conceptbase-telos = tree-sitter-conceptbase-pkgs.languages.telos;
      tree-sitter-conceptbase-assertions = tree-sitter-conceptbase-pkgs.languages.assertions;
      tree-sitter-conceptbase-ecarules = tree-sitter-conceptbase-pkgs.languages.ecarules;
      tree-sitter-conceptbase-examples = tree-sitter-conceptbase-pkgs.languages.examples;
      tree-sitter-conceptbase-encoding = tree-sitter-conceptbase-pkgs.languages.encoding;
      tree-sitter-conceptbase = tree-sitter-conceptbase-pkgs.aggregate;

      mmkit = pkgs.callPackage "${nixLib}/mmkit.nix" {
        componentSrc = componentSrc "mmkit";
        inherit (pkgs) vsce nodejs;
      };

      java-deps = pkgs.callPackage "${nixLib}/java-deps.nix" { };

      legacy-maven-src = pkgs.callPackage "${nixLib}/legacy-maven-src.nix" {
        inherit componentSrc;
      };

      java-reactor-src = pkgs.callPackage "${nixLib}/java-reactor-src.nix" {
        inherit componentSrc;
      };

      java-legacy-maven-lock = pkgs.callPackage "${nixLib}/java-legacy-maven-lock.nix" {
        stdenv = pkgs.stdenvNoCC;
        inherit legacy-maven-src;
        jdk = pkgs.jdk25;
        maven = pkgs.maven;
      };

      jgl = pkgs.callPackage "${nixLib}/jgl.nix" {
        stdenv = pkgs.stdenvNoCC;
        inherit legacy-maven-src java-legacy-maven-lock;
        jdk = pkgs.jdk25;
        maven = pkgs.maven;
      };

      grappa = pkgs.callPackage "${nixLib}/grappa.nix" {
        stdenv = pkgs.stdenvNoCC;
        inherit legacy-maven-src java-legacy-maven-lock;
        jdk = pkgs.jdk25;
        maven = pkgs.maven;
      };

      java-maven-local-repo = pkgs.callPackage "${nixLib}/java-maven-local-repo.nix" {
        inherit java-deps;
      };

      java-maven-lock = pkgs.callPackage "${nixLib}/java-maven-lock.nix" {
        stdenv = pkgs.stdenvNoCC;
        inherit java-reactor-src java-maven-local-repo;
        jdk = pkgs.jdk25;
        maven = pkgs.maven;
      };

      java-reactor = pkgs.callPackage "${nixLib}/java.nix" {
        stdenv = llvmStdenv;
        inherit java-reactor-src java-maven-lock;
        jdk = pkgs.jdk25;
        maven = pkgs.maven;
      };

      module-preprocessor = pkgs.callPackage "${nixLib}/module-preprocessor.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = componentSrc "module-preprocessor";
        jdk = pkgs.jdk25;
        inherit java-reactor;
      };

      server-engine = pkgs.callPackage "${nixLib}/server-engine.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = componentSrc "server-engine";
        inherit grammar-compiler;
      };

      system-data = pkgs.callPackage "${nixLib}/system-data.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = componentSrc "system-data";
      };

      cbserver = pkgs.callPackage "${nixLib}/cbserver.nix" {
        componentSrc = componentSrc "cbserver";
        stdenv = llvmStdenv;
        swi-prolog = pkgs.swi-prolog;
        llvmPackages = pkgs.llvmPackages_latest;
        inherit (pkgs) coreutils findutils;
        inherit
          server-repl
          server-engine
          system-data
          libcbgeneral
          libcbipc
          libcbtelos
          libcbtelosserver
          libcbcos
          ;
      };

      javaAppArgs = {
        jdk = pkgs.jdk25;
        inherit java-reactor;
      };

      cb-workbench = pkgs.callPackage "${nixLib}/cb-workbench.nix" javaAppArgs;
      cb-shell = pkgs.callPackage "${nixLib}/cb-shell.nix" javaAppArgs;
      cb-graph = pkgs.callPackage "${nixLib}/cb-graph.nix" javaAppArgs;

      examples-corpus = pkgs.callPackage "${nixLib}/examples-corpus.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = componentSrc "examples";
      };

      conceptbase = pkgs.callPackage "${nixLib}/conceptbase.nix" {
        inherit cbserver cb-workbench examples-corpus;
      };

      integration-tests = pkgs.callPackage "${nixLib}/integration-tests.nix" {
        llvmPackages = pkgs.llvmPackages_latest;
        coreutils = pkgs.coreutils;
        findutils = pkgs.findutils;
        inherit cbserver libcbc libcbcview examples-corpus;
      };

      no-ant = pkgs.callPackage "${nixLib}/no-ant.nix" {
        componentsSrc = builtins.path {
          path = ./components;
          name = "components";
          filter = _path: _type: true;
        };
        nixSrc = nixLib;
        scriptsSrc = builtins.path {
          path = ./scripts;
          name = "scripts";
          filter = _path: _type: true;
        };
        flakeSrc = builtins.path {
          path = ./flake.nix;
          name = "flake.nix";
          filter = _path: _type: true;
        };
      };

    in
    {
      packages.${system} = {
        inherit
          conceptbase
          cbserver
          cb-workbench
          cb-shell
          cb-graph
          mmkit
          ;
        default = conceptbase;
      };

      devShells.${system}.default = llvmStdenv.mkDerivation {
        name = "conceptbase-cc-dev";
        dontBuild = true;
        nativeBuildInputs = with pkgs; [
          llvmPackages_latest.clang
          cmake
          ninja
          pkg-config
          bison
          flex
          swi-prolog
          tree-sitter
          nodejs
          maven
          jdk25
          plantuml
          graphviz
        ];
        shellHook = ''
          export CC=clang
          export CXX=clang++
          echo "ConceptBase.cc dev shell"
          echo "  nix build                  # conceptbase (default)"
          echo "  nix run .#cbserver"
          echo "  nix run .#cb-workbench"
          echo "  ./scripts/sync-server-engine.sh"
          echo "  plantuml -tsvg docs/derivation-deps.puml   # derivation graph"
          echo "  See CONTRIBUTING.md"
        '';
      };

      checks.${system} = {
        inherit
          no-ant
          libcbc
          libcbcview
          libcbtelosclient
          server-repl
          grammar-compiler
          tree-sitter-conceptbase
          tree-sitter-conceptbase-lib
          tree-sitter-conceptbase-telos
          tree-sitter-conceptbase-assertions
          tree-sitter-conceptbase-ecarules
          tree-sitter-conceptbase-examples
          tree-sitter-conceptbase-encoding
          mmkit
          module-preprocessor
          server-engine
          system-data
          jgl
          grappa
          java-reactor
          cbserver
          cb-workbench
          cb-shell
          cb-graph
          examples-corpus
          integration-tests
          conceptbase
          ;
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
