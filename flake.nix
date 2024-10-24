{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        textlintrc = (pkgs.formats.json { }).generate "textlintrc" {
          plugins = {
            latex2e = true;
          };

          rules = {
            preset-ja-technical-writing = {
              max-kanji-continuous-len = {
                max = 15;
              };
              ja-no-mixed-period = {
                periodMark = ".";
              };
              arabic-kanji-numbers = false;
              no-mix-dearu-desumasu = {
                preferInHeader = "である";
                preferInBody = "である";
                preferInList = "である";
                strict = true;
              };
              ja-no-weak-phrase = true;
            };
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            (textlint.withPackages [
              textlint-rule-preset-ja-technical-writing
              textlint-plugin-latex2e
            ])
          ];
          buildInputs = [
            pkgs.texliveFull
            pkgs.nodejs
            # pkgs.textlint
            # pkgs.textlint-rule-preset-ja-technical-writing
            # pkgs.textlint-plugin-latex2e
          ];
          shellHook = ''
            unlink .textlintrc 
            ln -s ${textlintrc} .textlintrc 
          '';
        };
      }
    );
}
