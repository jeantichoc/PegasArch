pa_conf="${script_path:-.}/../config.txt"
columm_id=1
columm_scraper=2
columm_core=3
columm_path=4
columm_cloud=4

function echo.red(){
  echo -e "\033[1;31m$*\033[0m"
}


function echo.green(){
  echo -e "\033[1;32m$*\033[0m"
}


function echo.blue(){
  echo -e "\033[1;34m$*\033[0m"
}


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


function get_cloud(){
  get_field "$1" $columm_cloud
}


function trim(){
  while read -r data; do
    echo "$data" | sed 's/ *$//g' | sed 's/^ *//g'
  done
}


function rclone_sync(){
  mkdir -p "$2"
  echo rclone sync "$1" "$2"
  rclone sync "$1" "$2"
}


function rclone_bisync(){
  local RESYNC=""
  if [[ ! -d "$2" ]] ; then
      mkdir -p "$2"
      RESYNC="--resync"
  fi
  echo rclone bisync "$1" "$2" $RESYNC
  rclone bisync "$1" "$2" $RESYNC
}


function rclone_mount(){
  local options="--allow-other --read-only --vfs-cache-mode writes --allow-root --daemon-timeout=10s --daemon"
  mkdir -p "$2"
  echo rclone mount "$1" "$2" $options
  rclone mount $options
}


function find_core_file(){
  local core="$1"
  local file

  file="$HOME/.config/retroarch/cores/${core}_libretro.so"
  if [[ -f $file ]] ; then
    echo $file
    return
  fi

  file="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores/${core}_libretro.so"
  if [[ -f $file ]] ; then
    echo $file
    return
  fi

  file="/usr/lib/libretro/${core}_libretro.so"
  if [[ -f $file ]] ; then
    echo $file
    return
  fi

  file=$(dpkg -L libretro-$core 2>/dev/null | grep ${core}_libretro.so | head -1)
  if [[ -f $file ]] ; then
    echo $file
    return
  fi
}


function get_or_install_core_sub(){
  local id="$1"
  local core

  core="$(get_core "$id")"
  if [[ -z $core ]] ; then
    echo "[ERROR] No core found for $1"
    return 1
  fi

  core_file="$(find_core_file "$core")"
  if [[ ! -f $core_file ]] ; then
    sudo apt-get --assume-yes install libretro-$core
    core_file="$(find_core_file "$core")"
  fi

  echo ${core_file:-${core}}
}


function get_or_install_core(){
  get_or_install_core_sub "$1" | tail -1
}


function pegasarch_cloud(){
  get_ids_to_mount | while read -r id; do
    rclone_mount "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  get_ids_to_sync | while read -r id; do
    rclone_sync "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  rclone_bisync "$SAVDIR"
}
