#!/usr/bin/env python3
"""
動画ファイルを受け取り、Whisperで文字起こしをしてSRTファイルと字幕JSONを生成する
Usage: ./venv/bin/python3 transcribe.py <input_video> [--model medium]
"""
import argparse
import json
import os
import subprocess
import sys

def extract_audio(video_path: str, audio_path: str) -> None:
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        "-vn", "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1",
        audio_path
    ]
    subprocess.run(cmd, check=True, capture_output=True)

def transcribe(audio_path: str, model_name: str) -> list[dict]:
    import whisper
    print(f"Whisperモデル '{model_name}' を読み込み中...", flush=True)
    model = whisper.load_model(model_name)
    print("文字起こし中...", flush=True)
    result = model.transcribe(
        audio_path,
        language="ja",
        word_timestamps=True,
        verbose=False,
    )
    segments = []
    for seg in result["segments"]:
        segments.append({
            "start": seg["start"],
            "end": seg["end"],
            "text": seg["text"].strip(),
        })
    return segments

def segments_to_srt(segments: list[dict]) -> str:
    def fmt(t: float) -> str:
        h = int(t // 3600)
        m = int((t % 3600) // 60)
        s = int(t % 60)
        ms = int((t - int(t)) * 1000)
        return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

    lines = []
    for i, seg in enumerate(segments, 1):
        lines.append(str(i))
        lines.append(f"{fmt(seg['start'])} --> {fmt(seg['end'])}")
        lines.append(seg["text"])
        lines.append("")
    return "\n".join(lines)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="入力動画ファイルパス")
    parser.add_argument("--model", default="medium", help="Whisperモデル名 (default: medium)")
    parser.add_argument("--out-dir", default=None, help="出力ディレクトリ")
    args = parser.parse_args()

    input_path = os.path.abspath(args.input)
    if not os.path.exists(input_path):
        print(f"エラー: ファイルが見つかりません: {input_path}", file=sys.stderr)
        sys.exit(1)

    base = os.path.splitext(os.path.basename(input_path))[0]
    out_dir = args.out_dir or os.path.dirname(input_path)
    os.makedirs(out_dir, exist_ok=True)

    audio_path = os.path.join(out_dir, f"{base}_audio.wav")
    srt_path = os.path.join(out_dir, f"{base}.srt")
    json_path = os.path.join(out_dir, f"{base}_subtitles.json")

    print(f"音声を抽出中: {input_path}", flush=True)
    extract_audio(input_path, audio_path)

    segments = transcribe(audio_path, args.model)

    with open(srt_path, "w", encoding="utf-8") as f:
        f.write(segments_to_srt(segments))
    print(f"SRT出力: {srt_path}")

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(segments, f, ensure_ascii=False, indent=2)
    print(f"JSON出力: {json_path}")

    os.remove(audio_path)
    print("完了!")

if __name__ == "__main__":
    main()
