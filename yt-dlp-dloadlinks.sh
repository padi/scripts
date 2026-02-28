#!/bin/bash

# Check if the file exists
if [[ ! -f "$HOME/TextFiles/dloads.txt" ]]; then
  echo "File $HOME/TextFiles/dloads.txt not found!"
  exit 1
fi

# Loop through each line in dloads.txt
while IFS= read -r url; do
  # Download the video using yt-dlp
  yt-dlp -o "%(title).100B [%(id)s].%(ext)s" "$url"
done <"$HOME/TextFiles/dloads.txt"
