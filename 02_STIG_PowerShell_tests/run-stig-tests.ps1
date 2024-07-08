Write-Host "START" -ForegroundColor Cyan

# Inicjalizacja zmiennych do zliczania
$allTestsCount = 0
$passedTestsCount = 0
$failedTestsCount = 0

# Pobierz listę wszystkich skryptów PowerShell w katalogu \stig-tests
$scripts = Get-ChildItem -Path ".\stig-tests" -Filter *.ps1

# Uruchomienie każdego skryptu
foreach ($script in $scripts) {
    $allTestsCount++  # Zwiększ liczbę wszystkich testów
    $result = & ".\stig-tests\$($script.Name)"

    # Rozdzielenie wyników na poszczególne części
    $parts = $result.Split(';')
    $status = $parts[0]
    $stigID = $parts[1]
    $testName = $parts[2]
    $message = $parts[3]

    # Logika testów i zliczanie
    if ($status -eq "Passed") {
        $passedTestsCount++  # Zwiększ liczbę zaliczonych testów
        $message = "none"
        Write-Host -NoNewline "$status" -ForegroundColor Green
        Write-Host " | $stigID | $testName | $message" -ForegroundColor DarkGray
    } else {
        $failedTestsCount++  # Zwiększ liczbę niezaliczonych testów
        Write-Host -NoNewline "$status" -ForegroundColor Red
        Write-Host " | $stigID | $testName | $message"
    }
}

# Wyświetlanie podsumowania
Write-Host -NoNewline "Tests executed: "
Write-Host -NoNewline "$allTests" -ForegroundColor Cyan
Write-Host " | Passed: $passedTests | Failed: $failedTests"
