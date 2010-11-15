#!/bin/bash
#
# bck - a backup script with rsync.
# ---------------------------------
# version 0.1. author Dimitrios Meggidis
# Parameters: 
# -d destionation folder in server
# -s server ip
# -i file path of include files


function checkRequirements(){
    if [ ! "$inc" ]
    then 
        echo "[ERROR] Include file has not been set."
        echo "Usage: bck.sh -i includeFile -s server -d destinationFolder"
        exit 1
    elif [ ! -f "$inc" ]
    then 
        echo "[ERROR] $inc is not a file."
        echo "Usage: bck.sh -i includeFile -s server -d destinationFolder"
        exit 1
    elif [ ! "$srvr" ]
    then
        echo "[ERROR] Server must be set"
        echo "Usage: bck.sh -i includeFile -s server -d destinationFolder"
        exit 1
    elif [ ! "$dest" ]
    then
        echo "[ERROR] Destination folder in server must be set."
        echo "Usage: bck.sh -i includeFile -s server -d destinationFolder"
        exit 1
    fi
}

function parseParameters() {
    while getopts "s:d:i:ec" opt
    do
        case "$opt" in
            i) inc="$OPTARG";;
            s) srvr="$OPTARG";;
            d) dest="$OPTARG";;
            [?]) echo "$opt $OPTARG";;
        esac
    done
}

function filelistBackup() {
    while read f
    do
        checkfile $f
    done < "$inc"
}

function checkfile() {
     
    if [ -f "$f" ]
    then 
        echo "[rsync] File: $f"
        rsyncing $*
    elif [ -d "$f" ]
    then 
        if [[ ! $f =~ /$ ]]
        then 
            f=$f
        fi
        echo "[rsync] Folder: $f"
        rsyncing $*
    else
        if [[ $f =~ \* ]]
        then 
            echo "[WARNING] Wildcard found. Trying to rsync"
            rsyncing $*
        # elif [[ ! $f =~ ^/|^~ ]]
	# then
        #    f=$HOME/$f
        #    checkfile $f
        else
             echo "[WARNING] $f not file/directory or wildcard not found. Skipping."
        fi
    fi
}

function rsyncing() {
    rsync $opts $f $srvr::$dest/$backupdir
}

backupdir=`date +%m%d%y`
opts="--force --ignore-errors -avz"
echo "[INF] bck - $(date) from $(hostname)"
parseParameters $*
checkRequirements $inc $srvr $dest
filelistBackup $inc
