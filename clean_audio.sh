#!/bin/bash

# 아기 목소리 보존 및 남자 목소리 감소, 노이즈 제거 스크립트
# 남자 목소리: 85-180Hz, 여성 목소리: 165-255Hz, 아기 목소리: 250-400Hz

INPUT_FILE="$1"
OUTPUT_FILE="$2"

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

echo "Processing: $INPUT_FILE → $OUTPUT_FILE"
echo "Step 1: Reducing male voice frequency range (85-180Hz)"
echo "Step 2: Applying noise reduction"
echo "Step 3: Enhancing baby voice clarity (250-400Hz)"

# ffmpeg를 사용한 오디오 처리 (아기 목소리 최적화):
# 1. highpass filter: 남자 목소리의 저주파 제거 (200Hz 이하 감쇠)
# 2. lowpass filter: 고주파 노이즈 제거 (4000Hz 이상 감쇠)
# 3. equalizer: 남자 목소리 주파수 대역 강력 감소 (100Hz, 150Hz, 180Hz)
# 4. equalizer: 아기 목소리 주파수 대역 강화 (280Hz, 320Hz, 360Hz)
# 5. afftdn: 적응형 노이즈 제거
# 6. volume: 볼륨 정규화

ffmpeg -i "$INPUT_FILE" \
    -af "highpass=f=200:poles=2,\
         lowpass=f=4000:poles=2,\
         equalizer=f=100:width_type=h:width=60:g=-12,\
         equalizer=f=150:width_type=h:width=60:g=-10,\
         equalizer=f=180:width_type=h:width=60:g=-8,\
         equalizer=f=280:width_type=h:width=50:g=5,\
         equalizer=f=320:width_type=h:width=50:g=6,\
         equalizer=f=360:width_type=h:width=50:g=5,\
         afftdn=nf=-25:tn=1,\
         volume=1.8" \
    -c:a libmp3lame -q:a 2 \
    "$OUTPUT_FILE" -y

if [ $? -eq 0 ]; then
    echo "✅ Successfully processed: $OUTPUT_FILE"
    ls -lh "$OUTPUT_FILE"
else
    echo "❌ Error processing file"
    exit 1
fi
