#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
source "$SCRIPTPATH/../init/init.sh"

if [[ -z $screenscraper_login ]] ; then
  echo "Screenscraper login:password not set in config.txt"
  exit 1
fi

if [[ $frontend != pegasus ]] ; then
  echo "Only pegasus is compatible right now"
  exit 2
fi

param_filter=$1
if [[ -z $param_filter ]] ; then
  rm -rf $frontend_conf/metafiles
fi

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

    mkdir -p "$metadir"

    $scraper_cmd            \
      -s screenscraper       \
      -u $screenscraper_login \
      -p "$platform"           \
      -i "$folder"              \
      --lang $scraper_lang       \
      --region $scraper_region

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
      --flags unattend

    mkdir $frontend_conf/metafiles
    ln -sf "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
}

get_all_ids | while read -r platform_id; do
  scrap "$platform_id" $(get_scraper "$platform_id") $(get_path "$platform_id")
done
