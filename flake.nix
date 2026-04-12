{
  description = "k8s-gitops image lock generator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }:
    let
      forAllSystems = f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system: f (import nixpkgs { inherit system; })
        );
      clustersDir = ./clusters;
      clusterNames =
        if builtins.pathExists clustersDir then
          builtins.attrNames (
            nixpkgs.lib.filterAttrs (_name: ty: ty == "directory") (builtins.readDir clustersDir)
          )
        else
          [ ];
      mkName = cluster: "gen-image-lock-${cluster}";
    in {
      packages = forAllSystems (pkgs: {
        gen-image-lock = pkgs.writeShellApplication {
          name = "gen-image-lock";
          runtimeInputs = with pkgs; [
            bash
            coreutils
            findutils
            fluxcd
            kustomize
            kubernetes-helm
            crane
            jq
            yq-go
            uv
            nix-prefetch-docker
          ];
          text = builtins.readFile ./scripts/gen-image-lock.sh;
        };
      }
      // builtins.listToAttrs (
        map (
          cluster:
          let
            wrappedName = mkName cluster;
            system = pkgs.stdenv.hostPlatform.system;
          in
          {
            name = wrappedName;
            value = pkgs.writeShellApplication {
              name = wrappedName;
              runtimeInputs = [ self.packages.${system}.gen-image-lock ];
              text = ''
                exec gen-image-lock --cluster ${pkgs.lib.escapeShellArg cluster} "$@"
              '';
            };
          }
        ) clusterNames
      )
      // {
        gen-image-lock-all = pkgs.writeShellApplication {
          name = "gen-image-lock-all";
          runtimeInputs = [ self.packages.${pkgs.stdenv.hostPlatform.system}.gen-image-lock ];
          text =
            if clusterNames == [ ] then
              ''
                echo "No clusters found under ./clusters"
              ''
            else
              ''
                set -euo pipefail
                clusters=( ${pkgs.lib.concatStringsSep " " (map pkgs.lib.escapeShellArg clusterNames)} )
                for cluster in "''${clusters[@]}"; do
                  echo "Generating image lock for $cluster"
                  gen-image-lock --cluster "$cluster" "$@"
                done
              '';
        };
      });

      apps = forAllSystems (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
        in
        {
          gen-image-lock = {
            type = "app";
            program = "${self.packages.${system}.gen-image-lock}/bin/gen-image-lock";
          };
          gen-image-lock-all = {
            type = "app";
            program = "${self.packages.${system}.gen-image-lock-all}/bin/gen-image-lock-all";
          };
        }
        // builtins.listToAttrs (
          map (
            cluster:
            let
              wrappedName = mkName cluster;
            in
            {
              name = wrappedName;
              value = {
                type = "app";
                program = "${self.packages.${system}.${wrappedName}}/bin/${wrappedName}";
              };
            }
          ) clusterNames
        ));

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "k8s-gitops";
          packages = with pkgs; [ bashInteractive ];
        };
      });
    };
}
