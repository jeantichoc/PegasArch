
# Load first part of the config.txt as a bash pegasarch
pegasarch_conf="$pegasarch_path/config.txt"
eval $(cat $pegasarch_conf  | sed -e '/#########/,$d' | grep -v "^#"  )


##### ADDITONALS CONFIGURATIONS ####
frontend=pegasus
frontend_conf="$HOME/.var/app/org.pegasus_frontend.Pegasus/config/pegasus-frontend"
scraper_cmd="$HOME/GitHub/skyscraper/Skyscraper"
retroarch_cmd=retroarch
retroarch_superconf="$(realpath "$pegasarch_path/resources/retroarch.conf")"
retroarch_superconf_to_use="$(realpath "$pegasarch_path/resources/.retroarch_to_use.conf")"
scraper_artwork="$(realpath "$pegasarch_path/resources/artwork.xml")"



##### FUNCTIONS #####

columm_id=1
columm_scraper=2
columm_core=3
columm_path=4
columm_cloud=5

function echo.red () {
  echo -e "\033[1;31m$*\033[0m"
}


function echo.green () {
  echo -e "\033[1;32m$*\033[0m"
}


function echo.blue () {
  echo -e "\033[1;34m$*\033[0m"
}


function get_conf () {
  grep -v "^#" "$pegasarch_conf" | grep "|" | grep -Ei "^ *$1 *\|"
}


function get_all_ids () {
  grep -v "^#" "$pegasarch_conf" | grep "|" | cut -d '|' -f 1 | trim
}


function get_ids_to_sync () {
  grep -v "^#" "$pegasarch_conf" | grep -Ei "\| *sync *\|" | cut -d '|' -f $columm_id | trim
}


function get_ids_to_mount () {
  grep -v "^#" "$pegasarch_conf" | grep -Ei "\| *mount *\|" | cut -d '|' -f $columm_id | trim
}


function get_field () {
  local var="$(get_conf "$1"  | cut -d '|' -f "$2" | trim)"
  eval echo $var
}


function get_scraper () {
  get_field "$1" $columm_scraper
}


function get_path () {
  get_field "$1" $columm_path
}


function get_core () {
  get_field "$1" $columm_core
}


function get_cloud () {
  get_field "$1" $columm_cloud
}


function trim () {
  while read -r data; do
    echo "$data" | sed 's/ *$//g' | sed 's/^ *//g'
  done
}


function rclone_sync () {
  mkdir -p "$2"
  echo rclone sync "$1" "$2"
  rclone sync "$1" "$2"
}


function rclone_bisync () {
  local RESYNC=""
  if [[ ! -d "$2" ]] ; then
      mkdir -p "$2"
      RESYNC="--resync"
  fi
  echo rclone bisync "$1" "$2" $RESYNC
  rclone bisync "$1" "$2" $RESYNC
}


function rclone_mount () {
  local options="--allow-other --read-only --vfs-cache-mode writes --allow-root --daemon-timeout=10s --daemon"
  mkdir -p "$2"
  echo rclone mount "$1" "$2" $options
  rclone mount $options
}


function find_core_file () {
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


function install_core_if_required () {
  local id="$1"
  local core

  core="$(get_core "$id")"
  if [[ -z $core ]] ; then
    echo.red "[ERROR] No core found for $1"
    return 1
  fi

  if [[ -f $core ]] ; then
    return
  fi

  core_file="$(find_core_file "$core")"
  if [[ ! -f $core_file ]] ; then
    echo.blue "Installing core ${core//_/-}"
    sudo apt-get --assume-yes install libretro-${core//_/-}
    core_file="$(find_core_file "$core")"
  fi

  if [[ -f $core_file ]] ; then
    return
  fi

  echo.red "no core $core found"
  return 1
}

function get_core_file () {
  local id="$1"
  local core

  core="$(get_core "$id")"
  if [[ -z $core ]] ; then
    return 1
  elif [[ -f $core ]] ; then
    echo "$core"
    return
  fi

  core_file="$(find_core_file "$core")"
  if [[ -f $core_file ]] ; then
    echo "$core_file"
    return
  fi
  return 1
}


function pegasarch_cloud () {
  get_ids_to_mount | while read -r id; do
    rclone_mount "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  get_ids_to_sync | while read -r id; do
    rclone_sync "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  rclone_bisync "$SAVDIR"
}


function configure_retroarch () {
  cp "$retroarch_superconf" "$retroarch_superconf_to_use"
  if [[ $emulator_saves ]] ; then
    mkdir -p $emulator_saves
    sed "s|^savefile_directory *= *PEGASARCH *|savefile_directory = $emulator_saves|"   -i "$retroarch_superconf_to_use"
  fi

  if [[ $emulator_states ]] ; then
    mkdir -p $emulator_states
    sed "s|^savestate_directory *= *PEGASARCH *|savestate_directory = $emulator_states|" -i "$retroarch_superconf_to_use"
  fi
}


function pegasarch_launch () {
  file="$1"
  core="$2"

  configure_retroarch

  echo "$retroarch_cmd -f -L \"$core\" \"$file\" --appendconfig $retroarch_superconf_to_use"
  $retroarch_cmd -f -L "$core" "$file" --appendconfig "$retroarch_superconf_to_use"

  #rclone_bisync "$SAVDIR" &
}



function scrap () {
    local name="$1"
    local platform="$2"
    local folder="$3"
    local metadir="$pegasarch_path/metadatas/$name"
    local scraper_launcher
    local core


    install_core_if_required "$name" || return
    core="$(get_core_file "$name")"

    mkdir -p "$metadir"
    metadir="$(realpath "$metadir")"
    scraper_launcher="$pegasarch launch \"{file.path}\" "$core""

    echo.blue "getting metadas from screenscraper"
    $scraper_cmd            \
      -s screenscraper       \
      -u $screenscraper_login \
      -p "$platform"           \
      -i "$folder"              \
      --lang $scraper_lang       \
      --region $scraper_region    \
      --flags unattend,nohints


    echo.blue "generate metadas file for pegasus"
    $scraper_cmd       \
      -f "$frontend"    \
      -o "$metadir"      \
      -g "$metadir"       \
      -p "$platform"       \
      -a "$scraper_artwork" \
      -e "$scraper_launcher" \
      -i "$folder"            \
      --lang $scraper_lang     \
      --region $scraper_region  \
      --flags unattend,nohints

    ln -sf "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
    ls -l "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
}



function pegasarch_scrap () {
  local param_filter="$1"

  if [[ -z $screenscraper_login ]] ; then
    echo.red "Screenscraper login:password not set in config.txt"
    return 1
  fi

  if [[ $frontend != pegasus ]] ; then
    echo.red "Only pegasus is compatible right now"
    return 2
  fi

  if [[ -z $param_filter && -d $frontend_conf/metafiles ]] ; then
    rm -rf $frontend_conf/metafiles
  fi
  mkdir -p $frontend_conf/metafiles

  get_all_ids | while read -r platform_id; do
    if [[ $param_filter && $platform_id != $param_filter ]] ; then
      echo skipping $platform_id
      continue
    fi
    scrap "$platform_id" "$(get_scraper "$platform_id")" "$(get_path "$platform_id")"
  done
}
