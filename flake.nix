{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              (ruby.withPackages (ps: with ps; [ bundler solargraph rspec ]))
              turso-cli
              ruby-lsp
            ] ++ lib.optionals stdenv.isDarwin [ iconv ];
          };

          shellHook = ''
            export GEMRC=$PWD/.gemrc
            export BUNDLE_USER_CONFIG=$PWD/.bundle/config
            export BUNDLE_PATH=$PWD/.bundle

            bundle config set force_ruby_platform true
            bundle config set --local without 'development test'
            bundle config set --local with 'production'
            bundle update error_highlight
            bundle install
          '';
      });
}

