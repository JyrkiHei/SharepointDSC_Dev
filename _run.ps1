if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
    exit 
}

. C:\DSC\Helpers\LoadConfig.ps1

[int]$status = 1

if(Test-Path C:\DSC\_status.cnf)
{
    [int]$status = Get-Content _status.cnf
}
else {
    $status > '_status.cnf'
}

switch ($status) 
    { 
        1 { .\0_0_InstallSteps.ps1 } 
        2 {"The color is blue."} 
        3 {"The color is green."} 
        4 {"The color is yellow."} 
        5 {"The color is orange."} 
        6 {"The color is purple."} 
        7 {"The color is pink."}
        8 {"The color is brown."} 
        default {"The color could not be determined."}
    }



