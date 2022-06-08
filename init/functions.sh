pa_conf="${SCRIPTPATH:-.}/../config.txt"
columm_id=1
columm_scraper=2
columm_core=3
columm_path=4
columm_cloud=4

function get_conf(){
  grep -v "^#" "$pa_conf" | grep "|" | grep -Ei "^ *$1 *\|"
}

function get_all_ids(){
  grep -v "^#" "$pa_conf" | grep "|" | cut -d '|' -f 1 | trim
}

function get_ids_to_sync(){
  grep -v "^#" "$pa_conf" | grep -Ei "\| *sync *\|" | cut -d '|' -f $columm_id | trim
}

function get_ids_to_mount(){
  grep -v "^#" "$pa_conf" | grep -Ei "\| *mount *\|" | cut -d '|' -f $columm_id | trim
}

function get_field(){
  local var="$(get_conf "$1"  | cut -d '|' -f "$2" | trim)"
  eval echo $var
}

function get_scraper(){
  get_field "$1" $columm_scraper
}

function get_path(){
  get_field "$1" $columm_path
}

function get_core(){
  get_field "$1" $columm_core
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

function rclone_bisync(){
  local FOLDER="$1"
  local RESYNC=""
  if [[ ! -d "$CLOUDDIR/$FOLDER" ]] ; then
      mkdir -p "$CLOUDDIR/$FOLDER"
      RESYNC="--resync"
  fi
  echo rclone bisync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $RESYNC
  rclone bisync "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $RESYNC
}

function rclone_mount(){
  local FOLDER="$1"
  local OPTIONS="--allow-other --read-only --vfs-cache-mode writes --allow-root --daemon-timeout=10s --daemon"
  mkdir -p "$CLOUDDIR/$FOLDER"
  echo rclone mount "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $OPTIONS
  rclone mount "$CLOUD:$FOLDER" "$CLOUDDIR/$FOLDER" $OPTIONS
}
