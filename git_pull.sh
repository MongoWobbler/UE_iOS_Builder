#!/bin/sh

# edit your_git_repo to any git repo you may need to pull/sync/get latest from, such as UE source code
your_git_repo="/Users/USER/UnrealEngine"

# printing out empty line for visual reasons
echo

# switches the current working directory to the git repo and pulls
cd $your_git_repo
git pull
