#!/bin/bash
## DefaultSoundDeviceChanger ###
#                              #
#   Version 0.1 by .puzzles    #
#                              #
################################


# Check default card



# Choose new default card
echo "Choose your default card:"
aplay -l | grep card
echo -n '  << '
read -n1 defcard

fulldefcard=`aplay -l | grep "card $defcard" | head -1`

echo
echo "_________________________________________________________________"
echo "Are you sure you want to choose"
echo "$fulldefcard"
echo "as your new Default Soundcard (y/N)?"
echo -n '  << '
read -n1 confirm
echo

if [ "$confirm" = 'y' ]; then
#    echo "$defcard"
    sed -i "s/^defaults.ctl.card.*/defaults.ctl.card $defcard/" /usr/share/alsa/alsa.conf
    sed -i "s/^defaults.pcm.card.*/defaults.pcm.card $defcard/" /usr/share/alsa/alsa.conf
    echo "Default Soundcard changed "
    echo "New default: $fulldefcard"

else
    exit 1
fi
