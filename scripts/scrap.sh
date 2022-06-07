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
    local platform="$1"
    if [[ "$param_filter" && "$param_filter" != "$platform" ]] ; then
      echo skipping $platform
      return
    fi
    local folder="$2"
    local metadir="$frontend_conf/metafiles/$platform"
    $scraper_cmd $screenscraper -p "$platform" -i "$folder" --lang $scraper_lang --region $REGION
    mkdir -p "$metadir"
    $scraper_cmd -f "$frontend" -o "$metadir" -g "$metadir" -p "$platform" -a "$ARTWORK" -e "$scraper_launcher" -i "$folder" --lang $scraper_lang --region $REGION
    mv "$metadir/metadata.pegasus.txt" "$frontend_conf/metafiles/$platform.metadata.pegasus.txt"
}

get_all_ids | while read -r platform; do
  scrap $(get_scraper "$platform") $(getPath "$platform")
done

echo $ARTWORK
