$ErrorActionPreference = "Stop"
$repoDir = "c:\Users\dimitri_brosens\Documents\Github\Bishoftu"
Set-Location $repoDir

$allMdFiles = Get-ChildItem -Path . -Recurse -Include "*.md", "*.html" | Where-Object { $_.FullName -notmatch "\\\.git\\" }

$count = 0
foreach ($f in $allMdFiles) {
    if (-not (Test-Path $f.FullName -PathType Leaf)) { continue }
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $newBytes = new-object byte[] ($bytes.Length - 3)
        [System.Array]::Copy($bytes, 3, $newBytes, 0, $newBytes.Length)
        [System.IO.File]::WriteAllBytes($f.FullName, $newBytes)
        Write-Host "Removed BOM from: $($f.FullName)"
        $count++
    }
}
Write-Host "Removed BOM from $count files."

if (Test-Path ".\_site") { Remove-Item -Recurse -Force ".\_site" }
if (Test-Path ".\.jekyll-cache") { Remove-Item -Recurse -Force ".\.jekyll-cache" }
