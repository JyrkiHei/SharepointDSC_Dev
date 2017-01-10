# Stores config-values to $ConfigValues variable

if($ConfigValues -eq $null)
{
    Get-Content ".\config.txt" | foreach-object -begin {$ConfigValues=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $ConfigValues.Add($k[0], $k[1]) } }
}