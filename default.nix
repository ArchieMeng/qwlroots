{ pkgs ? import <inxpkgs> { }, wlroots_0_17_src ? null }:
let
  mkDate = longDate: (pkgs.lib.concatStringsSep "-" [
    (builtins.substring 0 4 longDate)
    (builtins.substring 4 2 longDate)
    (builtins.substring 6 2 longDate)
  ]);
in
rec {
  wlroots-git = pkgs.wlroots_0_16.overrideAttrs (
    old: {
      version =  mkDate (wlroots_0_17_src.lastModifiedDate or "19700101") + "_" + (wlroots_0_17_src.shortRev or "dirty");
      src = wlroots_0_17_src;
      buildInputs = old.buildInputs ++ (with pkgs; [ 
        hwdata 
        libdisplay-info
      ]);
      postPatch = ""; # don't need patch hwdata path in wlroots 0.17
    }
  );

  qwlroots-qt6 = pkgs.qt6.callPackage ./nix {
    wlroots = pkgs.wlroots_0_16;
  };
  
  qwlroots-qt5 = pkgs.libsForQt5.callPackage ./nix {
    wlroots = pkgs.wlroots_0_16;
  };

  qwlroots-qt6-wlroots-git = qwlroots-qt6.override {
    wlroots = wlroots-git;
  };

  qwlroots-qt6-dbg = qwlroots-qt6.override {
    stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
  };

  qwlroots-qt6-clang = qwlroots-qt6.override {
    stdenv = pkgs.clangStdenv;
  };

  default = qwlroots-qt6;
}
