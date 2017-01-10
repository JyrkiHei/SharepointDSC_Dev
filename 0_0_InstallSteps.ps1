Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Find-Module -Name xComputerManagement -Repository PSGallery | Install-Module
Find-Module -Name xTimeZone -Repository PSGallery | Install-Module
Find-Module -Name SystemLocaleDsc -Repository PSGallery | Install-Module
Find-Module -Name xActiveDirectory -Repository PSGallery | Install-Module
Find-Module -Name xNetworking -Repository PSGallery | Install-Module
Find-Module -Name xPendingReboot -Repository PSGallery | Install-Module
Find-Module -Name SharePointDsc -Repository PSGallery | Install-Module
Find-Module -Name xSQLServer -Repository PSGallery | Install-Module

Import-Module International
Set-Culture fi-FI
Set-WinUserLanguageList fi-FI -Force
Set-WinSystemLocale fi-FI

