{
  noGui,
  noCli,
  ageSecrets,
  isDarwin,
}: let
  coreModules =
    [
      ./noarch/core.nix
    ]
    ++ (
      if isDarwin
      then [./darwin/core.nix]
      else [./linux/core.nix]
    );

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
  coreModules
  ++ guiModules
  ++ cliModules
  ++ (
    if ageSecrets
    then [
      ./noarch/secrets
    ]
    else []
  )
