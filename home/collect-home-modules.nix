{
  noGui,
  noCli,
  ageSecrets,
  isDarwin,
}: let
  guiModules =
    if noGui
    then []
    else [./noarch/gui];

  cliModules =
    if noCli
    then []
    else
      [./noarch/cli]
      ++ (
        # MacOS platform specific modules
        if isDarwin
        then [./darwin/shell.nix]
        else []
      );
in
  [./noarch/core.nix]
  ++ guiModules
  ++ cliModules
  ++ (
    if ageSecrets
    then [
      ./noarch/secrets
    ]
    else []
  )
