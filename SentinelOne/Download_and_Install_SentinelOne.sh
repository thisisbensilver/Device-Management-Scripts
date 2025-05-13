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
#   Why might you need this?
#   Your SentinelOne Token needs to be in the same directory
#   as the installer, and not all MDM solutions let you do that.
#   I'm looking at you, MaaS360!
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





##############################
#                            #
#          Settings          #
#                            ######################################
#
# These are the only 2 things you *need* to change!
#

# URL to your installer package (download from SentinelOne portal)
fileLoc="https://YOURSERVER"

# Registration Token (copy from SentinelOne portal)
regToken="CHANGE ME"

#
###################################################################





##############################
#                            #
#     Optional Settings      #
#                            ######################################
#
# You can leave these as-is, unless you wanna tinker!
#

# Script name
myScriptTitle="Install SentinelOne from Remote Host"

# Location of temp install directory
# No final slash!
myDir="/tmp/S1"

# Name the LogFile "YYYY-MM-DD_HH-MM-AM"
myTime=$(date +"%Y-%m-%d_%I-%M-%p")
myLogFile="$myDir/$myTime.txt"

# Custom function to log "[datestamp] result"
log() {
    echo "[$(date '+%Y-%m-%d %I:%M:%S %p')] $*"
}

# Custom function to log "result"
logNoTime(){
    echo -e "$*"
}

# Custom function to log something in a fancy banner
logFancy(){
    echo "###################################################################"
    echo ""
    echo -e "$*"
    echo ""
    echo "###################################################################"
}
#
###################################################################







##############################
#                            #
#       Run the Script       #
#                            ######################################
#

# Remove the temp Directory if there is anything there
rm -r $myDir

# Create the Directory and Log file and begin the script
mkdir -p $myDir
touch $myLogFile
exec > >(tee -a "$myLogFile") 2>&1
logFancy "$myScriptTitle"
logNoTime ""

# Check if SentinelOne is installed first
if test -d "/Applications/SentinelOne/"; then
    log "It looks like SentinelOne is already installed!"
    exit
else
    log "SentinelOne is not detected. Begin installation."
    logNoTime ""

    # Create token file
    log "Creating Token"
    echo $regToken >$myDir"/com.sentinelone.registration-token"
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
    curl -L -o $myDir"/S1.pkg" $fileLoc && log "Download complete!"
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
        logFancy "Successful installation!\nConfirm in the SentinelOne Portal\n\nEndpoint name: $HOSTNAME"
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

exit

# Done
###################################################################
