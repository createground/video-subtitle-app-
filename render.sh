#!/bin/bash
# 字幕付き動画を生成するメインスクリプト
# Usage: ./render.sh <input_video.mp4>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON="$SCRIPT_DIR/venv/bin/python3"
REMOTION_DIR="$SCRIPT_DIR/remotion-project"

if [ -z "$1" ]; then
  echo "使い方: $0 <input_video.mp4>"
  exit 1
fi

INPUT="$(realpath "$1")"
BASENAME="$(basename "$INPUT" .mp4)"
OUT_DIR="$HOME/Documents/video-edit/output"
mkdir -p "$OUT_DIR"

echo "================================"
echo "字幕付き動画生成を開始します"
echo "入力: $INPUT"
echo "================================"

# Step 1: 文字起こし
echo ""
echo "【Step 1】Whisperで文字起こし中..."
$PYTHON "$SCRIPT_DIR/transcribe.py" "$INPUT" --out-dir "$OUT_DIR"

SUBTITLE_JSON="$OUT_DIR/${BASENAME}_subtitles.json"

# Step 2: Remotionプロジェクトに字幕をコピー
echo ""
echo "【Step 2】字幕データをRemotionにコピー中..."
cp "$SUBTITLE_JSON" "$REMOTION_DIR/src/subtitles.json"
cp "$INPUT" "$REMOTION_DIR/public/input.mp4"

# Step 3: Remotionでレンダリング
echo ""
echo "【Step 3】Remotionで動画をレンダリング中..."
OUTPUT="$OUT_DIR/${BASENAME}_subtitled.mp4"
cd "$REMOTION_DIR"
npx remotion render SubtitleVideo "$OUTPUT" \
  --props='{"videoSrc": "input.mp4"}' \
  --log=verbose 2>&1 | grep -E "(Rendering|Progress|Encoded|error|Error|✓|✗)" || true

echo ""
echo "================================"
echo "完了! 出力: $OUTPUT"
echo "================================"
