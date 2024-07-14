#!/usr/bin/env bash

echo -e "\n\033[32mNerd-Font Uninstaller\033[0m\n"

echo -e "Removing all nerd fonts..."

if rm -rf "${HOME}"/.local/share/fonts/* ; then

  echo -e "Nerd fonts successfully removed!\n"

else

  echo -e "Nerd fonts removal failed.\n"

fi
