# visual studio code
if( !(get-command -ea 0 code) ) {
    write-host -fore cyan "Info: Downloading Visual Studio Code"
    (New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?LinkID=623230", "c:\tmp\vs_code.exe" )
    if( !(test-path -ea 0 "c:\tmp\vs_code.exe" ) ) { return write-error "Unable to download VS code" }
    write-host -fore darkcyan "      Installing VS Code"
    C:\tmp\vs_code.exe /silent /norestart
    while( get-process vs_*  ) { write-host -NoNewline "." ; sleep 1 }
    ReloadPathFromRegistry
    if( !(get-command -ea 0 code) ) { return write-error "No VS Code in PATH." }
}

# 7zip
if( ! (test-path -ea 0  "C:\Program Files\7-Zip\7z.exe")) {
    write-host -fore cyan "Info: Downloading 7zip."
    ( New-Object System.Net.WebClient).DownloadFile("http://www.7-zip.org/a/7z1604-x64.msi", "c:\tmp\7z1604-x64.msi" );
    if( !(test-path -ea 0  "c:\tmp\7z1604-x64.msi") ) { return write-error "Unable to download 7zip installer" }
    write-host -fore darkcyan "      Installing 7Zip."
    Start-Process -wait -FilePath msiexec -ArgumentList  "/i", "c:\tmp\7z1604-x64.msi", "/passive"

    if( ! (test-path -ea 0  "C:\Program Files\7-Zip\7z.exe"))  { return write-error "Unable to install 7zip" } 
}


$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$settingspath = $directorypath + '\settings.xml'