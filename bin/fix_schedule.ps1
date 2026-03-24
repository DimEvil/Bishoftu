$ErrorActionPreference = "Stop"

Set-Location "c:\Users\dimitri_brosens\Documents\Github\Bishoftu"

$tmpFiles = Get-ChildItem -Path ".\_episodes" -Filter "TMP_*.md"
foreach ($f in $tmpFiles) {
    $newName = $f.Name -replace "^TMP_", ""
    if (-not (Test-Path ".\_episodes\$newName")) {
        Rename-Item $f.FullName -NewName $newName
    } else {
        # Overwrite if necessary, or skip.
        Remove-Item $f.FullName -Force
    }
}

$schedulePath = ".\_includes\custom-schedule.html"
$content = Get-Content $schedulePath -Raw -Encoding UTF8

$map = @{
    "/05.1-bioblitz/" = "/06-bioblitz/"
    "/06-belgian-node/" = "/07-belgian-node/"
    "/08-break/" = "/09-break/"
    "/07-gbif-atlas/" = "/08-gbif-atlas/"
    "/09-gbif-science/" = "/10-gbif-science/"
    "/10-gbif-discussion/" = "/11-gbif-discussion/"
    "/11-fair-session/" = "/12-fair-session/"
    "/13-break/" = "/14-break/"
    "/12-data-management/" = "/13-data-management/"
    "/15-break/" = "/16-break/"
    "/14-openrefine/" = "/15-openrefine/"
    "/17-break/" = "/19-break/"
    "/16.2-sqlite/" = "/18-sqlite/"
    "/19-introduction-darwin-core/" = "/22-introduction-darwin-core/"
    "/20-break/" = "/23-break/"
    "/21-datacleaning_darwincore/" = "/24-datacleaning_darwincore/"
    "/22-break/" = "/26-break/"
    "/21.1-gbif-community/" = "/25-gbif-community/"
    "/23-create-schema/" = "/27-create-schema/"
    "/25-metadata/" = "/29-metadata/"
    "/27-ipt-basic/" = "/32-ipt-basic/"
    "/24-break/" = "/28-break/"
    "/28-break/" = "/34-break/"
    "/27.1-publisher/" = "/33-publisher/"
    "/30-break/" = "/36-break/"
    "/29-ipt-admin/" = "/35-ipt-admin/"
    "/33-break/" = "/39-break/"
    "/32-grscicoll/" = "/38-grscicoll/"
}

foreach ($old in $map.Keys) {
    $new = $map[$old]
    $content = $content -replace [regex]::Escape($old), $new
}

[IO.File]::WriteAllText($schedulePath, $content, [System.Text.Encoding]::UTF8)

Write-Host "Schedule links updated and TMP_ stripped successfully!"
