#!/bin/sh

# edit variables below to match your .uproject, archive directory, and Unreal Automation Tool shell script
project_path="/Users/USER/PROJECT/PROJECT.uproject"
archive_dir="/Users/USER/Archive"
uat="/Users/USER/UnrealEngine/Engine/Build/BatchFiles/RunUAT.sh"

# printing out empty line for visual reasons
echo

# running shipping configuration since its the only way I've found to distribute apps for testing in other devices
$uat BuildCookRun -Project=$project_path -NoP4 -clean -build -cook -stage -package -pak -compressed -iostore -SkipCookingEditorContent -platform=IOS -configuration=Shipping -unattended -distribution -nodebuginfo -archive -archivedirectory=$archive_dir
