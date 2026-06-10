@echo off
chcp 65001 > nul
title 字幕付き動画を生成中...

cd /d "%~dp0"

if "%~1"=="" (
    echo ================================
    echo  使い方：
    echo  動画ファイルをこの render.bat に
    echo  ドラッグ＆ドロップしてください
    echo ================================
    pause
    exit /b 0
)

set INPUT=%~1
set BASENAME=%~n1
set OUTDIR=%USERPROFILE%\Documents\video-edit\output

mkdir "%OUTDIR%" 2>nul

echo ================================
echo  字幕付き動画生成を開始します
echo  入力: %INPUT%
echo ================================
echo.

echo [Step 1] Whisperで文字起こし中...
venv\Scripts\python.exe transcribe.py "%INPUT%" --out-dir "%OUTDIR%"
if errorlevel 1 (
    echo [エラー] 文字起こしに失敗しました
    pause
    exit /b 1
)

echo.
echo [Step 2] 字幕データをコピー中...
copy /y "%OUTDIR%\%BASENAME%_subtitles.json" "remotion-project\src\subtitles.json" > nul

REM 動画パスをfile://URLに変換（バックスラッシュをスラッシュに）
set VIDEO_URL=file:///%INPUT:\=/%

echo.
echo [Step 3] Remotionで動画をレンダリング中...
set OUTPUT=%OUTDIR%\%BASENAME%_subtitled.mp4
cd remotion-project
npx remotion render SubtitleVideo "%OUTPUT%" --props="{\"videoSrc\":\"%VIDEO_URL%\"}"
cd ..

echo.
echo ================================
echo  完了！
echo  出力: %OUTPUT%
echo ================================
pause
