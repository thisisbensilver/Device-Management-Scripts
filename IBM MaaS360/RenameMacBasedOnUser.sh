#!/bin/bash

###################################################################
#
#   Written by @thisisbensilver in May 2025 
#
###################################################################
#
#   Rename a Mac based on the registered user in MaaS360
#
#	Example, this script will rename a your computer:
#	First Initial + Last Name + "-" + Serial
#	Ex: B-SILVER-ABC123XYZ
#
#	But obviously you can do anything you want!
#   This is just one example
#
#	This expands on my basic "GetUser" script here:
#	https://github.com/thisisbensilver/Device-Management-Scripts/blob/main/IBM%20MaaS360/MaaS360_GetUser.sh
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

	# Get the Serial
	mySerial=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '/IOPlatformSerialNumber/{print $4}') 
	
	# Split and grab first name and last name
	# This assumes your username structure is FIRST.LAST
	myFirst="$(cut -d'.' -f1 <<<$myName)"
	myLast="$(cut -d'.' -f2 <<<$myName)" 
	
	# Grab first initial
	myFirstInitial="${myFirst:0:1}"
	
	# Combine it all!
	myNewName="$myFirstInitial-$myLast-$mySerial"
	
	# Convert it to UpperCase
	myNewName=$(echo "$myNewName" | awk '{print toupper($0)}')
	
	# Echo it all just in case you want to check it
	echo -e "Log line:\n$myFileText\n"
	echo "Username: $myName"
	echo "Serial: $mySerial"
	echo "First Name: $myFirst"
	echo "First Initial: $myFirstInitial"
	echo "Last Name: $myLast"
	echo -e ""
	echo "New Device Name: $myNewName"
	
	# Change the machine name
	sudo scutil --set HostName $myNewName
	sudo scutil --set LocalHostName $myNewName
	sudo scutil --set ComputerName $myNewName
	
else
	echo "Sorry, I couldn't find anything! =["
	exit
fi