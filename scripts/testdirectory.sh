#!/bin/bash
## DefaultSoundDeviceChanger ###
#                              #
#   Version 0.1 by .puzzles    #
#                              #
################################

#device1=
#device2=
dir1="/home/puzzles/scripts/test"

if [ -d $dir1 ]; then
    echo " Directory $dir1 exists allready "
    echo ' Do you want to delete it (y/N)?'
    echo -n '	<< '
    read -n1 confirm
    echo
#    [ "$confirm" != 'y' ] && exit 1
else
    mkdir "$dir1"
    echo "directory $dir1 created"

if [ "$confirm" = 'y' ]; then 
    rm -rf "$dir1"
    echo "directory $dir1 removed"
else

if ([ "$confirm" != 'y'] && [ -d "$dir1"]); then
    echo "would you like to make '$dir1-$(date +'%Y%m%d')'"
    echo "(y/N)?"
    echo -n '	<< '
    read -n1 confirm2
    echo
#    [ "$confirm2" != 'y' ] && exit 1
else

if [ "$confirm2" = 'y' ]; then
    dir1="$dir1-$(date +'%Y%m%d')"
    mkdir $dir1
else
    exit 1
fi
fi
fi
fi
touch "$dir1/yayyytaarballs"
echo "Backup complete"

