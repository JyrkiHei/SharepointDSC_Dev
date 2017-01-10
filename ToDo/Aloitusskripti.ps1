New-Item -ItemType directory -Path C:\dsc\
New-Item -ItemType directory -Path C:\Temp\
(New-Object Net.WebClient).DownloadFile('https://github.com/JyrkiHei/SharepointDSC_Dev/archive/master.zip','C:\dsc\dscmaster.zip');
(new-object -com shell.application).namespace('C:\temp').CopyHere((new-object -com shell.application).namespace('C:\temp\dscmaster.zip').Items(),16)
Move-Item -path C:\Temp\SharepointDSC_Dev-master -destination C:\dsc
set-location C:\dsc
#.\_start.cmd