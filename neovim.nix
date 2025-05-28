{
  lib,
  symlinkJoin,
  writeShellScriptBin,

  neovim,

  wl-clipboard
}:
symlinkJoin {
  name = "neovim";
  paths = [
    (writeShellScriptBin "nvim" ''
      export PATH="${lib.makeBinPath [ wl-clipboard ]}:$PATH"
      exec -a "$0" "${lib.getExe neovim}" "$@"
    '')
    neovim
  ];
}
