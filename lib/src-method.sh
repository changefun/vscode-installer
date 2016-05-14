#!/bin/bash
function src-method {

  printf "How would you like to get the source code? [curl/git/wget/?] "
  read SRC_METHOD

  if [[ $SRC_METHOD == "?" ]]; then

    printf "curl and wget are the fastest methods and they chew up less bandwidth.\n
    While git uses up more bandwidth but it also makes upgrading the package faster."

  elif [[ $SRC_METHOD == "curl" ]]; then

    if [[ -d $SRC_DEST/vscode-$pkgver ]]; then
      rm -rf $SRC_DEST/vscode-$pkgver
    fi

    curl -sL https://github.com/Microsoft/vscode/archive/$pkgver.tar.gz | tar xz -C $SRC_DEST

    cd $SRC_DEST/vscode-$pkgver

    curl -sL https://git.io/vrYIY > product.json

  elif [[ $SRC_METHOD == "wget" ]]; then

    if [[ -d $SRC_DEST/vscode-$pkgver ]]; then
      rm -rf $SRC_DEST/vscode-$pkgver
    fi

    wget -cqO- https://github.com/Microsoft/vscode/archive/$pkgver.tar.gz | tar xz -C $SRC_DEST

    cd $SRC_DEST/vscode-$pkgver

    curl -sL https://git.io/vrYIY > product.json

  elif [[ $SRC_METHOD == "git" ]]; then

    if ! [[ -d $SRC_DEST/vscode ]]; then
      git clone https://github.com/Microsoft/vscode $SRC_DEST/vscode
    fi
    cd $SRC_DEST/vscode
    git fetch -p
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

    # Use a custom product.json; necessary for extensions
    curl -sL https://git.io/vrYIY > product.json

  else

    printf "You must select a SRC_METHOD!"

  fi

}

export -f src-method