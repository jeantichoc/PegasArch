GAMESCONF="${SCRIPTPATH:-.}/../games.txt"

function getConf(){
  grep -v "^#" "$GAMESCONF" | grep -Ei "^ *$1 *\|"
}

function getGames(){
  grep -v "^#" "$GAMESCONF" | cut -d '|' -f 1 | trim
}


function getGamesToSync(){
  grep -v "^#" "$GAMESCONF" | grep -Ei "\| *sync *\|" | cut -d '|' -f 1 | trim
}

function getGamesToMount(){
  grep -v "^#" "$GAMESCONF" | grep -Ei "\| *mount *\|" | cut -d '|' -f 1 | trim
}

function getScraperCode(){
  getConf "$1"  | cut -d '|' -f 3 | trim
}

function getCore(){
  getConf "$1"  | cut -d '|' -f 4 | trim
}

function trim(){
  while read -r data; do
    echo "$data" | sed 's/ *$//g' | sed 's/^ *//g'
  done
}

function rcloneSync(){
  local FOLDER="$1"
  mkdir -p "$CLOUDDIR/$FOLDER"
  echo rclone sync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER"
  rclone sync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER"
}

function rcloneBiSync(){
  local FOLDER="$1"
  local RESYNC=""
  if [[ ! -d "$CLOUDDIR/$FOLDER" ]] ; then
      mkdir -p "$CLOUDDIR/$FOLDER"
      RESYNC="--resync"
  fi
  echo rclone bisync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $RESYNC
  rclone bisync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $RESYNC
}

function rcloneMount(){
  local FOLDER="$1"
  local OPTIONS="--allow-other --read-only --vfs-cache-mode writes --allow-root --daemon-timeout=10s --daemon"
  mkdir -p "$CLOUDDIR/$FOLDER"
  echo rclone mount "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $OPTIONS
  rclone mount "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $OPTIONS
}
