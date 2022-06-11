#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
source "$SCRIPTPATH/../init/init.sh"

if [[ -z $screenscraper_login ]] ; then
  echo.red "Screenscraper login:password not set in config.txt"
  exit 1
fi

if [[ $frontend != pegasus ]] ; then
  echo.red "Only pegasus is compatible right now"
  exit 2
fi


param_filter=$1
if [[ -z $param_filter && -d $frontend_conf/metafiles ]] ; then
  rm -rf $frontend_conf/metafiles
fi
mkdir -p $frontend_conf/metafiles

function scrap(){
    local name="$1"
    local platform="$2"
    local folder="$3"
    local metadir="$SCRIPTPATH/../metadatas/$name"
    local scraper_launcher
    local core

    if [[ "$param_filter" && "$param_filter" != "$name" ]] ; then
      echo skipping $name
      return
    fi

    mkdir -p "$metadir"
    metadir="$(realpath "$metadir")"

    core="$(get_or_install_core $name)"
    scraper_launcher="$SCRIPTPATH/launch.sh \"{file.path}\" $core"

    echo.blue "getting metadas from screenscraper"
    $scraper_cmd            \
      -s screenscraper       \
      -u $screenscraper_login \
      -p "$platform"           \
      -i "$folder"              \
      --lang $scraper_lang       \
      --region $scraper_region    \
      --flags unattend nohints


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
      --flags unattend nohints

    ln -sf "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
    ls -l "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
}

get_all_ids | while read -r platform_id; do
  scrap "$platform_id" $(get_scraper "$platform_id") $(get_path "$platform_id")
done
