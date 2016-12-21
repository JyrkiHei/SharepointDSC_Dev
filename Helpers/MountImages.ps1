function Mount-ISO($imagePath, $newLetter)
{
    $ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter

    IF (!$ISODrive) {
        Mount-DiskImage -ImagePath $ImagePath
    }

    $ISODrive = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter
    #Write-Host ("ISO Drive is " + $ISODrive)

    if($ISODrive)
    {
        $drive = Get-WmiObject -Class win32_volume -Filter “DriveLetter = '${ISODrive}:'”
        Set-WmiInstance -input $drive -Arguments @{DriveLetter="$newLetter";}
    }
}

Mount-ISO "C:\DSC\Software\en_windows_server_2016_x64_dvd_9327751.iso" "O:"
Mount-ISO "C:\DSC\Software\en_sql_server_2016_enterprise_with_service_pack_1_x64_dvd_9542382.iso" "P:"
Mount-ISO "C:\DSC\Software\en_sharepoint_server_2016_x64_dvd_8419458.iso" "Q:"

