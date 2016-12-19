Configuration RenameComputer
{
	param
    (
        [Parameter(Mandatory)]
        [string]$MachineName
    )
	
    Import-DscResource -Module xComputerManagement

    Node localhost
    {
		LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }
		
        xComputer NewName
        {
            Name = $MachineName
        }
    }
}

Get-Content "config.txt" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$compName = $h.computerName

RenameComputer -MachineName $compName
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\RenameComputer -Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path .\RenameComputer -Verbose