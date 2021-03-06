#!/bin/bash
function dest {
  printf "Where do you want to store the source code? [Leave empty for $GHUBM]\n"
  read SRC_DEST

  if ! [[ -n $SRC_DEST ]]; then
    SRC_DEST=$GHUBM
    if ! [[ -d $GHUBM ]]; then
      mkdir -p $GHUBM
    fi
  fi

  printf "Do you want to install Visual Studio Code locally or system-wide?\n[Available options: local/system. If you leave this field empty 'system' will be selected]\n"
  read DEST_TYPE

  export SRC_DEST
  export DEST_TYPE
}

export -f dest
