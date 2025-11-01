#!/bin/bash

# Script to split MP3 files into 12 equal parts with noise removal
# Output naming: jung-001, jung-002, jung-003, etc.

# Create output directory
mkdir -p output

# Counter for global file numbering
file_counter=1

# Process each jung*.mp3 file in order
for input_file in jung{01..10}.mp3; do
    if [ ! -f "$input_file" ]; then
        echo "Skipping $input_file (not found)"
        continue
    fi

    echo "Processing: $input_file"

    # Get duration in seconds
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")

    # Calculate segment duration (total duration / 12)
    segment_duration=$(echo "$duration / 12" | bc -l)

    echo "  Total duration: ${duration}s"
    echo "  Segment duration: ${segment_duration}s"

    # Split into 12 parts with noise removal
    for i in {1..12}; do
        # Calculate start time
        start_time=$(echo "($i - 1) * $segment_duration" | bc -l)

        # Output filename with zero-padded counter
        output_file=$(printf "output/jung-%03d.mp3" $file_counter)

        echo "  Creating: $output_file (segment $i/12)"

        # Process with noise removal and splitting
        ffmpeg -i "$input_file" -ss "$start_time" -t "$segment_duration" \
            -af "highpass=f=200,lowpass=f=3000,afftdn=nf=-25" \
            -codec:a libmp3lame -q:a 2 \
            "$output_file" -y -loglevel error

        # Increment global counter
        ((file_counter++))
    done

    echo "Completed: $input_file"
    echo ""
done

echo "All files processed!"
echo "Total output files: $((file_counter - 1))"
echo "Files are in the 'output' directory"
