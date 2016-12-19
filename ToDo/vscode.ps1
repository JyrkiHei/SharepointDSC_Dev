$ConfigurationData = @{
    AllNodes = 
    @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

Configuration VSCodeConfig {
    param (
        [pscredential] $Credential
    )
    Import-DscResource -ModuleName VSCode

    Node $AllNodes.NodeName {
        VSCodeSetup VSCodeSetup {
            IsSingleInstance = 'yes'
            Path = 'C:\temp\vscodesetup.exe'
            Ensure = 'Present'
        }

        #vscodeextension PowerShellExtension {
        #    Name = 'ms-vscode.PowerShell'
        #    Ensure = 'Present'
        #    DependsOn = '[vscodesetup]VSCodeSetup'
        #}
    }
}

VSCodeConfig -ConfigurationData $ConfigurationData -Credential (Get-Credential)