if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
    exit 
}

. .\Helpers\LoadConfig.ps1
. .\Helpers\Set-AutoLogon.ps1

$password = $ConfigValues.LocalAdminPassword
$encPassword = ConvertTo-SecureString $password -AsPlainText -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
.\Helpers\Reset-LocalAdminPassword.ps1 -ComputerName $env:COMPUTERNAME -Password $encPassword
Set-AutoLogon -DefaultUsername "$env:COMPUTERNAME\administrator" -DefaultPassword $password -Script "C:\DSC\_run.cmd"

 