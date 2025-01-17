#!/bin/bash

# Script to unmount an external drive based on its name label (macOS)
# Example Usage:
# ~> ./unmount_by_name.sh Insta360GO3

# Function to find the disk identifier by volume name
find_disk_by_name() {
    local volume_name="$1"
    local disk; disk=$(diskutil list | grep -B 1 "$volume_name" | head -n 1 | awk '{print $NF}')
    
    if [[ -z $disk ]]; then
        printf "Error: No drive found with the name '%s'\n" "$volume_name" >&2
        return 1
    fi
    
    # if a disk identifier was found e.g. disk2,
    # complete the disk identifier by adding /dev/ to it
    disk="/dev/${disk}"
    printf "%s\n" "$disk"
}

# Function to unmount the disk
unmount_disk() {
    local disk="$1"
    
    if [[ -z $disk ]]; then
        printf "Error: Disk identifier is empty\n" >&2
        return 1
    fi

    printf "Attempting to unmount %s...\n" "$disk"
    
    if ! diskutil unmountDisk "$disk"; then
        printf "Error: Failed to unmount %s\n" "$disk" >&2
        return 1
    fi

    printf "Successfully unmounted %s\n" "$disk"
}

# Main function to coordinate finding and unmounting
main() {
    if [[ $# -ne 1 ]]; then
        printf "Usage: %s <VolumeName>\n" "$0" >&2
        return 1
    fi

    local volume_name="$1"
    local disk; disk=$(find_disk_by_name "$volume_name")

    if [[ -n $disk ]]; then
        unmount_disk "$disk"
    else
        printf "No action taken.\n"
    fi
}

# Run the main function with the provided arguments
main "$@"

