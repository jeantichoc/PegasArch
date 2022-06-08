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
    local metadir="$(realpath "$SCRIPTPATH/../metadatas/$name")"

    if [[ "$param_filter" && "$param_filter" != "$name" ]] ; then
      echo skipping $name
      return
    fi

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
      -a "$ARTWORK"         \
      -e "$scraper_launcher" \
      -i "$folder"            \
      --lang $scraper_lang     \
      --region $scraper_region

    mv "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/$name.metadata.pegasus.txt"
}

get_all_ids | while read -r platform_id; do
  scrap "$platform_id" $(get_scraper "$platform_id") $(getPath "$platform_id")
done
