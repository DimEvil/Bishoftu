$ErrorActionPreference = "Stop"

$repoDir = "c:\Users\dimitri_brosens\Documents\Github\Bishoftu"
Set-Location $repoDir

$episodesDir = ".\_episodes"
$assetsImgDir = ".\assets\img"
$figDir = ".\fig"

Write-Host "Renaming episodes..."
$files = Get-ChildItem -Path $episodesDir -Filter "*.md" | Where-Object Name -match "^\d"
$mapped = @()
foreach ($f in $files) {
    if ($f.Name -match "^(\d+(?:\.\d+)?)") {
        $num = [double]$matches[1]
        $mapped += [PSCustomObject]@{ File = $f; Num = $num }
    }
}
$sorted = $mapped | Sort-Object Num

$renameMap = @{}
$i = 1
# Pass 1: rename to temporary names
foreach ($item in $sorted) {
    $oldName = $item.File.Name
    $newName = "{0:D2}-{1}" -f $i, ($oldName -replace "^\d+(?:\.\d+)?-", "")
    if ($oldName -ne $newName) {
        $tmpName = "TMP_$newName"
        $renameMap[$oldName] = $tmpName
        Rename-Item -Path $item.File.FullName -NewName $tmpName
    }
    $i++
}

# Pass 2: rename from temporary names to final names
foreach ($oldName in $renameMap.Keys) {
    $tmpName = $renameMap[$oldName]
    $finalName = $tmpName -replace "^TMP_", ""
    $renameMap[$oldName] = $finalName
    Rename-Item -Path (Join-Path $episodesDir $tmpName) -NewName $finalName
    Write-Host "Renamed: $oldName -> $finalName"
}

Write-Host "`nMoving images..."
$themeIcons = @("swc-icon-blue.svg", "swc-logo-blue.png", "swc-logo-white.png", "swc-logo-white.svg", "dc-icon-black.svg", "dc-logo-black.svg", "lc-icon-black.png", "lc-icon-black.svg", "lc-logo-black.png", "lc-logo-black.svg", "cp-logo-blue.svg", "carpentrieslab.svg", "incubator-logo-blue.svg")

$movedItems = @()
if (Test-Path $assetsImgDir) {
    $items = Get-ChildItem -Path $assetsImgDir
    foreach ($item in $items) {
        if ($themeIcons -notcontains $item.Name) {
            $destPath = Join-Path $figDir $item.Name
            
            if (-not (Test-Path $destPath)) {
                Move-Item -Path $item.FullName -Destination $figDir
            } else {
                if ($item.PSIsContainer) {
                    Get-ChildItem -Path $item.FullName | Move-Item -Destination $destPath -Force
                    Remove-Item -Path $item.FullName -Recurse
                } else {
                    Remove-Item -Path $item.FullName
                }
            }
            $movedItems += $item.Name
            Write-Host "Moved/Processed: $($item.Name)"
        }
    }
}

Write-Host "`nUpdating links..."
$allMdFiles = Get-ChildItem -Path . -Recurse -Include *.md, *.html | Where-Object { $_.FullName -notmatch "\\\.git\\" -and $_.FullName -notmatch "\\\.Rproj\.user\\" }

foreach ($f in $allMdFiles) {
    $content = Get-Content -Path $f.FullName -Raw -Encoding UTF8
    if ($null -eq $content) { continue }
    $changed = $false
    
    foreach ($key in $renameMap.Keys) {
        $oldBase = [regex]::Escape($key -replace "\.md", "")
        $newBase = $renameMap[$key] -replace "\.md", ""
        if ($content -match "\.\./$oldBase/") {
            $content = $content -replace "\.\./$oldBase/", "../$newBase/"
            $changed = $true
        }
        if ($content -match "$oldBase\.html") {
            $content = $content -replace "$oldBase\.html", "$newBase.html"
            $changed = $true
        }
    }
    
    foreach ($img in $movedItems) {
        $safeImg = [regex]::Escape($img)
        if ($content -match "assets/img/$safeImg") {
            $content = $content -replace "assets/img/$safeImg", "fig/$img"
            $changed = $true
        }
    }
    
    if ($changed) {
        [IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Updated links in: $($f.FullName)"
    }
}

Write-Host "`nStructure fixing completed successfully."
