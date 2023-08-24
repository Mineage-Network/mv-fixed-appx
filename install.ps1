# EXECUTION POLICY BYPASS START

function Pass-Parameters {
    Param ([hashtable]$NamedParameters)
    return ($NamedParameters.GetEnumerator()|%{"-$($_.Key) `"$($_.Value)`""}) -join " "
}

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`" " + (Pass-Parameters $MyInvocation.BoundParameters) + " " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

# EXECUTION POLICY BYPASS END

$ProgressPreference = 'SilentlyContinue'
$InformationPreference = 'Continue'

$116Url = 'https://github.com/Mineage-Network/mv-fixed-appx/releases/download/1.0.1/1.16.100.4.appx'
$118Url = 'https://github.com/Mineage-Network/mv-fixed-appx/releases/download/1.0.1/1.18.12.1.appx'

Write-Information "mv-fixed-appx: really simple script to either install or switch to xbox authentication fixed versions of Minecraft (1.16.100.4 and 1.18.12.1)."
Write-Information "Brought to you by mineage.us discord.gg/mineagenetwork"
Start-Sleep -Seconds 2
Write-Warning "This script will replace your current Minecraft installation with a patched package (no renderdragon, fixed xbox authentication)."
$choice = Read-Host -Prompt 'Enter 1 to proceed (the script automatically closes Minecraft if open), enter any other value to quit'
if ($choice -eq 1) {
    Write-Information "Killing Minecraft process..."
    $processId = (Get-Process Minecraft.Windows).Id
    Stop-Process -Id $processId
    Write-Information "Done."
    Start-Sleep -Seconds 1
} else {
    Write-Information "Quitting in 3 seconds..."
    Start-Sleep -Seconds 3
    Exit
}

$cerPath = 'null'
$pfxPath = 'null'
$appxPath = 'null'

$choice = Read-Host -Prompt 'Enter 1 to install 1.16.100.4, enter 2 to install 1.18.12.1'
if ( $choice ) {
    Write-Information "Choice entered successfully."
} else {
    Write-Error -Message "You didn't enter a choice."
    Start-Sleep -Seconds 5
    Exit
}

$mvFixedAppxPath = 'C:\Users\' + [Environment]::UserName + '\AppData\Local\Temp\mv-fixed-appx-temp'
if (Test-Path $mvFixedAppxPath) {
    Set-Location 'C:\'
    Remove-Item -Path $mvFixedAppxPath -Recurse -Force
}
New-Item -ItemType Directory -Path $mvFixedAppxPath
Set-Location $mvFixedAppxPath
New-Item -ItemType Directory -Path ($mvFixedAppxPath + '\oldData')

Write-Information "Attempting to download required files..."
$thumbprint = 'null'

if( $choice -eq '1' ) {
    $cerPath = ($mvFixedAppxPath + '\1.16.100.4.cer')
    $thumbprint = '95ea29c5a53b5c80ca7f42c5d30bea1c26382fac'
    $pfxPath = ($mvFixedAppxPath + '\1.16.100.4.pfx')
    $appxPath = ($mvFixedAppxPath + '\1.16.100.4.appx')
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.16.100.4/1.16.100.4.cer" -OutFile $cerPath
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.16.100.4/1.16.100.4.pfx" -OutFile $pfxPath
    Invoke-WebRequest -Uri $116Url -OutFile $appxPath
    Write-Information "Done."
} elseif( $choice -eq '2' ) {
    $cerPath = ($mvFixedAppxPath + '\1.18.12.1.cer')
    $thumbprint = '3dc5cf378d170d1c5083297c522c797ae1dd2e9d'
    $pfxPath = ($mvFixedAppxPath + '\1.18.12.1.pfx')
    $appxPath = ($mvFixedAppxPath + '\1.18.12.1.appx')
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.18.12.1/1.18.12.1.cer" -OutFile $cerPath
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.18.12.1/1.18.12.1.pfx" -OutFile $pfxPath
    Invoke-WebRequest -Uri $118Url -OutFile $appxPath
    Write-Information "Done."
} else {
    Write-Error "Value isn't valid. Try running the script again."
    Start-Sleep -Seconds 3
    Exit
}

Write-Information "Attempting to import .cer certificate..."
$params = @{
    FilePath = $cerPath
    CertStoreLocation = 'Cert:\LocalMachine\Root'
}
Import-Certificate @params

Write-Information "Attempting to import .pfx certificate..."
$params = @{
    FilePath = $pfxPath
    CertStoreLocation = 'Cert:\LocalMachine\My'
}
Import-PfxCertificate @params

$isBackupActive = Read-Host -Prompt 'Do you want to keep your data? Enter 1 to keep it, enter 2 to discard it'
$baseDir = 'C:\Users\' + [Environment]::UserName + '\AppData\Local\Packages'
$dataDir = 'null'
if ($isBackupActive -eq 1) {
    $dataDir = ($baseDir + '\Microsoft.MinecraftUWP_8wekyb3d8bbwe')
    if (Test-Path $dataDir) {
        Copy-Item -LiteralPath $dataDir -Recurse -Destination ($mvFixedAppxPath + '\oldData')
    } else {
        Write-Warning "You don't have any data related to Minecraft."
        $isBackupActive = '2'
    }
}

if( Get-AppxPackage *minecraft* ) {
    Write-Information "Attempting to uninstall Minecraft..."
    Get-AppxPackage *minecraft* | Remove-AppxPackage

    if ( -not(Get-AppxPackage *minecraft*) ) {
        Write-Information "Done."
    }

    else {
        Write-Error "Minecraft uninstallation failed."
        Write-Information "Deleting temp files..."
        Set-Location 'C:\'
        Remove-Item -Path $mvFixedAppxPath -Recurse -Force
        Write-Warning "Closing Powershell script in 5 seconds..."
        Start-Sleep -Seconds 5
        Exit
    }
}

Write-Information "Attempting to install Minecraft..."
Add-AppxPackage $appxPath
if( Get-AppxPackage *minecraft* ) {
    Write-Information "Done."
} else {
    Write-Error "Minecraft wasn't successfully installed."
    Write-Information "Deleting temp files..."
    Set-Location 'C:\'
    Remove-Item -Path $mvFixedAppxPath -Recurse -Force
    Write-Warning "Closing Powershell script in 5 seconds..."
    Start-Sleep -Seconds 5
    Exit
}

if ($isBackupActive -eq 1) {
    if (Test-Path $dataDir) {
        Remove-Item -Path $dataDir -Recurse -Force
    }
    Copy-Item -LiteralPath ($mvFixedAppxPath + '\oldData\Microsoft.MinecraftUWP_8wekyb3d8bbwe') -Recurse -Destination $baseDir
}

Write-Information "Deleting temp files..."
Set-Location 'C:\'
Remove-Item -Path $mvFixedAppxPath -Recurse -Force

Write-Information "Done."
Write-Information "Join our Discord server!"
Start-Process "https://discord.gg/mineagenetwork"
Write-Warning "Closing Powershell script in 5 seconds..."
Start-Sleep -Seconds 5