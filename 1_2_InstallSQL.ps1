#requires -Version 5

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Configuration SQLSA
{
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module xSQLServer

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }

        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = $Node.SourcePath + "\WindowsServer2012R2\sources\sxs"
        }

        # Install SQL Instances
        foreach($SQLServer in $Node.SQLServers)
        {
            $SQLInstanceName = $SQLServer.InstanceName

            #$Features = "SQLENGINE,FULLTEXT,RS,AS,IS"
            $Features = "SQLENGINE,IS"

            if($Features -ne "")
            {
                xSqlServerSetup ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = "[WindowsFeature]NET-Framework-Core"
                    SourcePath = $Node.SourcePath + "\sql_media\"                    
                    InstanceName = $SQLInstanceName
                    Features = $Features
                    UpdateEnabled = $true
                    UpdateSource = "MU"

                    SetupCredential = $Node.InstallerServiceAccount
                    SQLSysAdminAccounts = $Node.AdminAccount
                    SQLSvcAccount = $Node.SqlServiceAccount
                    AgtSvcAccount = $Node.AgentAccount                    
                    ISSvcAccount = $Node.IntegrationServicesAccount

                    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
                    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
                    InstanceDir = "C:\Program Files\Microsoft SQL Server"
                    InstallSQLDataDir = "C:\Program Files\Microsoft SQL Server"
                    SQLUserDBDir = "C:\SQL\Data"
                    SQLUserDBLogDir = "C:\SQL\Log"
                    SQLTempDBDir = "C:\SQL\Temp"
                    SQLTempDBLogDir = "C:\SQL\Temp"
                    SQLBackupDir = "C:\SQL\Backup"
                    #ASDataDir = "K:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Data"
                    #ASLogDir = "L:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Log"
                    #ASBackupDir = "M:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Backup"
                    #ASTempDir = "N:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Temp"
                    #ASConfigDir = "O:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config"
                }

                # Install SQL Management Tools
                xSqlServerSetup "SQLMT"
                {
                    DependsOn = "[WindowsFeature]NET-Framework-Core"
                    SourcePath = $Node.SourcePath + "\sql_media\"
                    SetupCredential = $Node.InstallerServiceAccount
                    InstanceName = "NULL"
                    Features = "SSMS,ADV_SSMS"
                }
                
                xSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                    SourcePath = $Node.SourcePath + "\sql_media\"
                    InstanceName = $SQLInstanceName
                    Features = $Features
                }
            }
        }
    }
}

$password = ConvertTo-SecureString "P@ssword1" -AsPlainText -Force

$InstallerServiceAccount = New-Object System.Management.Automation.PSCredential("vanilla\administrator", $password)
$sql_account = New-Object System.Management.Automation.PSCredential("vanilla\sql_service", $password)
$agent_Account = New-Object System.Management.Automation.PSCredential("vanilla\sql_agent", $password)
$is_account = New-Object System.Management.Automation.PSCredential("vanilla\sql_is", $password)

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true

            SourcePath = "c:\temp\"
            InstallerServiceAccount = $InstallerServiceAccount
            SqlServiceAccount = $sql_account
            AgentAccount = $agent_Account
            IntegrationServicesAccount = $is_account

            AdminAccount = "vanilla\spadmin"
        }
        @{
            NodeName = "localhost"
            SQLServers = @(
                @{
                    InstanceName = "MSSQLSERVER"
                }
            )
        }
    )
}

SQLSA -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager -Path .\SQLSA -Verbose
Start-DscConfiguration -Path .\SQLSA -Verbose -Wait -Force
