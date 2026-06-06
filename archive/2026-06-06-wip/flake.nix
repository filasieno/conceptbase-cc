{
  description = "ConceptBase.cc — source-only Linux build (GitLab: mjeu/conceptbasecc)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      src = nixpkgs.lib.cleanSourceWith {
        src = ./.;
        filter = path: type:
          let base = builtins.baseNameOf path;
          in base != ".git"
          && base != "result"
          && base != "result-*"
          && base != "CVS"
          && !(type == "directory" && (base == ".direnv" || base == ".git" || base == "CVS"));
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          packages = import ./nix/packages { inherit pkgs src; };
        in
        {
          default = packages.conceptbase;

          # Toolchain / third-party (cached independently)
          swi-prolog = packages.swi-prolog;
          cb-make = packages.cb-make;
          java-deps = packages.java-deps;
          maven-local-repo = packages.maven-local-repo;

          # Java reactor modules (fine-grained)
          java-common = packages.java-common;
          java-api = packages.java-api;
          java-telos = packages.java-telos;
          java-graph = packages.java-graph;
          java-workbench = packages.java-workbench;
          java-distribution = packages.java-distribution;

          # Deployable artifacts
          conceptbase-server = packages.conceptbase-server;
          conceptbase-clients = packages.conceptbase-clients;
          conceptbase = packages.conceptbase;
          docker-image = packages.docker-image;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          packages = import ./nix/packages { inherit pkgs src; };
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ packages.conceptbase-server ];
            packages = with pkgs; [ maven jdk11 ];
            shellHook = ''
              export CB_LOCATION=DevShell
              export CB_WORK="$PWD/ProductPOOL"
              export CB_HOME="$PWD/.cb-install"
              export PATH="$PWD/AdminPOOL/bin:$CB_HOME:$PATH"
              mkdir -p "$CB_HOME" "$CB_WORK/java/lib"
              ln -sf ${packages.cb-make}/bin/make "$PWD/AdminPOOL/utils/make.linux64"
              export SWI_HOME=${packages.swi-prolog}
              export SWI_INCLUDE=''${SWI_HOME}/lib/swipl-${packages.swi-prolog.version}/include
              echo "ConceptBase.cc dev shell"
              echo "  nix build .#conceptbase-server   # native server"
              echo "  nix build .#java-distribution    # Maven clients"
              echo "  nix build                        # full install"
              echo "  mvn -f ProductPOOL/java/pom.xml package"
            '';
          };
        });

      apps = forAllSystems (system:
        let
          pkg = self.packages.${system}.default;
        in
        {
          cbserver = {
            type = "app";
            program = "${pkg}/cbserver";
          };
        });
    };
}
