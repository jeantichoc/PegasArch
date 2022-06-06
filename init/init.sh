
source "${SCRIPTPATH:-.}/../init/functions.sh"
source "${SCRIPTPATH:-.}/../config.txt"


##### ADDITONALS CONFIGURATIONS ####
SCREENSCRAPER="-s screenscraper -u $SCREENSCRAPER_LOGIN"
FRONTEND="pegasus"
SCRAPCMD="$HOME/GitHub/skyscraper/Skyscraper"
LAUNCHER="$SCRIPTPATH/launch.sh \"{file.path}\""
ARTWORK="$(realpath "$SCRIPTPATH/../resources/artwork.xml")"

SAVDIRCLOUD="$CLOUDDIR/$SAVDIR"
