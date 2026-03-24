$ErrorActionPreference = "Stop"

$repoDir = "c:\Users\dimitri_brosens\Documents\Github\Bishoftu"
Set-Location $repoDir

$renameMap = @{
    "05.1-bioblitz.md" = "06-bioblitz.md"
    "06-belgian-node.md" = "07-belgian-node.md"
    "07-gbif-atlas.md" = "08-gbif-atlas.md"
    "08-break.md" = "09-break.md"
    "09-gbif-science.md" = "10-gbif-science.md"
    "10-gbif-discussion.md" = "11-gbif-discussion.md"
    "11-fair-session.md" = "12-fair-session.md"
    "12-data-management.md" = "13-data-management.md"
    "13-break.md" = "14-break.md"
    "14-openrefine.md" = "15-openrefine.md"
    "15-break.md" = "16-break.md"
    "16.1-openrefine.md" = "17-openrefine.md"
    "16.2-sqlite.md" = "18-sqlite.md"
    "17-break.md" = "19-break.md"
    "18-sqlite.md" = "20-sqlite.md"
    "18.1-discussion.md" = "21-discussion.md"
    "19-introduction-darwin-core.md" = "22-introduction-darwin-core.md"
    "20-break.md" = "23-break.md"
    "21-datacleaning_darwincore.md" = "24-datacleaning_darwincore.md"
    "21.1-gbif-community.md" = "25-gbif-community.md"
    "22-break.md" = "26-break.md"
    "23-create-schema.md" = "27-create-schema.md"
    "24-break.md" = "28-break.md"
    "25-metadata.md" = "29-metadata.md"
    "26-validation-and-publishing.md" = "30-validation-and-publishing.md"
    "26.1-finish.md" = "31-finish.md"
    "27-ipt-basic.md" = "32-ipt-basic.md"
    "27.1-publisher.md" = "33-publisher.md"
    "28-break.md" = "34-break.md"
    "29-ipt-admin.md" = "35-ipt-admin.md"
    "30-break.md" = "36-break.md"
    "31-gbif-registry.md" = "37-gbif-registry.md"
    "32-grscicoll.md" = "38-grscicoll.md"
    "33-break.md" = "39-break.md"
    "33.2-discussion.md" = "41-discussion.md"
    "34-node-opportunities.md" = "42-node-opportunities.md"
    "35-tdwg.md" = "43-tdwg.md"
    "36-break.md" = "44-break.md"
    "37-mentoring.md" = "45-mentoring.md"
    "38-break.md" = "46-break.md"
    "39-bid.md" = "47-bid.md"
    "40-strategy.md" = "48-strategy.md"
    "41-break.md" = "49-break.md"
    "42-strategy.md" = "50-strategy.md"
    "43-post-workshop.md" = "51-post-workshop.md"
    "44-evaluation.md" = "52-evaluation.md"
}

$movedImages = @("ACBmeetings.png", "ambassadors.PNG", "atlas_flanders.PNG", "award.PNG", "bbpf-ipt.png", "bbpf.jpg", "belspo.png", "bid.PNG", "bid2.PNG", "bingo.PNG", "bioblitz.PNG", "bioblitz_croment.PNG", "bishoftu1.png", "CBD-COP15.png", "cesp.PNG", "cespfunded.PNG", "croatia.png", "croatia_atlas.png", "croment.PNG", "cubes.png", "cubes2.png", "cubes3.png", "datacamp.PNG", "datapaper.PNG", "datapublishing.webp", "datause.PNG", "datauseclub.PNG", "data_management.PNG", "data_management1.png", "data_visualisation.png", "DwC-A_closeup.png", "DwCSchema.png", "ebbe.PNG", "ebbewinner.PNG", "ECA2023_Warshaw.png", "Ethiopia1.png", "evaluation", "extra", "forum.PNG", "GB29Brussels.JPG", "gbif.png", "gbif_belgium.PNG", "gbif_belgium2.PNG", "gbif_discussion.PNG", "gbif_introduction.PNG", "gbif_introduction_video.PNG", "gbif_introduction_video2.PNG", "gbif_ipbes.jpg", "gbif_ipbes.PNG", "GBIF_MoU.png", "gbif_science.PNG", "genericworkflow.PNG", "helpdesk.PNG", "hportals.PNG", "ipt.PNG", "iptadmin.PNG", "laslack.PNG", "license.PNG", "livingatlas.PNG", "mentors.PNG", "miniProject.png", "occurrencedata1.png", "openrefine.PNG", "openrefine_tutorial.PNG", "openscience.PNG", "portal.PNG", "portalfeedback.PNG", "portalfeedback2.PNG", "PreparatorySurvey.png", "RegistryInSystem.png", "science.PNG", "session1_occurrenceData.png", "Session2_dataQualit.png", "Session3_introR.png", "session4_dataAnalyse.png", "session_over.png", "session_over2.png", "session_over3.png", "session_over4.png", "session_over5.png", "session_over6.png", "session_over7.png", "session_over8.png", "SQLite.png", "StakeholdersLandscape.png", "standards.PNG", "strategy.PNG", "TDWG2023Hobart.jpg", "thf.PNG", "translators.PNG", "validation.PNG", "validator.PNG", "whydatacleaning.png")

$allMdFiles = Get-ChildItem -Path . -Recurse -Include "*.md", "*.html" | Where-Object { $_.FullName -notmatch "\\\.git\\" -and $_.FullName -notmatch "\\\.Rproj\.user\\" }

Write-Host "Updating links..."
$updatedCount = 0
foreach ($f in $allMdFiles) {
    if ($f.FullName -match "custom-schedule.html") { continue }
    
    $content = Get-Content -Path $f.FullName -Raw -Encoding UTF8
    if ($null -eq $content) { continue }
    $changed = $false
    
    foreach ($key in $renameMap.Keys) {
        $oldBase = [regex]::Escape( ($key -replace "\.md", "") )
        $newBase = ($renameMap[$key] -replace "\.md", "")
        
        if ($content -match "\.\./$oldBase/") {
            $content = $content -replace "\.\./$oldBase/", "../$newBase/"
            $changed = $true
        }
        if ($content -match "$oldBase\.html") {
            $content = $content -replace "$oldBase\.html", "$newBase.html"
            $changed = $true
        }
    }
    
    foreach ($img in $movedImages) {
        $safeImg = [regex]::Escape($img)
        if ($content -match "assets/img/$safeImg") {
            $content = $content -replace "assets/img/$safeImg", "fig/$img"
            $changed = $true
        }
    }
    
    if ($changed) {
        [IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Updated links in: $($f.FullName)"
        $updatedCount++
    }
}
Write-Host "Done. Updated $updatedCount files."
