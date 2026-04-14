[CmdletBinding()]
param(
    [string]$SourcePath = "",
    [string]$OutputDir = "",
    [int]$PartSizeMB = 95
)

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Remove-IfExists {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Force -Recurse
    }
}

$repoRoot = Get-RepoRoot

if (-not $SourcePath) {
    $SourcePath = Join-Path $repoRoot "resources\app.asar"
}

if (-not $OutputDir) {
    $OutputDir = Join-Path $repoRoot "release-assets\app-asar"
}

$sourceItem = Get-Item -LiteralPath $SourcePath
$sourceDir = Split-Path -Parent $sourceItem.FullName
$zipPath = Join-Path $OutputDir "app.asar.zip"
$manifestPath = Join-Path $OutputDir "app.asar.parts.manifest.json"
$sourceShaPath = Join-Path $OutputDir "app.asar.sha256"
$zipShaPath = Join-Path $OutputDir "app.asar.zip.sha256"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Get-ChildItem -LiteralPath $OutputDir -Filter "app.asar.zip.part*" -ErrorAction SilentlyContinue | Remove-Item -Force
Remove-IfExists -Path $zipPath
Remove-IfExists -Path $manifestPath
Remove-IfExists -Path $sourceShaPath
Remove-IfExists -Path $zipShaPath

tar.exe -a -cf $zipPath -C $sourceDir "app.asar"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to compress app.asar. tar.exe exit code: $LASTEXITCODE"
}

$partSizeBytes = $PartSizeMB * 1MB
$bufferSize = 4MB
$buffer = New-Object byte[] $bufferSize
$zipStream = [System.IO.File]::OpenRead($zipPath)

try {
    $partIndex = 1
    $partStreams = @()

    while ($zipStream.Position -lt $zipStream.Length) {
        $partName = "app.asar.zip.part{0:d2}" -f $partIndex
        $partPath = Join-Path $OutputDir $partName
        $partStream = [System.IO.File]::Create($partPath)
        $bytesRemaining = [int64]$partSizeBytes

        try {
            while ($bytesRemaining -gt 0 -and $zipStream.Position -lt $zipStream.Length) {
                $toRead = [Math]::Min($buffer.Length, $bytesRemaining)
                $read = $zipStream.Read($buffer, 0, $toRead)
                if ($read -le 0) {
                    break
                }

                $partStream.Write($buffer, 0, $read)
                $bytesRemaining -= $read
            }
        }
        finally {
            $partStream.Dispose()
        }

        $partStreams += Get-Item -LiteralPath $partPath
        $partIndex++
    }
}
finally {
    $zipStream.Dispose()
}

$sourceSha = Get-Sha256 -Path $sourceItem.FullName
$zipItem = Get-Item -LiteralPath $zipPath
$zipSha = Get-Sha256 -Path $zipPath

"$sourceSha  app.asar" | Set-Content -LiteralPath $sourceShaPath -NoNewline
"$zipSha  app.asar.zip" | Set-Content -LiteralPath $zipShaPath -NoNewline

$parts = foreach ($part in (Get-ChildItem -LiteralPath $OutputDir -Filter "app.asar.zip.part*" | Sort-Object Name)) {
    [pscustomobject]@{
        name = $part.Name
        size = $part.Length
        sha256 = Get-Sha256 -Path $part.FullName
    }
}

$manifest = [pscustomobject]@{
    generated_at = (Get-Date).ToString("s")
    source = [pscustomobject]@{
        name = $sourceItem.Name
        size = $sourceItem.Length
        sha256 = $sourceSha
    }
    zip = [pscustomobject]@{
        name = $zipItem.Name
        size = $zipItem.Length
        sha256 = $zipSha
    }
    split = [pscustomobject]@{
        part_size_mb = $PartSizeMB
        parts = @($parts)
    }
} | ConvertTo-Json -Depth 6

$manifest | Set-Content -LiteralPath $manifestPath

[pscustomobject]@{
    source = $sourceItem.FullName
    source_size_mb = [math]::Round($sourceItem.Length / 1MB, 2)
    zip = $zipPath
    zip_size_mb = [math]::Round($zipItem.Length / 1MB, 2)
    part_count = @($parts).Count
    manifest = $manifestPath
} | ConvertTo-Json -Depth 4
