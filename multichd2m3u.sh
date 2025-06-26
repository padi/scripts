#!/bin/bash

# Check if a game title was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <game_title> [search_directory]"
  echo "If no search_directory is provided, the current directory will be used."
  exit 1
fi

game_title="$1"
search_dir="${2:-.}" # Use current directory if second argument isn't provided
discs_folder="_discs"

# Create the _discs folder if it doesn't exist
mkdir -p "$discs_folder"

# Find all .chd files containing the game title (case-insensitive)
# and move them to the _discs folder
while IFS= read -r -d $'\0' file; do
  mv "$file" "$discs_folder/"
done < <(find "$search_dir" -maxdepth 1 -type f -iname "*.chd" -iname "*$game_title*" -print0)

# Get the sorted list of moved files and print their relative paths
# and append it to a new m3u file of the same game_title
find "$discs_folder" -type f -iname "*.chd" -iname "*$game_title*" | sort | while read -r file; do
  echo "$file"
done >"$game_title.m3u"
