eval $(cat ${SCRIPTPATH:-.}/../config.txt  | sed -e '/#########/,$d')
source "${SCRIPTPATH:-.}/../init/functions.sh"

##### ADDITONALS CONFIGURATIONS ####
frontend_conf="$HOME/.var/app/org.pegasus_frontend.Pegasus/config/pegasus-frontend"
scraper_cmd="$HOME/GitHub/skyscraper/Skyscraper"
scraper_launcher="$SCRIPTPATH/launch.sh \"{file.path}\""
ARTWORK="$(realpath "$SCRIPTPATH/../resources/artwork.xml")"

SAVDIRCLOUD="$CLOUDDIR/$SAVDIR"
