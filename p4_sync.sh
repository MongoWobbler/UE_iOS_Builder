#!/bin/sh

# edit variables below to match your perforce
path_to_p4="/usr/local/bin/"
server_port="127.0.0.1:1666"
p4_username="YOUR_USERNAME_HERE"
p4_workspace="YOUR_WORKSPACE_NAME_HERE"

# printing out empty line for visual reasons
echo

# adding the path to p4 and other p4 variables to the system's path
export PATH=$path_to_p4:$PATH
export P4PORT=$server_port
export P4USER=$p4_username
export P4CLIENT=$p4_workspace
p4 sync
