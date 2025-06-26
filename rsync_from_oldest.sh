#!/bin/bash

# Exit on any error
set -e

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 /path/to/dir1 /path/to/dir2"
  exit 1
fi

# Assign arguments to variables
SOURCE_DIR="$1"
DEST_DIR="$2"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' does not exist."
  exit 1
fi

# Ensure the destination directory exists, create it if not
if [ ! -d "$DEST_DIR" ]; then
  echo "Destination directory '$DEST_DIR' does not exist. Creating it..."
  mkdir -p "$DEST_DIR"
fi

# Use find and rsync to sync files in order of age
# only works on macos
# find "$SOURCE_DIR" -type f -exec stat -f '%m %N' {} \; | \
# sort -n | \
# awk '{print $2}' | \
# rsync -avh --progress --remove-source-files --files-from=- "$SOURCE_DIR" "$DEST_DIR"

#
cd "$SOURCE_DIR"
find . -type f -exec stat -f '%m %N' {} \; |
  sort -n |
  awk '{
  # Remove the leading timestamp (numbers followed by a space)
  sub(/^[0-9]+ /, "")
  # Remove the leading "./" if present
  sub(/^\.\//, "")
  print
}' |
  rsync -avh --exclude='.Spotlight*' --exclude='.DS_Store' \
    --progress --remove-source-files --files-from=- "$SOURCE_DIR" "$DEST_DIR"

# Cleanup: Remove empty directories from the source
# find "$SOURCE_DIR" -type d -empty -delete

echo "Sync complete! Oldest files were synced first."
#!/bin/bash

for i in {1..10}; do
  printf "\a"
  sleep 0.2 # Optional: pause between beeps (adjust as needed)
done
