New-Item -ItemType directory -Path C:\Temp\
(New-Object Net.WebClient).DownloadFile('https://github.com/JyrkiHei/SharepointDSC_Dev/archive/master.zip','C:\temp\dscmaster.zip');
(new-object -com shell.application).namespace('C:\temp').CopyHere((new-object -com shell.application).namespace('C:\temp\dscmaster.zip').Items(),16)
Rename-Item -Path c:\temp\SharepointDSC_Dev-master -NewName dsc
Move-Item -path C:\Temp\dsc -destination C:\
set-location C:\dsc
#.\_start.cmd