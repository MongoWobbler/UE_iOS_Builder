#!/bin/sh

# edit to your own directory. Make sure path ends with IOS since UE makes an IOS folder to put .ipa in
directory="/Users/USER/Archive/IOS"

# printing out empty line for visual reasons
echo

# gets the FIRST .ipa file found in the directory variable
cd $directory
files=(*.ipa)
FILE="$directory/${files[0]}"

# getting date/time and extensions
now=$(date "+_%y_%m_%dx%H_%M")
name="${FILE%.*}"
ext="${FILE##*.}"
zip_ext="zip"

# zip up the file with the new name
zip_file="$name$now.$ext.$zip_ext"
zip $zip_file $FILE

# remove the old file
rm $FILE
