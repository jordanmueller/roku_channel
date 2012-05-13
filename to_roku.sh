#!/bin/sh
# 
#  Simple shell script to zip and deploy the app to the dev roku device.
#  system must have zip and curl installed.

# Define some variables.
ZIPDIR=zips
APPNAME=harvard_roku_channel
ROKU_DEV_TARGET=10.10.10.130

# create the zip dir (if not present)
if [ ! -d $ZIPDIR ]
then
    echo "Creating the zip directory ($ZIPDIR)"
    mkdir $ZIPDIR
fi

# delete previous zip file
if [ -f "$ZIPDIR/$APPNAME.zip" ]
then
    echo "Deleting previous zip file"
    rm "$ZIPDIR/$APPNAME.zip"
fi

# create the new zip file (don't compress images)
zip -0 -r "$ZIPDIR/$APPNAME.zip" . -i \*.png -x *git*
zip -9 -r "$ZIPDIR/$APPNAME.zip" . -x \*~ -x \*.png -x Makefile -x *git* -x $0

# Send the file to the dev roku
echo "Sending $ZIPDIR/$APPNAME.zip to the Roku at $ROKU_DEV_TARGET"
curl -s -S -F "mysubmit=Install" -F "archive=@$ZIPDIR/$APPNAME.zip" -F "passwd=" http://$ROKU_DEV_TARGET/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["

