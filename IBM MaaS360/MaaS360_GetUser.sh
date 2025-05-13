#!/bin/bash

###################################################################
#
#   Written by @thisisbensilver in May 2025 
#
###################################################################
#
#   MaaS360 offers no way to dynamicaly identify which
#	User the current machine is registered to
#
#   Why might you want to do that?
#	My Org likes to format computer names based on
#	the User and Serial of a device
#
#   It's janky as heck, but this script tries to find the
#	MaaS360 logs and pull the username out
#
#	Once you have it, you can manipulate it however you need!
#
#   Disclaimer: Presented as-is with no guarantee or whatever-
#   It works for me and my organization as of May 2025.
#   I don't know how you'd break anything...
#   But don't get mad at me if you do!
#
###################################################################


# Loop through the logs to find a line that has the "user_name" identifier
myFileText="$(grep -R "\"user_name\" =" /Library/Application\ Support/MaaS360 -m 1)"

# If it found the username in a line, extract just the username value
if [ ! -z "$myFileText" ]; then
	
	# Save the username as myName
	myName=$(awk '{ sub(/.*\" = \"/, ""); sub(/\";.*/, ""); print }' <<< "$myFileText")
	echo "$myName"
	# That's it. Now you can pull it apart and do whatever you need!
	# For example, if your usernames are FIRST.LAST
	# you could split it into two variables
else
	echo "Sorry, I couldn't find anything! =["
	exit
fi