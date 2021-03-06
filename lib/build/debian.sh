. ./lib/build/vscode.sh

function debian_build {
  # Get dependencies
  sudo apt-get install -y curl
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  sudo apt-get install -y nodejs build-essential git \
    libgnome-keyring-dev fakeroot libx11-dev python

  sudo npm install -g gulp node-gyp

  vscode_build
}

export -f debian_build
