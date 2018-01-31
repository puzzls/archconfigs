#!/bin/bash
######## System Backup #########
#                              #
#   Version 0.1 by .puzzles    #
#                              #
################################

backup_dev="172.22.2.13:/volume1/_backup"

exclude="/dev/shm/rsync-excludes.rc"

excludes=(
    'tmp/*'                     # Temp files.
    'tmp/.*'                    # Hidden temp files.
    '.mozilla/firefox/*/Cache'  # Firefox caches...
    'cookies.sqlite'            # Mozilla-based cookies.
    'formhistory.sqlite'        # Mozilla-based form history.
    '.thumbnails'               # Thumbnail cache.
    '.recently-used.xbel'       # Recent-open history.
    '.ccache'                   # Compiler caches
    'sessionstore.js'           # Firefox session-saves.
    '.gvfs'                     # GNOME virtual filesystem.
    '.local/share/Trash'        # XDG trash.
    '.local/share/user-places*' # Recent-open history.
    '.purple/logs'              # Pidgin/Finch logs.
    '.cache/Thunar/thumbnailers.cache' # Thumbnailer cache.
    '.cache/chromium'           # Chrome cache.
    '*~'                        # Backup/temp files.
    '/home/*/.wine'		# Wine Programms
    '/home/*/Downloads'		# Download Folder
)

out () {
    echo ">> $*"
}

stat_done () {
    echo ">> ...done."
}

stat_fail () {
    echo ">> ...failed!"
}

if [ $UID != '0' ]; then
    echo "Must be executed as root user."
    exit 1
fi

out "Mouting backup device ('$backup_dev')..."
if mount | grep -qF "$backup_dev on"; then
    backup_root=`mount | grep -F "$backup_dev on" | cut -d' ' -f3`
    echo "  - This device seems to already be mounted at '$backup_root'."
    echo '    Do you want to use this, instead (y/N)?'
    echo -n '   << '
    read -n1 confirm
    echo
    [ "$confirm" != 'y' ] && exit 1
else
    backup_root="/mnt/backup"
    mkdir -p "$backup_root"
    if ! mount -o v4,noatime,user "$backup_dev" "$backup_root"; then
	echo '  - Failed to mount device.'
	exit 1
    fi
    echo '  - Device mounted successfully.'
fi

out "Backing up system..."
echo > /tmp/rsync-excludes.rc
for file in ${excludes[@]}; do
    echo "$file" >> "$exclude"
done

rsync -axl -h --progress --delete --delete-excluded --exclude-from="$exclude" /{home,usr,opt,var,*bin,lib*,etc,boot,root,srv} "$backup_root/$HOSTNAME-$(date +'%Y%m%d')"
mkdir -p "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/"{dev,sys,proc,tmp,mnt,media}
mkdir -p "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/var/"{tmp,lock}
chmod 1777 "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/tmp" "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/var/"{tmp,lock}
stat_done

out "Backing up package list..."
pacman -Qqe | grep -v "$(pacman -Qmq)" > "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/pacman.list"
pacman -Qmq > "$backup_root/$HOSTNAME-$(date +'%Y%m%d')/yaourt.list"
stat_done


##out "Making Tarball..."
##if
##    tar cvzf "$backup_root/$HOSTNAME-$(date +'%Y%m%d')".tgz "$backup_root/$HOSTNAME/";
##    then
##	rm -rfdv "$backup_root/$HOSTNAME"
##	stat_done
##    else
##    echo ' -could not make Tarball. ';
##fi

out "Unmouting backup partition..."
if umount "$backup_dev"; then
    rmdir "$backup_root/$HOSTNAME-$(date +'%Y%m%d')"
    rmdir "$backup_root"
    stat_done  
else
    echo '  - Could not unmount.';
fi