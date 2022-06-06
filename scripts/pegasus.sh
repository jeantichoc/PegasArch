SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
cd "$SCRIPTPATH/../scripts"

flatpak run org.pegasus_frontend.Pegasus &
