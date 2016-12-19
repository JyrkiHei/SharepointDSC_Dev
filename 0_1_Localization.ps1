Configuration Localization
{
   Param
   (
       [String[]]$NodeName = $env:COMPUTERNAME,

       [Parameter(Mandatory = $true)]
       [ValidateNotNullorEmpty()]
       [String]$SystemTimeZone

       [Parameter(Mandatory = $true)]
       [ValidateNotNullorEmpty()]
       [String] $SystemLocale
   )

   Import-DSCResource -ModuleName xTimeZone, SystemLocaleDsc

   Node $NodeName
   {
		LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        }
		
        xTimeZone TimeZoneExample
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $SystemTimeZone
        }

        SystemLocale SystemLocale
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $SystemLocale
        }

   }
}

Localization -NodeName "localhost" -SystemTimeZone "E. Europe Standard Time" -SystemLocale "fi-FI"

Set-DSCLocalConfigurationManager -Path .\Localization –Verbose # Make sure that LCM is set to continue configuration after reboot 
Start-DscConfiguration -Path .\Localization -Wait -Verbose -Force