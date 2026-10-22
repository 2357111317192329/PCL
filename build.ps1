# Build PCL from source.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\build.ps1
#   powershell -ExecutionPolicy Bypass -File .\build.ps1 -Configuration Debug
#
# This script restores NuGet packages, prepares a compatible MSBuild SDK
# directory when the installed Visual Studio lacks the .NET SDK MSBuild
# components, and then builds the main project.

param(
    [ValidateSet('Debug', 'Release', 'Snapshot')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# Files extracted from a downloaded ZIP carry the mark-of-the-web. Newer
# MSBuild versions refuse to process such .resx files (MSB3821), so unblock
# the sources first.
Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

# Locate the .NET SDK.
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) {
    throw 'dotnet was not found. Install the .NET SDK first: https://dotnet.microsoft.com/download'
}
$sdkLine = (& dotnet --list-sdks | Select-Object -Last 1)
if (-not $sdkLine) {
    throw 'No .NET SDK was found. Install one first.'
}
if ($sdkLine -notmatch '^(\S+)\s+\[(.+)\]$') {
    throw "Cannot parse the output of 'dotnet --list-sdks': $sdkLine"
}
$sdkVersion = $Matches[1]
$sdkDir = Join-Path $Matches[2] $sdkVersion

# Prepare a merged SDK directory. Some Visual Studio installations do not ship
# the .NET SDK MSBuild components (missing MSBuild\Sdks), which makes MSBuild
# fail with MSB4236 "The SDK 'Microsoft.NET.Sdk' specified could not be found".
$compatRoot = Join-Path $env:LOCALAPPDATA 'PCLBuild'
$compatSdks = Join-Path $compatRoot 'Sdks'
$stamp = Join-Path $compatRoot 'sdk-version.txt'
$needSetup = $true
if (Test-Path $stamp) {
    if ((Get-Content $stamp -Raw).Trim() -eq $sdkVersion) {
        $needSetup = $false
    }
}
if ($needSetup) {
    Write-Host "Preparing MSBuild SDK compatibility directory for .NET SDK $sdkVersion ..."
    if (Test-Path $compatRoot) {
        Remove-Item $compatRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $compatSdks -Force | Out-Null
    Get-ChildItem (Join-Path $sdkDir 'Sdks') -Directory | ForEach-Object {
        New-Item -ItemType Junction -Path (Join-Path $compatSdks $_.Name) -Target $_.FullName | Out-Null
    }
    $emptyProject = '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003" />'
    $stubs = @(
        @{ Name = 'Microsoft.NET.SDK.WorkloadAutoImportPropsLocator'; File = 'AutoImport.props' },
        @{ Name = 'Microsoft.NET.SDK.WorkloadManifestTargetsLocator'; File = 'WorkloadManifest.targets' }
    )
    foreach ($stub in $stubs) {
        $sdkSub = Join-Path (Join-Path $compatSdks $stub.Name) 'Sdk'
        New-Item -ItemType Directory -Path $sdkSub -Force | Out-Null
        Set-Content -Path (Join-Path $sdkSub 'Sdk.props') -Value $emptyProject -Encoding ASCII
        Set-Content -Path (Join-Path $sdkSub 'Sdk.targets') -Value $emptyProject -Encoding ASCII
        Set-Content -Path (Join-Path $sdkSub $stub.File) -Value $emptyProject -Encoding ASCII
    }
    Copy-Item (Join-Path $sdkDir 'Microsoft.NETCoreSdk.BundledVersions.props') (Join-Path $compatRoot 'Microsoft.NETCoreSdk.BundledVersions.props')
    Set-Content -Path $stamp -Value $sdkVersion -Encoding ASCII
}

# Locate MSBuild.
$msbuild = $null
$cmd = Get-Command msbuild -ErrorAction SilentlyContinue
if ($cmd) {
    $msbuild = $cmd.Source
}
if (-not $msbuild) {
    $candidates = @()
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (Test-Path $vswhere) {
        $path = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($path) {
            $candidates += (Join-Path $path 'MSBuild\Current\Bin\MSBuild.exe')
        }
    }
    $candidates += Get-ChildItem "${env:ProgramFiles}\Microsoft Visual Studio\2022\*\MSBuild\Current\Bin\MSBuild.exe" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
    $candidates += Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft Visual Studio\18\*\MSBuild\Current\Bin\MSBuild.exe" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
    $msbuild = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $msbuild) {
    throw 'MSBuild was not found. Install Visual Studio 2022 (or Build Tools) with the ".NET desktop development" workload.'
}
Write-Host "Using MSBuild: $msbuild"

# Restore NuGet packages.
Write-Host 'Restoring NuGet packages ...'
& dotnet restore (Join-Path $root 'PCLCS\PCLCS.csproj')
if ($LASTEXITCODE -ne 0) {
    throw 'dotnet restore failed.'
}

# Build.
$env:MSBuildSDKsPath = $compatSdks
Write-Host "Building ($Configuration) ..."
& $msbuild (Join-Path $root 'Plain Craft Launcher 2\Plain Craft Launcher 2.vbproj') "-p:Configuration=$Configuration" -m -v:m -nologo
if ($LASTEXITCODE -ne 0) {
    throw 'Build failed.'
}

Write-Host ''
Write-Host "Build succeeded: $(Join-Path $root 'Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe')"
