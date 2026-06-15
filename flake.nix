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

      man-pages = pkgs.callPackage "${nixLib}/man-pages.nix" {
        componentSrc = componentSrc "man";
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
          man-pages
          libcbgeneral
          libcbipc
          libcbtelos
          libcbtelosserver
          libcbcos
          ;
      };

      javaAppArgs = {
        jdk = pkgs.jdk25;
        inherit java-reactor man-pages;
      };

      cb-workbench = pkgs.callPackage "${nixLib}/cb-workbench.nix" javaAppArgs;
      cb-shell = pkgs.callPackage "${nixLib}/cb-shell.nix" javaAppArgs;
      cb-graph = pkgs.callPackage "${nixLib}/cb-graph.nix" javaAppArgs;

      cb-web = pkgs.callPackage "${nixLib}/cb-web.nix" {
        componentSrc = componentSrc "web";
        php = pkgs.php83;
      };

      examples-corpus = pkgs.callPackage "${nixLib}/examples-corpus.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = componentSrc "examples";
      };

      conceptbase = pkgs.callPackage "${nixLib}/conceptbase.nix" {
        inherit cbserver cb-workbench examples-corpus;
      };

      cb-testclient = pkgs.callPackage "${nixLib}/cb-testclient.nix" {
        componentSrc = componentSrc "cb-testclient";
        inherit (pkgs) coreutils bash gnused findutils perl;
        inherit cbserver cb-shell examples-corpus;
      };

      regression-tests = pkgs.callPackage "${nixLib}/regression-tests.nix" {
        inherit (pkgs) coreutils bash gnused findutils;
        jdk = pkgs.jdk25;
        inherit java-reactor cbserver cb-shell cb-testclient examples-corpus system-data howtosRoot;
      };

      integration-tests = pkgs.callPackage "${nixLib}/integration-tests.nix" {
        llvmPackages = pkgs.llvmPackages_latest;
        coreutils = pkgs.coreutils;
        findutils = pkgs.findutils;
        inherit cbserver cb-shell libcbc libcbcview examples-corpus;
      };

      # OCI image that runs the regression suite inside an isolated container
      # network namespace (port 4001 is container-local, never collides with
      # stray host servers). `nix build .#regression-container` streams it to
      # `docker load`; `docker run --rm` executes the tests.
      regression-container = pkgs.callPackage "${nixLib}/regression-container.nix" {
        inherit (pkgs) coreutils bash gnused findutils gnugrep procps;
        hostname = pkgs.unixtools.hostname;
        jdk = pkgs.jdk25;
        inherit java-reactor cbserver cb-shell cb-testclient examples-corpus system-data howtosRoot;
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

      howtosRoot = builtins.path {
        path = ./components/howtos;
        name = "howtos-root";
        filter = _path: _type: true;
      };

      howtoManualSrc = builtins.path {
        path = ./components;
        name = "howto-manual-src";
        filter = path: type:
          let
            root = toString ./components;
            rel = pkgs.lib.removePrefix (root + "/") (toString path);
          in
            rel == "doc/howto-manual.typ"
            || (type == "directory" && (rel == "doc" || rel == "howtos" || builtins.match "howtos/[^/]+" rel != null))
            || builtins.match "howtos/[^/]+/page\\.typ" rel != null;
      };

      howtoChecks = import "${nixLib}/howtos/default.nix" {
        stdenv = llvmStdenv;
        inherit cbserver howtosRoot;
        cbshell = cb-shell;
        cbgraph = cb-graph;
        xvfb-run = pkgs.xvfb;
        inherit (pkgs)
          lib
          coreutils
          bash
          gnugrep
          gnused
          findutils
          gawk
          ;
      };

      howtos = import "${nixLib}/howtos/howto-manual.nix" {
        stdenv = llvmStdenv;
        manualSrc = howtoManualSrc;
        inherit (pkgs) typst;
      };

      docSrc = componentSrc "doc";

      doc-user-manual = pkgs.callPackage "${nixLib}/doc-user-manual.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
        inherit (pkgs) typst;
      };

      doc-prog-manual = pkgs.callPackage "${nixLib}/doc-prog-manual.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
        inherit (pkgs) typst;
      };

      doc-tutorial = pkgs.callPackage "${nixLib}/doc-tutorial.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
        inherit (pkgs) typst;
      };

      doc-tech-info = pkgs.callPackage "${nixLib}/doc-tech-info.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
      };

      doc-developer = pkgs.callPackage "${nixLib}/doc-developer.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
      };

      doc-external-licenses = pkgs.callPackage "${nixLib}/doc-external-licenses.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
      };

      doc-logos = pkgs.callPackage "${nixLib}/doc-logos.nix" {
        stdenv = pkgs.stdenvNoCC;
        componentSrc = docSrc;
      };

      docs = pkgs.callPackage "${nixLib}/docs.nix" {
        inherit
          doc-user-manual
          doc-prog-manual
          doc-tutorial
          doc-tech-info
          doc-developer
          doc-external-licenses
          doc-logos
          ;
        howto-manual = howtos.howto-manual;
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
          cb-web
          mmkit
          docs
          regression-container
          ;
        default = conceptbase;
      };

      devShells.${system} = {
        default = llvmStdenv.mkDerivation {
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
            export CONCEPTBASE_NIX_DEVELOP_MARKER="$PWD/.nix-develop-shell"
            touch "$CONCEPTBASE_NIX_DEVELOP_MARKER"
            trap 'rm -f "$CONCEPTBASE_NIX_DEVELOP_MARKER"' EXIT
            echo "ConceptBase.cc dev shell"
            echo "  nix build                  # conceptbase (default)"
            echo "  nix run .#cbserver"
            echo "  nix run .#cb-workbench"
            echo "  ./scripts/sync-server-engine.sh"
            echo "  plantuml -tsvg docs/derivation-deps.puml   # derivation graph"
            echo "  See CONTRIBUTING.md"
          '';
        };

        mmkit = llvmStdenv.mkDerivation {
          name = "conceptbase-cc-mmkit-dev";
          dontBuild = true;
          nativeBuildInputs = with pkgs; [
            nodejs
            maven
            jdk25
            swi-prolog
            cbserver
          ];
          shellHook = ''
            export CONCEPTBASE_NIX_DEVELOP_MARKER="$PWD/.nix-develop-shell"
            touch "$CONCEPTBASE_NIX_DEVELOP_MARKER"
            trap 'rm -f "$CONCEPTBASE_NIX_DEVELOP_MARKER"' EXIT

            export CB_HOME=${cbserver}
            export CB_POOL=${cbserver}/share
            export CBS_DIR=${cbserver}/share/serverSources/Prolog_Files
            export CBL_DIR=${cbserver}/share/system-data
            export CB_VARIANT=""
            export MMKIT_REAL_CBSERVER_BIN=${cbserver}/bin/cbserver

            if [[ ! -x "$MMKIT_REAL_CBSERVER_BIN" ]]; then
              echo "ERROR: cbserver derivation is missing in this shell."
              echo "Hint: run 'nix develop .#mmkit' from repository root."
              return 1
            fi

            echo "ConceptBase.cc mmkit shell"
            echo "  cbserver: $MMKIT_REAL_CBSERVER_BIN"
            echo "  CB_HOME:  $CB_HOME"
            echo ""
            echo "  cd components/mmkit"
            echo "  npm install --workspaces --include=dev   # once"
            echo "  npm run test -w @mmkit/server            # mock unit tests"
            echo "  npm run test:cbserver:real -w @mmkit/server"
            echo "  # or: components/mmkit/packages/server/scripts/test-cbserver-real.sh"
          '';
        };
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
          doc-user-manual
          doc-prog-manual
          doc-tutorial
          doc-tech-info
          doc-developer
          doc-external-licenses
          doc-logos
          docs
          man-pages
          cb-web
          cb-testclient
          regression-tests
          ;
      } // howtoChecks // howtos;

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
