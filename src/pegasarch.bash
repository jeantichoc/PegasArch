
# Load first part of the config.txt as a bash pegasarch
pegasarch_conf="$pegasarch_path/config.txt"
for pegasarch_conf_line in "$(cat "$pegasarch_conf"  | sed -e '/###############################################/,$d' | grep -v "^#"  )" ; do
  eval "$pegasarch_conf_line"
done


##### ADDITONALS CONFIGURATIONS ####
frontend=pegasus
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

function get_table () {
  grep -v "^#" "$pegasarch_conf" | grep ".*|.*|.*|.*|.*|.*|.*"
}


function get_conf () {
  get_table | grep -Ei "^ *$1 *\|"
}


function get_all_ids () {
  get_table | cut -d '|' -f 1 | trim
}


function get_ids_to_sync () {
  get_table | grep -Ei "\| *sync *\|" | cut -d '|' -f $columm_id | trim
}


function get_ids_to_mount () {
  get_table | grep -Ei "\| *mount *\|" | cut -d '|' -f $columm_id | trim
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
  local err=
  if [[ ! -d "$2" ]] ; then
      mkdir -p "$2"
      RESYNC="--resync"
  fi
  echo rclone bisync "$1" "$2" $RESYNC
  rclone bisync "$1" "$2" $RESYNC
  err=$?
  if [[ $err == 2 ]] ; then
    echo.blue "unsync, try with resync"
    rclone bisync "$1" "$2" --resync
    err=$?
  fi
  return $err
}


function rclone_mount () {
  local options="--allow-other --read-only --vfs-cache-mode writes --allow-root --daemon-timeout=10s --daemon"
  mkdir -p "$2"
  echo rclone mount "$1" "$2" $options
  rclone mount $options
}

function sync_save () {
  if [[ $emulator_cloud_saves && $emulator_saves ]] ; then
    rclone_bisync $emulator_cloud_saves $emulator_saves && echo.green "saves sync OK"
  else
    echo \$emulator_saves and \$emulator_cloud_saves not set in config.txt, nothing to sync
  fi
  if [[ $emulator_cloud_states && $emulator_states ]] ; then
    rclone_bisync $emulator_cloud_states $emulator_states && echo.green "savestates sync OK"
  else
    echo \$emulator_states and \$emulator_cloud_states not set in config.txt, nothing to sync
  fi
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
    echo $core OK
    return
  fi

  core_file="$(find_core_file "$core")"
  if [[ ! -f $core_file ]] ; then
    echo.blue "Installing core ${core//_/-}"
    sudo apt-get --assume-yes install libretro-${core//_/-}
    core_file="$(find_core_file "$core")"
  fi

  if [[ -f $core_file ]] ; then
    echo $core_file OK
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
  check_rclone || return 1
  get_ids_to_mount | while read -r id; do
    rclone_mount "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  get_ids_to_sync | while read -r id; do
    rclone_sync "$(get_cloud "$id")"  "$(get_path "$id")"
  done

  sync_save
}


function configure_retroarch () {
  cp "$retroarch_superconf" "$retroarch_superconf_to_use"
  if [[ $emulator_saves ]] ; then
    mkdir -p $emulator_saves
    sed "s|^# *savefile_directory *= *PEGASARCH *$|savefile_directory = $emulator_saves|"   -i "$retroarch_superconf_to_use"
  fi

  if [[ $emulator_states ]] ; then
    mkdir -p $emulator_states
    sed "s|^# *savestate_directory *= *PEGASARCH *$|savestate_directory = $emulator_states|" -i "$retroarch_superconf_to_use"
  fi
}


function pegasarch_launch () {
  file="$1"
  core="$2"

  configure_retroarch

  echo "\"$retroarch_cmd\" -f -L \"$core\" \"$file\" --appendconfig \"$retroarch_superconf_to_use"\"
  "$retroarch_cmd" -f -L "$core" "$file" --appendconfig "$retroarch_superconf_to_use"

  sync_save &
}

function lang_options () {
  if [[ $scraper_lang ]] ; then
    echo -n " --lang $scraper_lang "
  fi
  if [[ $scraper_region ]] ; then
    echo -n " --region $scraper_region "
  fi
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
    scraper_launcher="\"$pegasarch\" launch \"{file.path}\" "$core""

    echo.blue "getting metadas from screenscraper"
    "$scraper_cmd"          \
      -s screenscraper       \
      -u $screenscraper_login \
      -p "$platform"           \
      -i "$folder"              \
      $(lang_options) --flags unattend,nohints


    echo.blue "generate metadas file for pegasus"
    "$scraper_cmd"     \
      -f "$frontend"    \
      -o "$metadir"      \
      -g "$metadir"       \
      -p "$platform"       \
      -a "$scraper_artwork" \
      -e "$scraper_launcher" \
      -i "$folder"            \
      $(lang_options) --flags unattend,nohints

    ln -sf "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/pegasarch.$name.metadata.pegasus.txt"
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

  install_libretro_cores || return 1

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


function check_rclone () {
  local list=$(rclone listremotes)
  if [[ $? != 0 ]] ; then
    echo.red "rclone issue $list"
    return 1
  fi
  if [[ $(echo "$list" | sed '/^\s*$/d' | wc -l) < 1 ]] ; then
    echo.red "no rclone remote configured"
    echo.red "run 'rclone config' to start the configuration"
    return 1
  fi
}

function check_table () {
  if [[ -z $(get_table) ]] ; then
    echo.red PegasArch table is empty
  fi
}


function install_libretro_cores () {
  local error=0
  get_all_ids | while read -r platform_id; do
    install_core_if_required "$platform_id" || error=1
  done
  return $error
}

function dir_empty_or_absent() {
  if [[ -d $1 ]] ; then
    local lsA="$(ls -A "$1")" || return 1
    if [[ $lsA ]] ; then
      echo false
      return
    fi
    echo true
  fi
  return true
}


function rclone_config_if_none () {
  if [[ $(rclone listremotes | sed '/^\s*$/d' | wc -l) >= 1 ]] ; then
    return
  fi
  while true; do
      read -p "Do you wish to configure rclone (y/n)? " yn </dev/tty
      case $yn in
          [Yy]* )
            rclone config
            break
            ;;
          [Nn]* )
            break
            ;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}


function scraperlogin_if_none () {
  if [[ $screenscraper_login ]] ; then
    return
  fi
  local username
  local password
  read -p "screenscraper.fr username :" username </dev/tty
  read -s -p "screenscraper.fr password :" password </dev/tty
  echo
  sed "s|^ *screenscraper_login=.*|screenscraper_login='$username:$password'|" -i "$pegasarch_conf"
}

function edit_table_if_empty () {
  if [[ -z $(get_table) ]] ; then
    echo the PegasArch table is empty
    gedit "$pegasarch_conf"
  fi
}
