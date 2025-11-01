#!/bin/bash

# Audio processing script for jung01-jung10.mp3 → me01-me10.mp3
# Features:
# - Aggressive noise reduction
# - Male voice (85-180Hz) significantly reduced
# - Overall volume set to very low level

echo "================================"
echo "Audio Processing: jung → me series"
echo "Noise reduction + Very low volume"
echo "================================"
echo ""

# Counter for successful/failed files
success_count=0
fail_count=0

# Process jung01 through jung10
for i in {01..10}; do
    input_file="jung${i}.mp3"
    output_file="me${i}.mp3"

    if [ ! -f "$input_file" ]; then
        echo "⚠️  Skipping ${input_file} (not found)"
        ((fail_count++))
        continue
    fi

    echo "Processing: ${input_file} → ${output_file}"
    echo "  [1/5] Applying high-pass filter (120Hz)"
    echo "  [2/5] Applying low-pass filter (3500Hz)"
    echo "  [3/5] Reducing male voice frequencies (-12dB @ 100Hz, -10dB @ 150Hz)"
    echo "  [4/5] Aggressive noise reduction (nf=-30)"
    echo "  [5/5] Setting volume to very low (0.15x)"

    # FFmpeg processing with aggressive filters
    ffmpeg -i "$input_file" \
        -af "highpass=f=120:poles=2,\
             lowpass=f=3500:poles=2,\
             equalizer=f=100:width_type=h:width=50:g=-12,\
             equalizer=f=150:width_type=h:width=50:g=-10,\
             equalizer=f=130:width_type=h:width=40:g=-10,\
             afftdn=nf=-30:tn=1,\
             volume=0.15" \
        -c:a libmp3lame -q:a 2 \
        "$output_file" -y -loglevel error

    if [ $? -eq 0 ]; then
        echo "✅ Success: ${output_file}"
        ls -lh "$output_file" | awk '{print "   Size:", $5, "  Modified:", $6, $7, $8}'
        ((success_count++))
    else
        echo "❌ Failed: ${output_file}"
        ((fail_count++))
    fi
    echo ""
done

echo "================================"
echo "Processing Complete"
echo "================================"
echo "✅ Successful: ${success_count} files"
echo "❌ Failed: ${fail_count} files"
echo "Total processed: $((success_count + fail_count)) files"
echo ""
echo "Output files: me01.mp3 through me10.mp3"
