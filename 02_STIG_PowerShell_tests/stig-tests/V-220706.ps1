$stigID = "V-220706"
$test_name = "Windows 10 systems must be maintained at a supported servicing level."

# Definicje obsługiwanych wersji dla Semi-Annual Channel i Long-Term Servicing Channel (LTSC)
$semiAnnualSupportedVersions = @(
    [Version]"10.0.18363.0",  # v1909
    [Version]"10.0.19041.0",  # v2004
    [Version]"10.0.19042.0"   # v20H2
)

$ltscSupportedVersions = @{
    "1507" = [Version]"10.0.10240.0";
    "1607" = [Version]"10.0.14393.0";
    "1809" = [Version]"10.0.17763.0"
}

# Pobieranie informacji o systemie
$osInfo = Get-ComputerInfo -Property "WindowsProductName", "WindowsVersion", "OsHardwareAbstractionLayer"

# Pobieranie aktualnej wersji systemu
$currentBuild = [Version]"$($osInfo.WindowsVersion).$($osInfo.OsHardwareAbstractionLayer.split('.')[-1])"

# Określenie czy system jest na LTSC
$isLTSC = $osInfo.WindowsProductName -like "*LTSC*" -or $osInfo.WindowsProductName -like "*LTSB*"

# Logika testu
if ($isLTSC) {
    $supported = $ltscSupportedVersions.Values -contains $currentBuild
} else {
    $supported = $semiAnnualSupportedVersions -contains $currentBuild
}

# Wyniki
if ($supported) {
    $status = "Passed"
    $message = "none"
} else {
    $status = "Failed"
    $message = "System is NOT at a supported servicing level. Update is required."
}

# Wydrukuj wynik w formacie status;id;nazwa;message
"$status;$stigID;$test_name;$message"
