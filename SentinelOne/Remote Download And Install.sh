#!/bin/bash
###################################################################
#
#   Written by @thisisbensilver in May 2025 
#
###################################################################
#
#   This script downloads a SentinelOne installer package
#   from a remote URL and installs it from a temp directory.
#
#   Your SentinelOne Token needs to be in the same directory
#   as the installer, and not all MDM solutions let you do that.
# 
#   So this lets you install SentinelOne via script instead-
#   Quick and dirty!
#  
#   You should push out any MobileConfig policies prior to this
#   Otherwise users get Security & Privacy permission pop-ups
#
#   Disclaimer: Presented as-is with no guarantee or whatever-
#   It works for me and my organization as of May 2025.
#   I don't know how you'd break anything...
#   But don't get mad at me if you do!
#
###################################################################
# Script name
myScriptTitle="Install SentinelOne from Remote Host"
###################################################################





##############################
#                            #
#          Settings          #
#                            ######################################
#
# These are the only 2 things you *need* to change!
#

# URL to your installer package (download from SentinelOne portal)
fileLoc="CHANGE_ME_TO_YOUR_DOWNLOAD_LINK"

# Registration Token (copy from SentinelOne portal)
regToken="CHANGE_ME_TO_YOUR_REGISTRATION_TOKEN"
#
###################################################################





##############################
#                            #
#     Optional Settings      #
#                            ######################################
#
# You can leave these as-is, unless you wanna tinker!
#

# Location of temp install directory
myDir="/tmp/S1" #No final slash!

# Name the LogFile "YYYY-MM-DD_HH-MM-AM"
myTime=$(date +"%Y-%m-%d_%I-%M-%p")
myLogFile="$myDir/$myTime.txt"

#Let Echo display whitespace character
set -e


# Some custom logging functions for clean output
# Output "[datestamp] result"
log() {
    echo "[$(date '+%Y-%m-%d %I:%M:%S %p')] $*"
}

# Output the result with no datestampe
logNoTime(){
    echo -e "$*"
}

#
###################################################################







##############################
#                            #
#       Run the Script       #
#                            ######################################
#
# Do everything within the main() function
# This lets us put custom functions at the bottom of the script

    
# Remove the temp Directory if there is anything there
if [ -d "$myDir" ]; then
    sudo rm -r "$myDir"
fi


# Create the Directory and Log file and begin the script
mkdir -p "$myDir"
touch "$myLogFile"
exec > >(tee -a "$myLogFile") 2>&1
logNoTime "$myScriptTitle"
logNoTime ""


# Check if SentinelOne is installed first
if test -d "/Applications/SentinelOne/"; then
    log "It looks like SentinelOne is already installed!"
    exit 0 
else
    log "SentinelOne is not detected. Begin installation."
    logNoTime ""
    
    # Create token file
    log "Creating Token"
    echo "$regToken" >"$myDir/com.sentinelone.registration-token"
    logNoTime ""

    # Make sure it's readable
    log "Permission Check:"
    ls -l $myDir"/com.sentinelone.registration-token"
    logNoTime ""
    log "Modify Permissions:"
    chmod 644 $myDir"/com.sentinelone.registration-token"
    ls -l $myDir"/com.sentinelone.registration-token"
    logNoTime ""

    # Download Installer
    # (The '&& log' ensures the download is done before proceeding)
    log "Begin Download"
    if curl -L -o "$myDir/S1.pkg" "$fileLoc"; then
        log "Download complete"
    else
        log "Download error."
        exit 1
    fi

    logNoTime ""

    # Wait a few seconds... just in case!
    log "Waiting 10s"
    sleep 10
    logNoTime ""
    
    # Run the installer
    log "Beginning Installation"
    sudo installer -pkg $myDir"/S1.pkg" -target /
    logNoTime ""
    
    # Check installation
    if test -d "/Applications/SentinelOne/"; then
        logNoTime ""
        logNoTime "Successful installation!"
        logNoTime "Confirm in the SentinelOne Portal"
        logNoTime " "
        logNoTime "Endpoint name: $HOSTNAME"
    else
        logNoTime ""
        logNoTime "Something went wrong =["
        logNoTime ""
    fi
    
    # Clean up after yourself!
    # But don't delete the log file
    rm $myDir"/S1.pkg"
    rm $myDir"/com.sentinelone.registration-token"
    
fi

logNoTime ""
log "You've made it to the end, traveller!"

exit 0

# Done
###################################################################
