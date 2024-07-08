$stigID = "V-220708"
$test_name = "Local volumes must be formatted using NTFS"

# Pobieranie informacji o woluminach na lokalnym komputerze, które mają przypisaną literę dysku
$volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }

# Lista woluminów, które nie przeszły testu
$failedVolumes = @()

# Sprawdzanie każdego woluminu, czy jest sformatowany jako NTFS
foreach ($volume in $volumes) {
    if ($volume.FileSystem -ne "NTFS" -and $volume.DriveType -eq "Fixed") {
        $failedVolumes += $volume.DriveLetter
    }
}

# Sprawdzamy, czy lista zawodziących woluminów jest pusta
if ($failedVolumes.Count -gt 0) {
    $status = "Failed"
    $failedList = $failedVolumes -join ', '
    $message = "Volumes that are not formatted as NTFS: $failedList"
} else {
    $status = "Passed"
    $message = "none"
}

# Wydrukuj wynik w formacie status;id;nazwa;message
"$status;$stigID;$test_name;$message"
