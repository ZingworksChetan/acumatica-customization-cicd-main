param (
    [string]$versionName  # Accepts version name as an argument
)

if (-not $versionName) {
    Write-Host "Error: versionName parameter is required."
    exit 1
}

# Construct paths safely
$customizationPath = [System.IO.Path]::Combine("customization", "Customizations", "AcumaticaUSSFenceCustomizations[2024R1]")
#$zipFilePath = [System.IO.Path]::Combine($customizationPath, "$versionName.zip")
$zipFilePath = [System.IO.Path]::Combine("build", "$versionName.zip")
$xmlFilePath = [System.IO.Path]::Combine($customizationPath, "_project", "ProjectMetadata.xml")

$packageName = $versionName
$serverUrl = $env:ACUMATICA_URL
$username = $env:ACUMATICA_USERNAME
$password = $env:ACUMATICA_PASSWORD

$missing = @()
#Ensure serverUrl exist
if (-not $serverUrl -or $serverUrl.Trim() -eq "") {
    $missing += "ACUMATICA_URL"
}
#Ensure username exist
if (-not $username -or $username.Trim() -eq "") {
    $missing += "ACUMATICA_USERNAME"
}
#Ensure password exist
if (-not $password -or $password.Trim() -eq "") {
    $missing += "ACUMATICA_PASSWORD"
}
if ($missing.Count -gt 0) {
    Write-Host "Error: The following required environment variables are missing:`n - $($missing -join "`n - ")"
    exit 1
}
# Ensure the ZIP file exists
if (-not (Test-Path -LiteralPath $zipFilePath)) {
    Write-Host "Error: Customization package '$zipFilePath' not found. Cannot publish."
    exit 1
}
# Check if XML file exists
if (-not (Test-Path -LiteralPath $xmlFilePath)) {
    Write-Host "Error: ProjectMetadata.xml file not found at '$xmlFilePath'"
    exit 1
}

# Load XML and extract project level and description
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

Write-Host "Level of PackG: $Level"

$cmd = "dlls\CustomizationPackageTool\CustomizationPackageTools.exe"

    # Execute the publish command safely
    &$cmd publish --packagefilename "$zipFilePath" --packagename "$packageName" --url "$serverUrl" --username "$username" --password "$password" --description "$Description" --level "$Level"
