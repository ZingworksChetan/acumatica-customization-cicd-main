# Acumatica Customization Project
This repository contains the Acumatica customization package for AcumaticaUSSFenceCustomizations[2024R1], with full CI/CD pipeline integration using GitHub Actions.

## Project Structure
```
├── AcumaticaUSSFenceCustomizations[2024R1]     # Main Acumatica customization project
├── Customizations                              # Folder containing Pages, Bin, _project
├── CustomizationPackageTools                   # This tool parses all .xml files in the _project folder to generate project.xml and packages the customization (Bin, Pages, _project) into a deployable ZIP file.
├── buildCustomization.ps1                      # Script to package customization ZIP
├── publishCustomization.ps1                    # Script to publish package to Acumatica Instance
└── .github/workflows                           # GitHub Actions CI/CD workflows
```
