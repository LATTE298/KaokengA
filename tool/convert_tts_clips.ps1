# แปลงไฟล์เสียง .wav (จาก Google AI Studio) เป็น .opus ขนาดเล็ก ลง assets/tts/
# ดูรายชื่อไฟล์/ข้อความที่ต้องอัดใน docs/TTS_CLIPS.md
#
# วิธีใช้:  ./tool/convert_tts_clips.ps1                 (อ่านจากโฟลเดอร์ tts_raw/ ที่ root)
#          ./tool/convert_tts_clips.ps1 -InDir D:\clips  (หรือระบุโฟลเดอร์เอง)
#
# ต้องมี ffmpeg ใน PATH — ติดตั้ง: winget install Gyan.FFmpeg (แล้วเปิด terminal ใหม่)

param(
  [string]$InDir = (Join-Path $PSScriptRoot '..\tts_raw'),
  [string]$OutDir = (Join-Path $PSScriptRoot '..\assets\tts')
)

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  Write-Error 'ไม่พบ ffmpeg — ติดตั้งด้วย: winget install Gyan.FFmpeg แล้วเปิด terminal ใหม่'
  exit 1
}
if (-not (Test-Path $InDir)) {
  Write-Error "ไม่พบโฟลเดอร์ $InDir — สร้างโฟลเดอร์แล้วเอาไฟล์ .wav ใส่ก่อน"
  exit 1
}

$files = @(Get-ChildItem $InDir -Filter *.wav)
if ($files.Count -eq 0) {
  Write-Host "ไม่มีไฟล์ .wav ใน $InDir"
  exit 0
}

$ok = 0
foreach ($f in $files) {
  $out = Join-Path $OutDir ($f.BaseName + '.opus')
  # mono 32kbps เพียงพอสำหรับเสียงพูด — ไฟล์เล็กกว่า wav ~10 เท่า
  ffmpeg -hide_banner -loglevel error -y -i $f.FullName -c:a libopus -b:a 32k -ac 1 $out
  if ($LASTEXITCODE -eq 0) {
    Write-Host "OK   $($f.Name) -> $($f.BaseName).opus"
    $ok++
  } else {
    Write-Warning "FAIL $($f.Name)"
  }
}

Write-Host ""
Write-Host "แปลงสำเร็จ $ok/$($files.Count) ไฟล์ -> $OutDir"
Write-Host "เช็คชื่อไฟล์ให้ตรงกับ assets/tts/tts_manifest.json แล้ว build/รันแอปได้เลย"
