@echo off
chcp 65001 > nul
title セットアップ - 字幕付き動画アプリ

echo ================================
echo  初回セットアップを開始します
echo ================================
echo.

cd /d "%~dp0"

REM --- Python確認 ---
python --version > nul 2>&1
if errorlevel 1 (
    echo [エラー] Pythonが見つかりません。
    echo https://www.python.org/downloads/ からインストールしてください。
    pause
    exit /b 1
)
echo [OK] Python確認済み

REM --- Node.js確認 ---
node --version > nul 2>&1
if errorlevel 1 (
    echo [エラー] Node.jsが見つかりません。
    echo wingetでインストールします...
    winget install OpenJS.NodeJS --silent
    echo インストール後、このファイルを再度ダブルクリックしてください。
    pause
    exit /b 1
)
echo [OK] Node.js確認済み

REM --- ffmpeg確認 ---
ffmpeg -version > nul 2>&1
if errorlevel 1 (
    echo [エラー] ffmpegが見つかりません。
    echo wingetでインストールします...
    winget install Gyan.FFmpeg --silent
)
echo [OK] ffmpeg確認済み

REM --- 出力フォルダ作成 ---
mkdir "%USERPROFILE%\Documents\video-edit\input" 2>nul
mkdir "%USERPROFILE%\Documents\video-edit\output" 2>nul
echo [OK] 出力フォルダ作成済み

REM --- Python仮想環境 ---
echo.
echo [1/4] Python仮想環境を作成中...
python -m venv venv
if errorlevel 1 (
    echo [エラー] venvの作成に失敗しました
    pause
    exit /b 1
)
echo [OK] 仮想環境作成済み

REM --- Pythonパッケージ ---
echo.
echo [2/4] Pythonパッケージをインストール中（数分かかります）...
venv\Scripts\python.exe -m pip install --upgrade pip --quiet
venv\Scripts\python.exe -m pip install openai-whisper torch torchaudio silero-vad budoux --quiet
if errorlevel 1 (
    echo [エラー] パッケージのインストールに失敗しました
    pause
    exit /b 1
)
echo [OK] パッケージインストール済み

REM --- Whisperモデル ---
echo.
echo [3/4] Whisperモデルをダウンロード中（約1.5GB、時間がかかります）...
venv\Scripts\python.exe -c "import whisper; whisper.load_model('medium'); print('OK')"
if errorlevel 1 (
    echo [エラー] Whisperモデルのダウンロードに失敗しました
    pause
    exit /b 1
)
echo [OK] Whisperモデル準備済み

REM --- Remotion ---
echo.
echo [4/4] Remotionの依存をインストール中...
cd remotion-project
npm install --silent
cd ..
echo [OK] Remotion準備済み

echo.
echo ================================
echo  セットアップ完了！
echo.
echo  使い方：
echo  動画ファイルを render.bat に
echo  ドラッグ＆ドロップしてください
echo ================================
pause
