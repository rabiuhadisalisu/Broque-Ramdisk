# Define the output directory
$outputDir = "..\..\Broque Ramdisk v2.3.5"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# NuGet download utility
function Download-NuGetPackage {
    param (
        [string]$packageName,
        [string]$version,
        [string]$outputDirectory
    )
    
    # Check for NuGet CLI
    if (!(Get-Command nuget -ErrorAction SilentlyContinue)) {
        Write-Host "NuGet CLI is not installed. Please download it from https://www.nuget.org/downloads and add it to your PATH."
        exit 1
    }
    
    # Download the package
    $tempDir = Join-Path -Path $env:TEMP -ChildPath $packageName
    nuget install $packageName -Version $version -OutputDirectory $tempDir
    
    # Copy DLLs to the output directory
    $libDir = Join-Path -Path $tempDir -ChildPath "$packageName.$version\lib\net45"
    if (Test-Path $libDir) {
        Copy-Item -Path (Get-ChildItem -Path $libDir -Filter "*.dll") -Destination $outputDirectory -Force
    }
    Remove-Item -Recurse -Force -Path $tempDir
}

# List of required packages
$packages = @(
    @{ Name = "DotNetZip"; Version = "1.15.0" },
    @{ Name = "RestSharp"; Version = "106.15.0" }, # Assuming this is equivalent to LBT.RestSharp
    @{ Name = "Newtonsoft.Json"; Version = "13.0.3" },
    @{ Name = "plist-cil"; Version = "1.0.0" },
    @{ Name = "Renci.SshNet"; Version = "2020.0.1" },
    @{ Name = "System.Data.SQLite"; Version = "1.0.117" }
)

# Download each package
foreach ($pkg in $packages) {
    Write-Host "Downloading $($pkg.Name)..."
    Download-NuGetPackage -packageName $pkg.Name -version $pkg.Version -outputDirectory $outputDir
}

Write-Host "All packages have been downloaded to $outputDir."
