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

. .\Helpers\LoadConfig.ps1
$compName = $ConfigValues.computerName

RenameComputer -MachineName $compName
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\RenameComputer -Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path .\RenameComputer -Verbose