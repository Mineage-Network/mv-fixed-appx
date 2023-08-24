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

$ProgressPreference = 'SilentlyContinue'

$116Url = 'https://drive.usercontent.google.com/download?id=1jvMz-lftJBNEQLNchbR9CxbGQof1ulgC&export=download&authuser=4&confirm=t&uuid=8fa9b2c4-c76c-4a51-82fa-3400709491d2&at=APZUnTWAlfTsKv3bWSsRsllFYRKK:1692898677781'
$118Url = 'https://drive.usercontent.google.com/download?id=1Od0qCZ_BoTU3Nv6TtlUz861guYPqrqKc&export=download&authuser=4&confirm=t&uuid=8256c431-c54f-4fcb-b444-5eb07cf3a74c&at=APZUnTUiUAQZRRxt1st1aUbxpMMT:1692898652772'

$mvFixedAppxPath = 'C:\Users\' + [Environment]::UserName + '\AppData\Local\Temp\mv-fixed-appx-temp'
New-Item -ItemType Directory -Path $mvFixedAppxPath
Set-Location $mvFixedAppxPath

Write-Information "mv-fixed-appx: really simple script to either install or switch to xbox authentication fixed versions of Minecraft (1.16.100.4 and 1.18.12.1)."
Write-Information "Brought to you by mineage.us discord.gg/mineagenetwork"

Write-Warning "This script will uninstall your current Minecraft installation including data (resource packs, keybinds, saved servers...)."
pause
$cerPath = 'null'
$pfxPath = 'null'
$appxPath = 'null'

$choice = Read-Host -Prompt 'Enter 1 to install 1.16.100.4, enter 2 to install 1.18.12.1'
if ( $choice ) {
    Write-Host "Choice entered successfully."
} else {
    Write-Error -Message "You didn't enter a choice."
    pause
    Exit
}

Write-Information "Attempting to download the required files..."

if( $choice -eq '1' )
{
    $cerPath = ($mvFixedAppxPath + '\1.16.100.4.cer')
    $pfxPath = ($mvFixedAppxPath + '\1.16.100.4.pfx')
    $appxPath = ($mvFixedAppxPath + '\1.16.100.4.appx')
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.16.100.4/1.16.100.4.cer" -OutFile $cerPath
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.16.100.4/1.16.100.4.pfx" -OutFile $pfxPath
    Invoke-WebRequest -Uri $116Url -OutFile $appxPath
}
elseif( $choice -eq '2' )
{
    $cerPath = ($mvFixedAppxPath + '\1.18.12.1.cer')
    $pfxPath = ($mvFixedAppxPath + '\1.18.12.1.pfx')
    $appxPath = ($mvFixedAppxPath + '\1.18.12.1.appx')
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.18.12.1/1.18.12.1.cer" -OutFile $cerPath
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Mineage-Network/mv-fixed-appx/master/1.18.12.1/1.18.12.1.pfx" -OutFile $pfxPath
    Invoke-WebRequest -Uri $118Url -OutFile $appxPath
}
else
{
    Write-Error "Value isn't valid. Try running the script again."
    pause
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
    CertStoreLocation = 'Cert:\LocalMachine\Root'
}
Import-PfxCertificate @params

Write-Information "Attempting to uninstall Minecraft..."
if( Get-AppxPackage *minecraft* )
{
    Get-AppxPackage *minecraft* | Remove-AppxPackage
}

Write-Information "Installing Minecraft..."
Add-AppxPackage $appxPath

Write-Information "Deleting temp files..."
Set-Location 'C:\'
Remove-Item -Path $mvFixedAppxPath -Recurse -Force

Write-Information "Done!"
Write-Information "Join our Discord server!"
Start-Process "https://discord.gg/mineagenetwork"
pause