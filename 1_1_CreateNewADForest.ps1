﻿Configuration CreateNewADForest {
    param(
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xNetworking, xPendingReboot

    Node $AllNodes.Where{$_.Role -eq "DC"}.Nodename
    {
       LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }

        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
        }

        xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature RSAT
        {
            Ensure = "Present"
            Name = "RSAT"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
        }  

        xADDomain FirstDC 
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $Node.AdminCreds
            SafemodeAdministratorPassword = $Node.SafeModeAdminCreds
            DomainNetBIOSName = $Node.DomainNameNetbios
            DatabasePath = "C:\NTDS"
            LogPath = "C:\NTDS"
            SysvolPath = "C:\SYSVOL"
            DependsOn = "[WindowsFeature]ADDSInstall","[xDnsServerAddress]DnsServerAddress"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $Node.AdminCreds
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDC"
        } 

        xPendingReboot Reboot1
        { 
            Name = "RebootServer"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}

Get-Content "config.txt" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$DomainName = $h.AD_DomainName
$DomainNameNetbios = $h.AD_DomainNameNetbios

$DomainAdminUser = $h.AD_AdminUserName
$DomainAdminPasswordPlain = $h.AD_AdminUserPassword
$SafeModeAdminUser = "NotNecessary"
$SafeModeAdminPasswordPlain = $h.AD_SafeModeAdminPassword

$DomainAdminPassword = ConvertTo-SecureString $DomainAdminPasswordPlain -AsPlainText -Force
$DomainAdmincreds = New-Object System.Management.Automation.PSCredential ($DomainAdminUser, $DomainAdminPassword)

$SafeModeAdminPassword = ConvertTo-SecureString $SafeModeAdminPasswordPlain -AsPlainText -Force 
$SafeModeAdminCreds = New-Object System.Management.Automation.PSCredential("NotNecessary", $SafeModeAdminPassword)

# Configuration Data for AD              
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = "localhost"             
            Role = "DC"             
            DomainName = $DomainName
            DomainNameNetbios = $DomainNameNetbios
            AdminCreds = $DomainAdmincreds     
            SafeModeAdminCreds = $SafeModeAdminCreds
            RetryCount = 20              
            RetryIntervalSec = 30            
            PsDscAllowPlainTextPassword = $true            
        }            
    )             
}

CreateNewADForest -ConfigurationData $ConfigData

# Make sure that LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\CreateNewADForest\ –Verbose            
            
# Build the domain            
Start-DscConfiguration -Wait -Force -Path .\CreateNewADForest\ -Verbose