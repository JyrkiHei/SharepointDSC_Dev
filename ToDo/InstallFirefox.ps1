Configuration Sample_InstallFirefoxBrowser
{
    param
    (

    [Parameter(Mandatory)]
    $VersionNumber,

    [Parameter(Mandatory)]
    $Language,

    [Parameter(Mandatory)]
    $OS,

    [Parameter(Mandatory)]
    $LocalPath      

    )

    Import-DscResource -module xFirefox

    MSFT_xFirefox Firefox
    {
    VersionNumber = $VersionNumber
    Language = $Language
    OS = $OS
    LocalPath = $LocalPath
    }
}