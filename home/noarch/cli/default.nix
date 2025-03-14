{
  pkgs,
  scanPaths,
  ...
}: {
  imports = scanPaths ./.;

  home.packages = with pkgs; [
    # nil # LSP. can install it through mason
    nixd # LSP
    statix # Lints and suggestions for the nix programming language
    deadnix # Find and remove unused code in .nix source files
    alejandra # Nix Code Formatter
  ];
}
