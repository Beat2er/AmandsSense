# AmandsSense Release Build Script
# Creates a release package with proper BepInEx structure

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [Parameter(Mandatory=$true)]
    [string]$SPTPath,

    [Parameter(Mandatory=$false)]
    [string]$AssetsPath = ".\Assets\Sense",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\release"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== AmandsSense Release Builder ===" -ForegroundColor Cyan
Write-Host "Configuration: $Configuration" -ForegroundColor Gray
Write-Host "SPT Path: $SPTPath" -ForegroundColor Gray
Write-Host "Assets Path: $AssetsPath" -ForegroundColor Gray
Write-Host "Output Path: $OutputPath`n" -ForegroundColor Gray

# Validate paths
if (-not (Test-Path $SPTPath)) {
    Write-Host "ERROR: SPT installation not found: $SPTPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $AssetsPath)) {
    Write-Host "ERROR: Assets folder not found: $AssetsPath" -ForegroundColor Red
    Write-Host "Make sure you have the Assets/Sense folder with images/, sounds/, and Items.json" -ForegroundColor Yellow
    exit 1
}

# Get version from csproj
$csprojPath = "AmandsSense\AmandsSense.csproj"
$csprojContent = Get-Content $csprojPath -Raw
if ($csprojContent -match '<Version>([^<]+)</Version>') {
    $version = $Matches[1]
} else {
    Write-Host "ERROR: Could not extract version from $csprojPath" -ForegroundColor Red
    exit 1
}

Write-Host "Building AmandsSense v$version..." -ForegroundColor Yellow

# Setup References from SPT installation
Write-Host "`nSetting up References from SPT..." -ForegroundColor Yellow
$referencesRoot = "References"
$folders = @(
    "$referencesRoot\BepInEx",
    "$referencesRoot\Managed",
    "$referencesRoot\spt"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# Copy required DLLs
$dllMappings = @{
    "$SPTPath\BepInEx\core\0Harmony.dll" = "$referencesRoot\BepInEx\0Harmony.dll"
    "$SPTPath\BepInEx\core\BepInEx.dll" = "$referencesRoot\BepInEx\BepInEx.dll"
    "$SPTPath\BepInEx\plugins\spt-reflection.dll" = "$referencesRoot\spt\spt-reflection.dll"
    "$SPTPath\BepInEx\plugins\spt-common.dll" = "$referencesRoot\spt\spt-common.dll"
    "$SPTPath\BepInEx\plugins\spt-custom.dll" = "$referencesRoot\spt\spt-custom.dll"
    "$SPTPath\BepInEx\plugins\spt-core.dll" = "$referencesRoot\spt\spt-core.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Assembly-CSharp.dll" = "$referencesRoot\Managed\Assembly-CSharp.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Assembly-CSharp-firstpass.dll" = "$referencesRoot\Managed\Assembly-CSharp-firstpass.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Comfort.dll" = "$referencesRoot\Managed\Comfort.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Comfort.Unity.dll" = "$referencesRoot\Managed\Comfort.Unity.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\ItemComponent.Types.dll" = "$referencesRoot\Managed\ItemComponent.Types.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\ItemTemplate.Types.dll" = "$referencesRoot\Managed\ItemTemplate.Types.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Newtonsoft.Json.dll" = "$referencesRoot\Managed\Newtonsoft.Json.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Sirenix.OdinInspector.Attributes.dll" = "$referencesRoot\Managed\Sirenix.OdinInspector.Attributes.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Sirenix.Serialization.dll" = "$referencesRoot\Managed\Sirenix.Serialization.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Sirenix.Serialization.Config.dll" = "$referencesRoot\Managed\Sirenix.Serialization.Config.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Sirenix.Utilities.dll" = "$referencesRoot\Managed\Sirenix.Utilities.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.dll" = "$referencesRoot\Managed\UnityEngine.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.CoreModule.dll" = "$referencesRoot\Managed\UnityEngine.CoreModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.PhysicsModule.dll" = "$referencesRoot\Managed\UnityEngine.PhysicsModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.AudioModule.dll" = "$referencesRoot\Managed\UnityEngine.AudioModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.UIModule.dll" = "$referencesRoot\Managed\UnityEngine.UIModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.UI.dll" = "$referencesRoot\Managed\UnityEngine.UI.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.IMGUIModule.dll" = "$referencesRoot\Managed\UnityEngine.IMGUIModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.AnimationModule.dll" = "$referencesRoot\Managed\UnityEngine.AnimationModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.ParticleSystemModule.dll" = "$referencesRoot\Managed\UnityEngine.ParticleSystemModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.TextRenderingModule.dll" = "$referencesRoot\Managed\UnityEngine.TextRenderingModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.ImageConversionModule.dll" = "$referencesRoot\Managed\UnityEngine.ImageConversionModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.InputLegacyModule.dll" = "$referencesRoot\Managed\UnityEngine.InputLegacyModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.UnityWebRequestModule.dll" = "$referencesRoot\Managed\UnityEngine.UnityWebRequestModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.UnityWebRequestAudioModule.dll" = "$referencesRoot\Managed\UnityEngine.UnityWebRequestAudioModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\UnityEngine.UnityWebRequestTextureModule.dll" = "$referencesRoot\Managed\UnityEngine.UnityWebRequestTextureModule.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Unity.TextMeshPro.dll" = "$referencesRoot\Managed\Unity.TextMeshPro.dll"
    "$SPTPath\EscapeFromTarkov_Data\Managed\Unity.Postprocessing.Runtime.dll" = "$referencesRoot\Managed\Unity.Postprocessing.Runtime.dll"
}

$copied = 0
foreach ($entry in $dllMappings.GetEnumerator()) {
    $source = $entry.Key
    $dest = $entry.Value
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        $copied++
    } else {
        Write-Host "  WARNING: DLL not found: $source" -ForegroundColor Yellow
    }
}
Write-Host "  Copied $copied DLLs from SPT installation" -ForegroundColor Green

# Build the project
Write-Host "`nBuilding project..." -ForegroundColor Yellow
dotnet build AmandsSense\AmandsSense.csproj -c $Configuration

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Create release structure
Write-Host "`nCreating release package..." -ForegroundColor Yellow

$releaseDir = "$OutputPath\BepInEx\plugins"
$senseDir = "$releaseDir\Sense"

# Clean and create directories
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
New-Item -ItemType Directory -Path $senseDir -Force | Out-Null

# Copy DLL
$sourceDll = "AmandsSense\bin\$Configuration\netstandard2.1\AmandsSense.dll"
if (Test-Path $sourceDll) {
    Copy-Item $sourceDll $releaseDir -Force
    Write-Host "  Copied AmandsSense.dll" -ForegroundColor Green
} else {
    Write-Host "ERROR: Built DLL not found: $sourceDll" -ForegroundColor Red
    exit 1
}

# Copy Assets
if (Test-Path "$AssetsPath\images") {
    Copy-Item "$AssetsPath\images" "$senseDir\images" -Recurse -Force
    $imageCount = (Get-ChildItem "$senseDir\images" -Filter *.png).Count
    Write-Host "  Copied $imageCount images" -ForegroundColor Green
}

if (Test-Path "$AssetsPath\sounds") {
    Copy-Item "$AssetsPath\sounds" "$senseDir\sounds" -Recurse -Force
    Write-Host "  Copied sounds folder" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Path "$senseDir\sounds" -Force | Out-Null
    Write-Host "  Created empty sounds folder" -ForegroundColor Gray
}

if (Test-Path "$AssetsPath\Items.json") {
    Copy-Item "$AssetsPath\Items.json" $senseDir -Force
    Write-Host "  Copied Items.json" -ForegroundColor Green
}

# Create zip archive
$zipName = "AmandsSense.$version.zip"
Write-Host "`nCreating archive: $zipName..." -ForegroundColor Yellow

if (Test-Path $zipName) {
    Remove-Item $zipName -Force
}

# Compress from within the release directory to get correct structure
Push-Location $OutputPath
Compress-Archive -Path "BepInEx" -DestinationPath "..\$zipName" -CompressionLevel Optimal
Pop-Location

if (Test-Path $zipName) {
    $zipInfo = Get-Item $zipName
    Write-Host "`n=== Release Package Created ===" -ForegroundColor Cyan
    Write-Host "File: $zipName" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($zipInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "`nStructure:" -ForegroundColor Gray
    Write-Host "  BepInEx/" -ForegroundColor Gray
    Write-Host "    plugins/" -ForegroundColor Gray
    Write-Host "      AmandsSense.dll" -ForegroundColor Gray
    Write-Host "      Sense/" -ForegroundColor Gray
    Write-Host "        images/ ($imageCount files)" -ForegroundColor Gray
    Write-Host "        sounds/" -ForegroundColor Gray
    Write-Host "        Items.json" -ForegroundColor Gray
    Write-Host "`nReady for distribution!`n" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to create zip archive" -ForegroundColor Red
    exit 1
}
