########################################################################################################################################
#
# skrypt pobiera dane na temat uzytkownikow bazy ldap z pliku roboczego JSON i wyswietla informacje o uzytkownikach ktorzy logowali sie
# wiecej niz < n > dni temu. Zmienna < n > ustawiamy w zaleznosci od potrzeb.
# 
# skrypt czesciowo bazuje na zmiennych pobieranych z pliku konfiguracyjnego
#
########################################################################################################################################

# KRYTERIA WYSZUKIWANIA
########################################################################################################################################
$days = 0 # tu podac ilosc dni powyzej ktorych ma sprawdzac

# VARIABLES
########################################################################################################################################
Clear-Host

# to do ustawienia pod system
$configFilePath = "C:\01_ADDC_PowerShell_tests\" # sciezka do pliku konfiguracyjnego

# zmienne globalne
$date = Get-Date

# plik konfiguracyjny
$configFileName = "addc_tests_config_file.txt" # nazwa pliku konfiguracyjnego
$configFile = $configFilePath + $configFileName

# zmienne z pliku konfiguracyjnego
$configFileValues = Get-Content $configFile | Out-String | ConvertFrom-StringData
$jsonBaseFileName = $configFileValues.jsonBaseFileName
$systemName = $configFileValues.systemName
$workFilesPath = $configFileValues.workFilesPath
$configFilesPath = $configFileValues.configFilesPath
$csvExclusionFileName = $configFileValues.csvExclusionFileName
$nc = $configFileValues.nc

# plik bazy danych json
$jsonBaseWorkFileName = $jsonBaseFileName + $systemName
$jsonBaseWorkFileName = "$jsonBaseWorkFileName.json"
$jsonBaseWorkFilePath = $workFilesPath + $jsonBaseWorkFileName
$dataFromjsonBaseWorkFile = Get-Content $jsonBaseWorkFilePath -Raw | ConvertFrom-Json

# plik csv z baza kont wykluczonych
$csvExclusionFilePath = $configFilesPath + $csvExclusionFileName
$dataFromCsvExclusionFile = Import-Csv $csvExclusionFilePath -Delimiter ";"

# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.systemName
$usersCountFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.usersCount
$allUsersFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.users

# zmienne z pliku csv
$csvPrincipalName = $dataFromCsvExclusionFile.principalName

# FUNCTIONS
########################################################################################################################################

# funkcja sprawdzajaca czy ilosc uzytkownikow w petli zgadza sie z liczba zapisana w pliku
function fileValidation($count){
    $correctFile = $true
    foreach ($jsonUser in $allUsersFromjsonBaseWorkFile){ $i++ }
    $usersCount = $i
    $i = $null
    if ($usersCount -ne $usersCountFromjsonBaseWorkFile) { $correctFile = $false }
    $jsonUser = $null
    $usersCountFromjsonBaseWorkFile = $null
    $usersCount = $null
    $count = $null
    Return $correctFile
}

# funkcja sprawdzająca czy konto nie jest wykluczone (konta techniczne dla usług)
function userValidation ($suspect) {
    $account = $true
    foreach ($user in $CsvPrincipalName) {
        if ($user -eq $suspect) {$account = $false}
    }
    $suspect = $null
    $user = $null
    $CsvPrincipalName = $null
    return $account
}

function timestamp($timestampToCheck){
    if($timestampToCheck -eq $null){
        $timestamp = $nc
    }else{
        $timestamp = $timestampToCheck
    }
    $nc = $null
    $timestampToCheck = $null
    Return $timestamp
}

function timestampToDate($timestampToDate){
    if($timestampToDate -eq $nc){
        $dateFromTimestamp = $nc
    }else{
        $dateFromTimestamp = [DateTime]::FromFileTimeUtc( $timestampToDate )
    }
    $nc = $null
    $timestampToDate = $null
    Return $dateFromTimestamp
}

# PROGRAM
########################################################################################################################################
if(fileValidation($file) -eq $true){
    Write-Host "*************************************************************************************************************"
    Write-Host "KONTA AKTYWNE, ostatnie logowanie w domenie " -ForegroundColor Gray -NoNewline
    Write-Host "$systemNameFromjsonBaseWorkFile" -ForegroundColor Yellow -NoNewline
    Write-Host " ponad " -ForegroundColor Gray -NoNewline
    Write-Host "$days" -ForegroundColor Yellow -NoNewline
    Write-Host " dni temu" -ForegroundColor Gray
    Write-Host "*************************************************************************************************************"
    Write-Host "____________________________________________________________________________________________________________"
    $i = 1
    foreach ($user in $allUsersFromjsonBaseWorkFile){
        
        $userPersInf = $user.users_pers_inf
        $principalName = $userPersInf.principalName
        if (userValidation($principalName) -eq $true) { # to wyklucza konta techniczne
            $accountStatusInf = $user.account_status_inf
            $accountStatus = $accountStatusInf.accountStatus
            if ($accountStatus -eq $false){ # to daje tylko aktywne konta
                $lastLogOnTimestamp = timestamp($accountStatusInf.lastLogOnTimestamp)
                $lastLogOnTime = timestampToDate($lastLogOnTimestamp)
                if ($lastLogOnTime -lt ($date).AddDays(-$days)){ # to daje uzytkownikow ktorzy nie loguja od n dni
                    $userPersData = $userPersInf.users_pers_data
                    $userNumber = $i
                    $firstName = $userPersData.firstName
                    $surname = $userPersData.surname
                    $displayName = $userPersInf.displayName

                    # DISPLAY
                    ########################################################################################################################
                    Write-Host "User no.`t`t`t`t`t`t`[ " -NoNewline
                    Write-Host "$userNumber" -NoNewline -ForegroundColor DarkYellow
                    Write-Host " ]"
                    Write-Host "Display name:`t`t`t`t`t" -NoNewline
                    Write-Host  "[ " -NoNewline  
                    Write-Host "$displayName" -NoNewline -ForegroundColor DarkYellow
                    Write-Host  " ]`t" -NoNewline  
                    Write-Host "principalName:`t" -NoNewline -ForegroundColor DarkCyan
                    Write-Host  "[ " -NoNewline  
                    Write-Host "$principalName" -NoNewline -ForegroundColor DarkYellow
                    Write-Host " ]"
                    Write-Host "Account status:`t`t`t`t`t" -NoNewline
                    Write-Host "[ " -NoNewline
                    if ($accountStatus -eq $true) {Write-Host "DISABLED" -NoNewline -ForegroundColor Red}
                    if ($accountStatus -eq $false) {Write-Host "ACTIVE" -NoNewline -ForegroundColor Green}
                    Write-Host " ]"
                    $i++
                    Write-Host "____________________________________________________________________________________________________________"
                } # end if ($lastLogOnDate -lt ($date).AddDays(-$days))
                
                $userPersData = $null
                $userNumber = $null
                $firstName = $null
                $surname = $null
                $displayName = $null
            } # end if ($accountStatus -eq $false)
            
            $accountStatusInf = $null
            $accountStatus = $null
        } # end if (userValidation($displayName) -eq $true)
        
        $userPersInf = $null
        $principalName = $null
    } # end foreach ($user in $allUsers)
    $i = $null
}else{
    Write-Host "`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t" -BackgroundColor DarkRed
    Write-Host ""
    Write-Host "`t`t`t LICZBA KONT ZAPISANYCH W PLIKU NIE ZAGADA SIE Z LICZBA PO ICH PRZELICZENIU" -ForegroundColor Gray
    Write-Host "`t`t`t`t`t`t PLIK USZKODZONY LUB CELOWO ZMODYFIKOWANY" -ForegroundColor Gray
    Write-Host ""
    Write-Host " sprawdz:" -ForegroundColor Gray
    Write-Host " - czy jest prawidlowo ustawiona sciezka do pliku z danymi" -ForegroundColor Gray
    Write-Host " - czy plik z danymi nie jest uszkodzony (otworzyc w przegladarce)" -ForegroundColor Gray
    Write-Host " - porownaj plik roboczy z ostatnia kopia archiwum czy nie zostal zmodyfikowany" -ForegroundColor Gray
    Write-Host ""
    Write-Host "`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t" -BackgroundColor DarkRed
    $i = $null
} # end if(fileValidation($file) -eq $true)

# CLEANER
########################################################################################################################################

# KRYTERIA WYSZUKIWANIA
$days = $null

# VARIABLES
# to do ustawienia pod system
$configFilePath = $null
# zmienne globalne
$date = $null
# plik konfiguracyjny
$configFileName = $null
$configFile = $null
# zmienne z pliku konfiguracyjnego
$configFileValues = $null
$jsonBaseFileName = $null
$systemName = $null
$workFilesPath = $null
$configFilesPath = $null
$workFilesPath = $null
$csvExclusionFileName = $null
$nc = $null
# plik bazy danych json
$jsonBaseWorkFileName = $null
$jsonBaseWorkFilePath = $null
$dataFromjsonBaseWorkFile = $null
# plik csv z baza kont wykluczonych
$csvExclusionFilePath = $null
$dataFromCsvExclusionFile = $null
# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $null
$usersCountFromjsonBaseWorkFile = $null
$allUsersFromjsonBaseWorkFile = $null
# zmienne z pliku csv
$csvPrincipalName = $null

# FUNCTIONS
$correctFile = $null
$account = $null
$timestamp = $null
$dateFromTimestamp = $null

# PROGRAM
$file = $null
$user = $null