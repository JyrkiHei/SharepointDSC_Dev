Configuration Localization
{
   Param
   (
       [String[]]$NodeName = $env:COMPUTERNAME,

       [Parameter(Mandatory = $true)]
       [ValidateNotNullorEmpty()]
       [String]$SystemTimeZone,

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

. .\Helpers\LoadConfig.ps1

$SystemTimeZone = $ConfigValue.SystemTimeZone
$SystemLocale = $ConfigValue.SystemLocale

Localization -NodeName "localhost" -SystemTimeZone $SystemTimeZone -SystemLocale $SystemLocale

Set-DSCLocalConfigurationManager -Path .\Localization -Verbose
Start-DscConfiguration -Path .\Localization -Wait -Verbose -Force