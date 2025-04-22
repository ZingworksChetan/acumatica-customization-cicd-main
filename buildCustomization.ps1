param (
    [string]$versionName  # Accepts version name as an argument
)

if (-not $versionName) {
    Write-Host "Error: versionName parameter is required."
    exit 1
}

# Construct paths using System.IO to handle special characters properly
$customizationPath = [System.IO.Path]::Combine("Customizations", "AcumaticaUSSFenceCustomizations[2024R1]", "AcumaticaUSSFenceCustomizations[2024R1]")
#$zipFileName = [System.IO.Path]::Combine("acumatica-customization", "Customization", $versionName, "$versionName.zip")
$zipFileName = [System.IO.Path]::Combine("build", "$versionName.zip")
$xmlFilePath = [System.IO.Path]::Combine($customizationPath, "_project", "ProjectMetadata.xml")

# Check if the customization folder exists
if (-not (Test-Path -LiteralPath $customizationPath -PathType Container)) {
    Write-Host "Error: Customization folder does not exist: $customizationPath"
    exit 1
}

# Check if the directory contains files
$files = Get-ChildItem -LiteralPath $customizationPath -Recurse -ErrorAction SilentlyContinue
if (-not $files) {
    Write-Host "Error: Customization files not found in: $customizationPath. Not able to generate ZIP."
    exit 1
}

# Check if XML file exists
if (-not (Test-Path -LiteralPath $xmlFilePath -PathType Leaf)) {
    Write-Host "Error: ProjectMetadata.xml file not found at '$xmlFilePath'"
    exit 1
}

# Load XML and extract project level
[xml]$xmlContent = Get-Content -LiteralPath $xmlFilePath
$Level = $xmlContent.project.level
$Description = $xmlContent.project.description

# Set Level to 0 if it's missing or empty
if (-not $Level -or $Level.Trim() -eq "") {
    Write-Host "Warning: 'Level' is missing or empty in ProjectMetadata.xml. Defaulting to 0."
    $Level = 0
}

if (-not $Description -or $Description.Trim() -eq "") {
    Write-Host "Warning: 'Description' is missing or empty in ProjectMetadata.xml. Defaulting to project name ."
    $Description = $versionName
}

if (![string]::IsNullOrWhiteSpace($zipFileName)) {
    $buildFolder = [System.IO.Path]::GetDirectoryName($zipFileName)
    if (![string]::IsNullOrWhiteSpace($buildFolder) -and !(Test-Path -LiteralPath $buildFolder)) {
        New-Item -ItemType Directory -Path $buildFolder -Force | Out-Null
    }
}

$cmd = "CustomizationPackageTools\bin\Release\net8.0\CustomizationPackageTools.exe"

# Execute the build command safely
&$cmd build --customizationpath "$customizationPath" --packagefilename "$zipFileName" --description "$Description" --level $Level

Write-Host "Customization package created successfully: $zipFileName"
