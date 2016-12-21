<# 
.SYNOPSIS
    Downloads a file showing the progress of the download
.DESCRIPTION
    This Script will download a file locally while showing the progress of the download 
.EXAMPLE
    .\Download-File.ps1 'http:\\someurl.com\somefile.zip'
.EXAMPLE
    .\Download-File.ps1 'http:\\someurl.com\somefile.zip' 'C:\Temp\somefile.zip'
.PARAMETER url
    url to be downloaded
.PARAMETER localFile
    the local filename where the download should be placed
.NOTES
    FileName     : Download-File.ps1
    Author       : CrazyDave
    LastModified : 18 Jan 2011 9:39 AM PST
#Requires -Version 2.0 
#>
param(
    [Parameter(Mandatory=$true)]
    [String] $url,
    [Parameter(Mandatory=$false)]
    [String] $localFile = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/'))) 
)

begin {
        $client = New-Object System.Net.WebClient
    $Global:downloadComplete = $false

    $eventDataComplete = Register-ObjectEvent $client DownloadFileCompleted `
        -SourceIdentifier WebClient.DownloadFileComplete `
        -Action {$Global:downloadComplete = $true}
    $eventDataProgress = Register-ObjectEvent $client DownloadProgressChanged `
        -SourceIdentifier WebClient.DownloadProgressChanged `
        -Action { $Global:DPCEventArgs = $EventArgs }
}

process {
    Write-Progress -Activity 'Downloading file' -Status $url
    $client.DownloadFileAsync($url, $localFile)
    
    while (!($Global:downloadComplete)) {
        $pc = $Global:DPCEventArgs.ProgressPercentage
        if ($pc -ne $null) {
            Write-Progress -Activity 'Downloading file' -Status $url -PercentComplete $pc
        }
    }
    
    Write-Progress -Activity 'Downloading file' -Status $url -Complete
}

end {
    Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
    Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete
    $client.Dispose()
    $Global:downloadComplete = $null
    $Global:DPCEventArgs = $null
    Remove-Variable client
    Remove-Variable eventDataComplete
    Remove-Variable eventDataProgress
    [GC]::Collect()
}

#Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkID=623230 -OutFile "C:\tmp\dsc\Software\vs_code.exe"


#DownloadFile("https://go.microsoft.com/fwlink/?LinkID=623230", "C:\Users\WMLI049045\OneDrive\Työ\VMKoneet\DSC_Stuff\Scripts\Software\vs_code.exe");

#.\DownloadHelper.ps1 'https://go.microsoft.com/fwlink/?LinkID=623230' 'C:\tmp\dsc\Software\vs_code.exe'

# Sharepoint 2016 https://my.visualstudio.com/Downloads?pid=2033
# en_sharepoint_server_2016_x64_dvd_8419458.iso
# Sharepoint 2013 + SP1 https://my.visualstudio.com/Downloads?pid=1464
# en_sharepoint_server_2013_with_sp1_x64_dvd_3823428.iso

# SQL Server Enterprise 2016 + SP1 https://my.visualstudio.com/Downloads?pid=2166
# en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso
# SQL Server Enterprise 2012 + SP3 https://my.visualstudio.com/Downloads?pid=1943
# en_sql_server_2012_enterprise_edition_with_service_pack_3_x86_dvd_7286838.iso

# Visual Studio Enterprise 2015 + Update 3 https://my.visualstudio.com/Downloads?pid=2087
# en_visual_studio_enterprise_2015_with_update_3_x86_x64_web_installer_8922986.exe

# Windows Server 2016 https://my.visualstudio.com/Downloads?pid=2133
# en_windows_server_2016_x64_dvd_9327751.iso