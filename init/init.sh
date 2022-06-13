eval $(cat ${script_path:-.}/../config.txt  | sed -e '/#########/,$d' | grep -v "^#"  )
source "${script_path:-.}/../init/functions.sh"

##### ADDITONALS CONFIGURATIONS ####
frontend=pegasus
frontend_conf="$HOME/.var/app/org.pegasus_frontend.Pegasus/config/pegasus-frontend"
scraper_cmd="$HOME/GitHub/skyscraper/Skyscraper"
scraper_launcher="$script_path/launch.sh \"{file.path}\""
retroarch_cmd=retroarch
retroarch_superconf="$(realpath "$script_path/../resources/retroarch.conf")"
scraper_artwork="$(realpath "$script_path/../resources/artwork.xml")"
