$currentDir = (pwd).Path
$cerPath = $currentDir + '\Minecraft-1.16.100.4.cer'
$pfxPath = $currentDir + '\Minecraft-1.16.100.4.pfx'
$appxPath = $currentDir + '\Minecraft-1.16.100.4.appx'

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

$params = @{
    FilePath = $cerPath
    CertStoreLocation = 'Cert:\LocalMachine\Root'
}

Import-Certificate @params

$params = @{
    FilePath = $pfxPath
    CertStoreLocation = 'Cert:\LocalMachine\Root'
}

Import-PfxCertificate @params

Add-AppxPackage $appxPath
pause