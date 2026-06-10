# 初回セットアップスクリプト (Windows PowerShell版)
# PowerShellを管理者として実行してください

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "================================" -ForegroundColor Cyan
Write-Host "初回セットアップを開始します"
Write-Host "================================" -ForegroundColor Cyan

# 1. wingetでffmpegとNode.jsをインストール
Write-Host ""
Write-Host "【1】ffmpeg, Node.js を確認中..." -ForegroundColor Yellow

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "ffmpegをインストール中..."
    winget install Gyan.FFmpeg --silent
} else {
    Write-Host "ffmpeg: OK" -ForegroundColor Green
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.jsをインストール中..."
    winget install OpenJS.NodeJS --silent
} else {
    Write-Host "Node.js: OK" -ForegroundColor Green
}

# 2. Python仮想環境の作成
Write-Host ""
Write-Host "【2】Python仮想環境を作成中..." -ForegroundColor Yellow
Set-Location $ScriptDir
python -m venv venv
if ($LASTEXITCODE -ne 0) { Write-Error "Python venvの作成に失敗しました"; exit 1 }

# 3. Pythonパッケージのインストール
Write-Host ""
Write-Host "【3】Pythonパッケージをインストール中（時間がかかります）..." -ForegroundColor Yellow
& ".\venv\Scripts\python.exe" -m pip install --upgrade pip
& ".\venv\Scripts\python.exe" -m pip install openai-whisper torch torchaudio silero-vad budoux
if ($LASTEXITCODE -ne 0) { Write-Error "パッケージのインストールに失敗しました"; exit 1 }

# 4. Whisperモデルのダウンロード
Write-Host ""
Write-Host "【4】Whisperモデルをダウンロード中（約1.5GB、時間がかかります）..." -ForegroundColor Yellow
& ".\venv\Scripts\python.exe" -c "import whisper; whisper.load_model('medium'); print('Whisper OK')"

# 5. Remotionの依存インストール
Write-Host ""
Write-Host "【5】Remotionの依存をインストール中..." -ForegroundColor Yellow
Set-Location "$ScriptDir\remotion-project"
npm install
Set-Location $ScriptDir

# 6. 出力フォルダの作成
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Documents\video-edit\input" | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Documents\video-edit\output" | Out-Null

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "セットアップ完了!" -ForegroundColor Green
Write-Host ""
Write-Host "使い方:"
Write-Host "  .\render.ps1 C:\Users\あなた\Documents\video-edit\input\動画.mp4"
Write-Host "================================" -ForegroundColor Green
