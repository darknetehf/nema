#!/bin/bash

# Convert a PDF file to OCR version
# Output file will generated in the same directory as the source file
# Dependencies required: Tesseract, ImageMagick, poppler (pdftoppm)
#
# Usage: convert-document.sh <pdf file>
#

if [ -z "$1" ]; then
    echo "Error: No file provided"
    exit 1
fi

file=$1
base_file=$(basename "$file")  # get file name without directory
source_dir=$(dirname "$file")  # get directory of the file to process
base_file_no_ext="${base_file%.*}"  # get file name without extension

check_dependencies() {
    requirements=("pdftoppm" "tesseract" "magick")
    for dependency in "${requirements[@]}"; do
        if ! command -v "$dependency" &>/dev/null; then
            echo "This script requires '$dependency' to function" >&2
            exit 1
        fi
    done
}


cleanup() {
    if [ -n "$temp_dir" ]; then
        echo "Removing temp dir: $temp_dir..."
        rm -rf "$temp_dir"
    fi
}

trap cleanup EXIT

# Verify that the required tool are installed
check_dependencies

# Use a temp dir to extract images from PDF (shall be removed when script exits)
temp_dir=$(mktemp -d)
echo "Using temp directory: $temp_dir"


# Step 1: extract images from PDF file
echo "Extracting images from PDF file to temp directory..."
pdftoppm -png -rx 300 -ry 300 "$file" "$temp_dir/${base_file%.pdf*}"


# Step 2: optional - rotate all images
echo "Would you like to rotate the scanned images? Enter number of degrees (eg 90 for clockwise rotation), otherwise just leave blank."
read -rp "Degrees: " rotation

if [ -n "$rotation" ]; then
    echo "Rotating images in place..."
    magick mogrify -rotate "$rotation" "$temp_dir/*.png"
fi


# Step 3: pipe files to tesseract, produce pdf file
output_file="$base_file_no_ext-ocr"  # add -ocr prefix to output file
echo "Creating OCR file..."
ls "$temp_dir"/*.png | tesseract -l isl - "$source_dir/$output_file" pdf

echo "Done"
