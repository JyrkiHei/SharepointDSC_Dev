configuration NewDomain             
{             
   param             
    (             
        [Parameter(Mandatory)]             
        [pscredential]$safemodeAdministratorCred,             
        [Parameter(Mandatory)]            
        [pscredential]$domainCred            
    )             
            
    Import-DscResource -ModuleName xActiveDirectory             
            
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename             
    {             
            
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }            
            
        File ADFiles            
        {            
            DestinationPath = 'N:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }            
                    
        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"             
        }            
            
        # Optional GUI tools            
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
            
        # No slash at end of folder paths            
        xADDomain FirstDS             
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $domainCred             
            SafemodeAdministratorPassword = $safemodeAdministratorCred            
            DatabasePath = 'N:\NTDS'            
            LogPath = 'N:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }            
            
    }             
}     

. .\Helpers\LoadConfig.ps1     

$DomainName = $ConfigValues.AD_DomainName
$DomainNameNetbios = $ConfigValues.AD_DomainNameNetbios

$DomainAdminUser = $ConfigValues.AD_AdminUserName
$DomainAdminPasswordPlain = $ConfigValues.AD_AdminUserPassword
$SafeModeAdminUser = "NotNecessary"
$SafeModeAdminPasswordPlain = $ConfigValues.AD_SafeModeAdminPassword

$DomainAdminPassword = ConvertTo-SecureString $DomainAdminPasswordPlain -AsPlainText -Force
$DomainAdmincreds = New-Object System.Management.Automation.PSCredential ($DomainAdminUser, $DomainAdminPassword)

$SafeModeAdminPassword = ConvertTo-SecureString $SafeModeAdminPasswordPlain -AsPlainText -Force 
$SafeModeAdminCreds = New-Object System.Management.Automation.PSCredential("NotNecessary", $SafeModeAdminPassword)  
            
# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "localhost"             
            Role = "Primary DC"             
            DomainName = $DomainName             
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }            
    )             
}

            
NewDomain -ConfigurationData $ConfigData -safemodeAdministratorCred $SafeModeAdminCreds -domainCred $DomainAdmincreds
            
# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\ -Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path .\ -Verbose