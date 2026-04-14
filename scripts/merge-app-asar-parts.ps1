[CmdletBinding()]
param(
    [string]$InputDir = "",
    [string]$OutputZipPath = "",
    [string]$ExtractTo = "",
    [switch]$SkipVerification
)

$ErrorActionPreference = "Stop"

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$repoRoot = Get-RepoRoot

if (-not $InputDir) {
    $InputDir = Join-Path $repoRoot "release-assets\app-asar"
}

if (-not $OutputZipPath) {
    $OutputZipPath = Join-Path $InputDir "app.asar.zip"
}

if (-not $ExtractTo) {
    $ExtractTo = Join-Path $InputDir "extracted"
}

$manifestPath = Join-Path $InputDir "app.asar.parts.manifest.json"
$partFiles = Get-ChildItem -LiteralPath $InputDir -Filter "app.asar.zip.part*" | Sort-Object Name

if (-not $partFiles) {
    throw "No app.asar part files were found."
}

if (Test-Path -LiteralPath $OutputZipPath) {
    Remove-Item -LiteralPath $OutputZipPath -Force
}

$outStream = [System.IO.File]::Create($OutputZipPath)
$buffer = New-Object byte[] (4MB)

try {
    foreach ($part in $partFiles) {
        $inStream = [System.IO.File]::OpenRead($part.FullName)
        try {
            while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outStream.Write($buffer, 0, $read)
            }
        }
        finally {
            $inStream.Dispose()
        }
    }
}
finally {
    $outStream.Dispose()
}

$zipSha = Get-Sha256 -Path $OutputZipPath

if ((-not $SkipVerification) -and (Test-Path -LiteralPath $manifestPath)) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.zip.sha256 -ne $zipSha) {
        throw "Merged zip hash mismatch. Expected: $($manifest.zip.sha256), Actual: $zipSha"
    }
}

New-Item -ItemType Directory -Force -Path $ExtractTo | Out-Null
tar.exe -xf $OutputZipPath -C $ExtractTo
if ($LASTEXITCODE -ne 0) {
    throw "Failed to extract app.asar.zip. tar.exe exit code: $LASTEXITCODE"
}

[pscustomobject]@{
    output_zip = $OutputZipPath
    output_zip_sha256 = $zipSha
    extracted_to = $ExtractTo
    extracted_file = (Join-Path $ExtractTo "app.asar")
} | ConvertTo-Json -Depth 4
