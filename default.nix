{ rev    ? "c7e0e9ed5abd0043e50ee371129fcb8640264fc4"
, sha256 ? "0c28mpvjhjc8kiwj2w8zcjsr2rayw989a1wnsqda71zpcyas3mq2"
, pkgs   ? import (builtins.fetchTarball { inherit sha256;
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  }) { }
, lib    ? pkgs.lib }:

let
  matrix-nio = pkgs.python3Packages.matrix-nio.overrideAttrs (super: rec {
    version = "local";
    src = lib.cleanSource ./.;
    old_src = pkgs.fetchFromGitHub {
      owner = "poljar";
      repo = "matrix-nio";
      rev = "98f0c244065ea59c2e5105bc0aab5811aea748cf";
      hash = "sha256-GQPTnGxazR3WW8WGrC4X1oXvDXPMqQ5AZxdJns87C/Q=";
    };
  });
  weechat-matrix = (pkgs.weechatScripts.weechat-matrix.override {
    inherit matrix-nio;
  }).overrideAttrs (super: rec {
    version = lib.substring 0 9 src.rev;
    src = pkgs.fetchFromGitHub {
      owner = "poljar";
      repo = "weechat-matrix";
      rev = "d415841662549f096dda09390bfdebd3ca597bac";
      hash = "sha256-QT3JNzIShaR8vlrWuGzBtLDHjn7Z6vhovcOAfttgUxo=";
    };
  });
in pkgs.weechat.override {
  configure = { availablePlugins, ... }: {
    scripts = [ weechat-matrix ];
    plugins = builtins.attrValues (availablePlugins // {
      python = availablePlugins.python.withPackages (ps: with ps; [
        weechat-matrix
      ]);
    });
  };
}
