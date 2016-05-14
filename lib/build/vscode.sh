function vscode-build {
  export GHUB="$HOME/GitHub"
  export DESC="Visual Studio Code (VSCode), open-source version. VSCode is a free text editor developed by Microsoft, that is built on the Electron (formerly Atom Shell) framework, with support for a wide variety of different computer languages."

  # Get the source code
  printf "How would you like to get the source code? [curl/git/wget/?] "
  read SRC_METHOD

  printf "Where do you want to store the source code? [Leavy empty for $GHUB] "
  read SRC_DEST

  if ! [[ -n $SRC_DEST ]]; then
    SRC_DEST=$GHUB
  fi

  printf "Do you want to install VScode locally or system-wide? [local/system] "
  read DEST_TYPE

  ver=$(sed -n 's/ver=//p' ./lib/version.sh)

  if [[ $SRC_METHOD == "?" ]]; then

    printf "curl and wget are the fastest methods and they chew up less bandwidth.\n
    While git uses up more bandwidth but it also makes upgrading the package faster."

  elif [[ $SRC_METHOD == "curl" ]]; then

    if [[ -d $SRC_DEST/vscode-$ver ]]; then
      rm -rf $SRC_DEST/vscode-$ver
    fi
    curl -sL https://github.com/Microsoft/vscode/archive/$ver.tar.gz | tar xz -C $SRC_DEST
    cd $SRC_DEST/vscode-$ver

  elif [[ $SRC_METHOD == "wget" ]]; then

    if [[ -d $SRC_DEST/vscode-$ver ]]; then
      rm -rf $SRC_DEST/vscode-$ver
    fi
    wget -cqO- https://github.com/Microsoft/vscode/archive/$ver.tar.gz | tar xz -C $SRC_DEST
    cd $SRC_DEST/vscode-$ver

  elif [[ $SRC_METHOD == "git" ]]; then
    if ! [[ -d $SRC_DEST/vscode ]]; then
      git clone https://github.com/Microsoft/vscode $SRC_DEST/vscode
    fi
    cd $SRC_DEST/vscode
    git fetch -p
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

  else

    printf "You must select a SRC_METHOD!"

  fi

  ARCH=$(uname -m)
  if [[ $ARCH == 'x86_64' ]]; then
    _vscode_arch=x64
  else
    _vscode_arch=x86
  fi

  ########### The build #############
  # Use a custom product.json; necessary for extensions
  curl -sL https://git.io/vrYIY > product.json

  # Install NPM dependencies
  scripts/npm.sh install

  # Build vscode
  node --max_old_space_size=2000 /usr/bin/gulp vscode-linux-${_vscode_arch} || printf "An error has occurred while building this package with gulp. Please report the exact error message you received\n at https://github.com/fusion809/VScode-installer/issues/new"

  # DEST
  wget -cqO- https://github.com/fusion809/VScode-installer/blob/master/resources/visual-studio-code-oss.desktop > $SRC_DEST/visual-studio-code-oss.desktop
  if [[ $DEST_TYPE == 'local' ]]; then
    mv "$SRC_DEST/visual-studio-code-oss.desktop" .
    sed -i -e "s|<%-INST-%>|$GHUBM/VSCode-linux-${_vscode_arch}|g" visual-studio-code-oss.desktop
    printf "VScode is now installed to $GHUBM/VSCode-linux-${_vscode_arch}"
  else
    cd ..

    if [[ -d /opt/VSCode-linux-${_vscode_arch} ]]; then
      sudo rm -rf /opt/VSCode-linux-${_vscode_arch}
    fi
    sudo mv VSCode-linux-${_vscode_arch} /opt

    sudo ln -sf "/opt/VSCode-linux-${_vscode_arch}/code-oss" "/usr/bin/visual-studio-code-oss"

    # Modify desktop configuration file
    sed -i -e "s|<%-INST-%>|/opt/VSCode-linux-${_vscode_arch}|g" \
           -e "s|<%-DESC-%>|$DESC|g" "$SRC_DEST/visual-studio-code-oss.desktop"
    sudo install -D -m644 "$SRC_DEST/visual-studio-code-oss.desktop" "/usr/share/applications/visual-studio-code-oss.desktop"
  fi
}

export -f vscode-build