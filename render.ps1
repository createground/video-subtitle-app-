# 字幕付き動画を生成するメインスクリプト (Windows PowerShell版)
# Usage: .\render.ps1 <input_video.mp4>

param(
    [Parameter(Mandatory=$true)]
    [string]$InputVideo
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Python = "$ScriptDir\venv\Scripts\python.exe"
$RemotionDir = "$ScriptDir\remotion-project"

if (-not (Test-Path $InputVideo)) {
    Write-Error "ファイルが見つかりません: $InputVideo"
    exit 1
}

$InputVideo = Resolve-Path $InputVideo
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputVideo)
$OutDir = "$env:USERPROFILE\Documents\video-edit\output"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "================================" -ForegroundColor Cyan
Write-Host "字幕付き動画生成を開始します"
Write-Host "入力: $InputVideo"
Write-Host "================================" -ForegroundColor Cyan

# Step 1: 文字起こし
Write-Host ""
Write-Host "【Step 1】Whisperで文字起こし中..." -ForegroundColor Yellow
& $Python "$ScriptDir\transcribe.py" "$InputVideo" --out-dir "$OutDir"
if ($LASTEXITCODE -ne 0) { Write-Error "文字起こしに失敗しました"; exit 1 }

$SubtitleJson = "$OutDir\${BaseName}_subtitles.json"

# Step 2: Remotionに字幕をコピー
Write-Host ""
Write-Host "【Step 2】字幕データをRemotionにコピー中..." -ForegroundColor Yellow
Copy-Item $SubtitleJson "$RemotionDir\src\subtitles.json" -Force

New-Item -ItemType Directory -Force -Path "$RemotionDir\public" | Out-Null
Copy-Item $InputVideo "$RemotionDir\public\input.mp4" -Force

# Step 3: Remotionでレンダリング
Write-Host ""
Write-Host "【Step 3】Remotionで動画をレンダリング中..." -ForegroundColor Yellow
$Output = "$OutDir\${BaseName}_subtitled.mp4"
Set-Location $RemotionDir
npx remotion render SubtitleVideo "$Output" --props='{"videoSrc": "input.mp4"}'
Set-Location $ScriptDir

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "完了! 出力: $Output" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
