{ username }:
let 
  currentUsername = builtins.getEnv "USER";
in
  if username == currentUsername 
  then username
  else throw ''
    Username Mismatch:
      - Current System User: ${currentUsername}
      - Configured User: ${username}

    Please update the configuration or log in as the correct user.
    Hint: Make sure the username in your configuration matches your current system user.
  ''
