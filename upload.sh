#!/bin/sh

# edit variables below to match your workspace. Make sure directory ends with IOS since UE makes an IOS folder to put .ipa in
directory="/Users/USER/Archive/IOS"
path_to_appcenter="/usr/local/bin/"
appcenter_token="May look like a bunch of random letters and numbers. Do NOT share this token!"
appcenter_group_name="Collaborators"
appcenter_app_name="APPCENTER_USER/APP_NAME"

# printing out empty line for visual reasons
echo

# gets the FIRST .ipa file found in the directory variable
cd $directory
files=(*.ipa)
FILE="$directory/${files[0]}"

# add the path to appcenter to the system's path
export PATH=$path_to_appcenter:$PATH

# set token to not have to input username and/or password
export APPCENTER_ACCESS_TOKEN=$appcenter_token

# after -g comes the name of the group that will be notified of upload.
# after -app is the user followed by app name to upload to, use "appcenter app list" command to see all app names
appcenter distribute release -f $FILE -g $appcenter_group_name --app $appcenter_app_name
