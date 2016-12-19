Configuration DisableLocalIEEsc
{
    Import-DSCResource -Module xSystemSecurity -Name xIEEsc

    Node localhost
    {
        xIEEsc DisableIEEsc
        {
            IsEnabled = $false
            UserRole = "Users"
        }

        xIEESC IEESC 
        { 
            IsEnabled = $False
            UserRole = "Administrators"  
        }
    }
}

DisableLocalIEEsc