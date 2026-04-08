#!/bin/bash

# Screenshot Folder and naming scheme
source ~/.config/peridot/settings/screenshot-folder.sh
source ~/.config/peridot/settings/screenshot-filename.sh

takescreenshot() {
  slurp | grim -g - $HOME/$NAME
  wl-copy < $HOME/$NAME
  if [ -d $screenshot_folder ]; then
      mv $HOME/$NAME $screenshot_folder/
  fi
}

takescreenshot