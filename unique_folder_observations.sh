#!/usr/bin/env bash

# Usage: bash unique_birds.sh [path to folder of csv files]
# Example: bash unique_birds.sh ../../shared/439539/birds/full

# Check if the correct number of arguments (1) is provided
if [ "$#" -ne 1 ]; then
echo "Usage: $0 <path_to_your_csv_folder>"
exit 1
fi

# Define the input folder, output folder, and bird info file
INPUT_FOLDER="$1"
OUTPUT_FOLDER="./processed_files"
BIRD_INFO_FILE="../../shared/439539/birds/bird-info"
SORTED_BIRD_INFO_FILE="sorted_bird_info.csv"

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Sort the bird-info file by species_code for the join operation
awk -F, 'NR > 1 { gsub(/"/, "", $1); gsub(/"/, "", $4); gsub(/"/, "", $5); print $1","$4","$5 }' "$BIRD_INFO_FILE" | sort > "$SORTED_BIRD_INFO_FILE"

# Loop over all CSV files in the input folder
for INPUT_FILE in "$INPUT_FOLDER"/*.csv; do
# Define the output file name based on the input file
OUTPUT_FILE="$OUTPUT_FOLDER/$(basename "$INPUT_FILE" .csv)_unique_observations.csv"

# Add headers to the output file
echo "Species_Code,Scientific_Name,Common_Name,Year,Location_ID,Latitude,Longitude,State" > "$OUTPUT_FILE"

# Process the file and join with sorted bird info
awk -F, 'NR > 1 {print $12","$10","$1","$2","$3","$4}' "$INPUT_FILE" | \
sort | \
uniq -u -w 8 | \
sort -t, -k1,1 | \
join -t, -1 1 -2 1 - "$SORTED_BIRD_INFO_FILE" | \
sort -t, -k2,2n -k1,1 | \
awk -F, '{print $1","$7","$8","$2","$3","$4","$5","$6}' >> "$OUTPUT_FILE"

echo "Analysis complete for $(basename "$INPUT_FILE"). Results are in $OUTPUT_FILE."
done
