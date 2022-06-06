#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

FILTER=$1

if [[ -z $FILTER ]] ; then
  rm -rf $PEGASUSCONF/metafiles
fi

function scrap(){
    local PLATFORM="$1"
    if [[ "$FILTER" && "$FILTER" != "$PLATFORM" ]] ; then
      echo skipping $PLATFORM
      return
    fi
    local FOLDER="$2"
    local META="$PEGASUSCONF/metafiles/$PLATFORM"
    $SCRAPCMD $SCREENSCRAPER -p "$PLATFORM" -i "$FOLDER" --lang $LANG --region $REGION
    mkdir -p "$META"
    $SCRAPCMD -f "$FRONTEND" -o "$META" -g "$META" -p "$PLATFORM" -a "$ARTWORK" -e "$LAUNCHER" -i "$FOLDER" --lang $LANG --region $REGION
    mv "$META/metadata.pegasus.txt" "$PEGASUSCONF/metafiles/$PLATFORM.metadata.pegasus.txt"
}

getGames | while read -r PLATFORM; do
  scrap $(getScraperCode "$PLATFORM") "$CLOUDDIR/$ROMSDIR/$PLATFORM"
done

echo $ARTWORK
