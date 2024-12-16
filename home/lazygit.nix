{userfullname, ... }: {
    
programs.lazygit = {
  enable = true;
  settings = {
    gui = {
      nerdFontsVersion = "3";
      spinner = {
        frames = [
          "'"
          "°"
          "º"
          "¤"
          "ø"
          ","
          "¸"
          "¸"
          ","
          "ø"
          "¤"
          "º"
          "°"
          "'"
        ];
      };
      theme = {
        selectedLineBgColor = [
          "reverse"
        ];
      };
      authorColors = {
        # "Yuxin Duan" = "#30A0A0";
        ${userfullname} = "#30A0A0";
      };
    };
    confirmOnQuit = true;
  };
};
}

