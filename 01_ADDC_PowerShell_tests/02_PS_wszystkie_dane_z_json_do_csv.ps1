########################################################################################################################################
#
# skrypt do konwersji danych z pliku roboczego JSON do pliku CSV
# skrypt czesciowo bazuje na zmiennych pobieranych z pliku konfiguracyjnego
#
########################################################################################################################################

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
$timestampZero = $configFileValues.timestampZero
$nc = $configFileValues.nc
$dateFormat = $configFileValues.dateFormat
$varTrue = $configFileValues.varTrue
$varFalse = $configFileValues.varFalse
$csvReportFileName = $configFileValues.csvReportFileName
$reportFilesPath = $configFileValues.reportFilesPath

# plik bazy danych json
$jsonBaseWorkFileName = $jsonBaseFileName + $systemName
$jsonBaseWorkFileName = "$jsonBaseWorkFileName.json"
$jsonBaseWorkFilePath = $workFilesPath + $jsonBaseWorkFileName
$dataFromjsonBaseWorkFile = Get-Content $jsonBaseWorkFilePath -Raw | ConvertFrom-Json

# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.systemName
$usersCountFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.usersCount
$allUsersFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.users

# plik raportu csv
$csvReportFileName = $csvReportFileName + "main_report_" + $systemName # tu nadajemy pełną nazwę dla pliku raportu
$csvReportFileName = "$csvReportFileName.csv"
$csvReportFileNamePath = $reportFilesPath + $csvReportFileName

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

function dateFormated($timestampToFormat){
    if($timestampToFormat -eq $nc){
        $dateFormated = $nc
    }else{
        $dateFormated = [DateTime]::FromFileTimeUtc($timestampToFormat).ToString("$dateFormat")
    }
    $dateFormat = $null
    $nc = $null
    $timestampToFormat = $null
    Return $dateFormated
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

function clock($dateToClock){
    if($dateToClock -eq $nc){
        $clock = $nc
    }else{
    $dateToDays = (New-TimeSpan -Start $dateToClock -End $date).Days
    $dateToHours = (New-TimeSpan -Start $dateToClock -End $date).Hours
    $dateToMinutes = (New-TimeSpan -Start $dateToClock -End $date).Minutes
    $clock = "$dateToDays D` $dateToHours h` $dateToMinutes min"
    }
    $nc = $null
    $dateToDays = $null
    $dateToHours = $null
    $dateToMinutes = $null
    $dateToClock = $null
    $date = $null
Return $clock
}

# PROGRAM
########################################################################################################################################

if(fileValidation($file) -eq $true){
    $csvMainReportFile = New-Item -ItemType file -Force $csvReportFileNamePath
    # naglowki tabeli pliku csv raportu
    "userNumber;displayName;principalName;firstName;surname;accountStatus;whenCreatedTimestamp;whenCreatedDate;whenCreatedClok;whenChangedTimestamp;whenChangedDate;whenChangedClock;lastLogOnTimestamp;lastLogOnDate;lastLogOnClock;badPasswordTimestamp;badPasswordDate;badPasswordClock;pwdLastSetTimestamp;pwdLastSetDate;pwdLastSetClock;accountExpiresTimestamp;accountExpiresDate;accountExpiresClock;userAccountControl;script;accoundDisable;reservedA;homedir_required;lockout;passwd_notreqd;passwd_cant_change;encrypted_text_pwd_allowed;temp_duplicate_account;normal_user;reservedB;interdomain_trust_account;workstation_trust_account;server_trust_account;reservedC;reservedD;dont_expire_password;msn_logon_account;smartcard_required;trusted_for_delegation;reservedE;domain_controller;not_delegated;use_des_key_only;dont_req_preauth;password_expired;trusted_to_auth_for_delegation;partial_secrets_account" | Out-File $csvMainReportFile -Encoding utf8

    foreach ($user in $allUsersFromjsonBaseWorkFile){
        # dane personalne
        $userPersInf = $user.users_pers_inf
        $userNumber = $userPersInf.userNumber
        $displayName = $userPersInf.displayName
        $principalName = $userPersInf.principalName
        $userPersData = $userPersInf.users_pers_data
        $firstName = $userPersData.firstName
        $surname = $userPersData.surname
        # status konta
        $accountStatusInf = $user.account_status_inf
        $accountStatus = $accountStatusInf.accountStatus
        if ($accountStatus -eq $true) {$accountStatus = "DISABLED"}
        if ($accountStatus -eq $false) {$accountStatus = "ACTIVE"}

        # daty aktywnosci na koncie
        $whenCreatedTimestamp = timestamp($accountStatusInf.whenCreatedTimestamp)
        $whenCreatedDate = dateFormated($whenCreatedTimestamp)
        $whenCreatedTime = timestampToDate($whenCreatedTimestamp)
        $whenCreatedClok = clock($whenCreatedTime)
        
        $whenChangedTimestamp = timestamp($accountStatusInf.whenChangedTimestamp)
        $whenChangedDate = dateFormated($whenChangedTimestamp)
        $whenChangedTime = timestampToDate($whenChangedTimestamp)
        $whenChangedClock = clock($whenChangedTime)
        
        $lastLogOnTimestamp = timestamp($accountStatusInf.lastLogOnTimestamp)
        $lastLogOnDate = dateFormated($lastLogOnTimestamp)
        $lastLogOnTime = timestampToDate($lastLogOnTimestamp)
        $lastLogOnClock = clock($lastLogOnTime)

        $badPasswordTimestamp = timestamp($accountStatusInf.badPasswordTimestamp)
        $badPasswordDate = dateFormated($badPasswordTimestamp)
        $badPasswordTime = timestampToDate($badPasswordTimestamp)
        $badPasswordClock = clock($badPasswordTime)
        
        $pwdLastSetTimestamp = timestamp($accountStatusInf.pwdLastSetTimestamp)
        $pwdLastSetDate = dateFormated($pwdLastSetTimestamp)
        $pwdLastSetTime = timestampToDate($pwdLastSetTimestamp)
        $pwdLastSetClock = clock($pwdLastSetTime)

        $accountExpiresTimestamp = timestamp($accountStatusInf.accountExpiresTimestamp)
        $accountExpiresDate = dateFormated($accountExpiresTimestamp)
        $accountExpiresTime = timestampToDate($accountExpiresTimestamp)
        $accountExpiresClock = clock($accountExpiresTime)

        # atrybuty konta
        $userAccountControlInf = $user.account_control_flags_status
        $userAccountControl = $userAccountControlInf.accountControlFlagsStatus
        $script = $userAccountControlInf.script_0x0001
        $accoundDisable = $userAccountControlInf.accoundDisable_0x0002
        $reservedA = $userAccountControlInf.reservedA_0x0004
        $homedir_required = $userAccountControlInf.homedir_required_0x0008
        $lockout = $userAccountControlInf.lockout_0x0010
        $passwd_notreqd = $userAccountControlInf.passwd_notreqd_0x0020
        $passwd_cant_change = $userAccountControlInf.passwd_cant_change_0x0040
        $encrypted_text_pwd_allowed = $userAccountControlInf.encrypted_text_pwd_allowed_0x0080
        $temp_duplicate_account = $userAccountControlInf.temp_duplicate_account_0x0100
        $normal_user = $userAccountControlInf.normal_user_0x0200
        $reservedB = $userAccountControlInf.reservedB_0x0400 # do odszukania co to
        $interdomain_trust_account = $userAccountControlInf.interdomain_trust_account_0x0800
        $workstation_trust_account = $userAccountControlInf.workstation_trust_account_0x1000
        $server_trust_account = $userAccountControlInf.server_trust_account_0x2000
        $reservedC = $userAccountControlInf.reservedC_0x4000 # do odszukania co to
        $reservedD = $userAccountControlInf.reservedD_0x8000 # do odszukania co to
        $dont_expire_password = $userAccountControlInf.dont_expire_password_0x10000
        $msn_logon_account = $userAccountControlInf.msn_logon_account_0x20000
        $smartcard_required = $userAccountControlInf.smartcard_required_0x40000
        $trusted_for_delegation = $userAccountControlInf.trusted_for_delegation_0x80000
        $reservedE = $userAccountControlInf.reservedE_0x81000 # do odszukania co to
        $domain_controller = $userAccountControlInf.domain_controller_0x82000
        $not_delegated = $userAccountControlInf.not_delegated_0x100000
        $use_des_key_only = $userAccountControlInf.use_des_key_only_0x200000
        $dont_req_preauth = $userAccountControlInf.dont_req_preauth_0x400000
        $password_expired = $userAccountControlInf.password_expired_0x800000
        $trusted_to_auth_for_delegation = $userAccountControlInf.trusted_to_auth_for_delegation_0x1000000
        $partial_secrets_account = $userAccountControlInf.partial_secrets_account_0x4000000

        if ($script -eq $true) {$script = $varTrue} elseif ($script -eq $false) {$script = $varFalse}
        if ($accoundDisable -eq $true) {$accoundDisable = $varTrue} elseif ($accoundDisable -eq $false) {$accoundDisable = $varFalse}
        if ($reservedA -eq $true) {$reservedA = $varTrue} elseif ($reservedA -eq $false) {$reservedA = $varFalse}
        if ($homedir_required -eq $true) {$homedir_required = $varTrue} elseif ($homedir_required -eq $false) {$homedir_required = $varFalse}
        if ($lockout -eq $true) {$lockout = $varTrue} elseif ($lockout -eq $false) {$lockout = $varFalse}
        if ($passwd_notreqd -eq $true) {$passwd_notreqd = $varTrue} elseif ($passwd_notreqd -eq $false) {$passwd_notreqd = $varFalse}
        if ($passwd_cant_change -eq $true) {$passwd_cant_change = $varTrue} elseif ($passwd_cant_change -eq $false) {$passwd_cant_change = $varFalse}
        if ($encrypted_text_pwd_allowed -eq $true) {$encrypted_text_pwd_allowed = $varTrue} elseif ($encrypted_text_pwd_allowed -eq $false) {$encrypted_text_pwd_allowed = $varFalse}
        if ($temp_duplicate_account -eq $true) {$temp_duplicate_account = $varTrue} elseif ($temp_duplicate_account -eq $false) {$temp_duplicate_account = $varFalse}
        if ($normal_user -eq $true) {$normal_user = $varTrue} elseif ($normal_user -eq $false) {$normal_user = $varFalse}
        if ($reservedB -eq $true) {$reservedB = $varTrue} elseif ($reservedB -eq $false) {$reservedB = $varFalse}
        if ($interdomain_trust_account -eq $true) {$interdomain_trust_account = $varTrue} elseif ($interdomain_trust_account -eq $false) {$interdomain_trust_account = $varFalse}
        if ($workstation_trust_account -eq $true) {$workstation_trust_account = $varTrue} elseif ($workstation_trust_account -eq $false) {$workstation_trust_account = $varFalse}
        if ($server_trust_account -eq $true) {$server_trust_account = $varTrue} elseif ($server_trust_account -eq $false) {$server_trust_account = $varFalse}
        if ($reservedC -eq $true) {$reservedC = $varTrue} elseif ($reservedC -eq $false) {$reservedC = $varFalse}
        if ($reservedD -eq $true) {$reservedD = $varTrue} elseif ($reservedD -eq $false) {$reservedD = $varFalse}
        if ($dont_expire_password -eq $true) {$dont_expire_password = $varTrue} elseif ($dont_expire_password -eq $false) {$dont_expire_password = $varFalse}
        if ($msn_logon_account -eq $true) {$msn_logon_account = $varTrue} elseif ($msn_logon_account -eq $false) {$msn_logon_account = $varFalse}
        if ($smartcard_required -eq $true) {$smartcard_required = $varTrue} elseif ($smartcard_required -eq $false) {$smartcard_required = $varFalse}
        if ($trusted_for_delegation -eq $true) {$trusted_for_delegation = $varTrue} elseif ($trusted_for_delegation -eq $false) {$trusted_for_delegation = $varFalse}
        if ($reservedE -eq $true) {$reservedE = $varTrue} elseif ($reservedE -eq $false) {$reservedE = $varFalse}
        if ($domain_controller -eq $true) {$domain_controller = $varTrue} elseif ($domain_controller -eq $false) {$domain_controller = $varFalse}
        if ($not_delegated -eq $true) {$not_delegated = $varTrue} elseif ($not_delegated -eq $false) {$not_delegated = $varFalse}
        if ($use_des_key_only -eq $true) {$use_des_key_only = $varTrue} elseif ($use_des_key_only -eq $false) {$use_des_key_only = $varFalse}
        if ($dont_req_preauth -eq $true) {$dont_req_preauth = $varTrue} elseif ($dont_req_preauth -eq $false) {$dont_req_preauth = $varFalse}
        if ($password_expired -eq $true) {$password_expired = $varTrue} elseif ($password_expired -eq $false) {$password_expired = $varFalse}
        if ($trusted_to_auth_for_delegation -eq $true) {$trusted_to_auth_for_delegation = $varTrue} elseif ($trusted_to_auth_for_delegation -eq $false) {$trusted_to_auth_for_delegation = $varFalse}
        if ($partial_secrets_account -eq $true) {$partial_secrets_account = $varTrue} elseif ($partial_secrets_account -eq $false) {$partial_secrets_account = $varFalse}
        
        "$userNumber;$displayName;$principalName;$firstName;$surname;$accountStatus;$whenCreatedTimestamp;$whenCreatedDate;$whenCreatedClok;$whenChangedTimestamp;$whenChangedDate;$whenChangedClock;$lastLogOnTimestamp;$lastLogOnDate;$lastLogOnClock;$badPasswordTimestamp;$badPasswordDate;$badPasswordClock;$pwdLastSetTimestamp;$pwdLastSetDate;$pwdLastSetClock;$accountExpiresTimestamp;$accountExpiresDate;$accountExpiresClock;$userAccountControl;$script;$accoundDisable;$reservedA;$homedir_required;$lockout;$passwd_notreqd;$passwd_cant_change;$encrypted_text_pwd_allowed;$temp_duplicate_account;$normal_user;$reservedB;$interdomain_trust_account;$workstation_trust_account;$server_trust_account;$reservedC;$reservedD;$dont_expire_password;$msn_logon_account;$smartcard_required;$trusted_for_delegation;$reservedE;$domain_controller;$not_delegated;$use_des_key_only;$dont_req_preauth;$password_expired;$trusted_to_auth_for_delegation;$partial_secrets_account" |Out-File $csvMainReportFile -Encoding utf8 -Append
        
        $i++
    } # end foreach ($user in $allUsers)
    Write-Host "`tSUCCESS`t`tERFOLG`t`tSUKCES`t`tSUCCESS`t`tERFOLG`t`tSUKCES`t`tSUCCESS`t`tERFOLG`t`tSUKCES`t" -BackgroundColor DarkGreen
    Write-Host "Plik " -NoNewline
    Write-Host "$csvReportFileName" -ForegroundColor Yellow -NoNewline
    Write-Host " gotowy."
    Write-Host "____________________________________________________________________________________________________________"

    $i = $null

    $userPersInf = $null
    $userPersData = $null
    $userNumber = $null
    $firstName = $null
    $surname = $null
    $displayName = $null
    $principalName = $null
    $accountStatusInf = $null
    $accountStatus = $null

    $whenCreatedTimestamp = $null
    $whenChangedTimestamp = $null
    $lastLogOnTimestamp = $null
    $badPasswordTimestamp = $null
    $pwdLastSetTimestamp = $null
    $accountExpiresTimestamp = $null

    $whenCreatedDate = $null
    $whenChangedDate = $null
    $lastLogOnDate = $null
    $badPasswordDate = $null
    $pwdLastSetDate = $null
    $accountExpiresDate = $null

    $whenCreatedTime = $null
    $whenChangedTime = $null
    $lastLogOnTime = $null
    $badPasswordTime = $null
    $pwdLastSetTime = $null
    $accountExpiresTime = $null

    $whenCreatedClok = $null
    $whenChangedClok = $null
    $lastLogOnClock = $null
    $badPasswordClock = $null
    $pwdLastSetClock = $null
    $accountExpiresClock = $null

    $userAccountControl = $null
    $script = $null
    $accoundDisable = $null
    $reservedA = $null
    $homedir_required = $null
    $lockout = $null
    $passwd_notreqd = $null
    $passwd_cant_change = $null
    $encrypted_text_pwd_allowed = $null
    $temp_duplicate_account = $null
    $normal_user = $null
    $reservedB = $null
    $interdomain_trust_account = $null
    $workstation_trust_account = $null
    $server_trust_account = $null
    $reservedC = $null
    $reservedD = $null
    $dont_expire_password = $null
    $msn_logon_account = $null
    $smartcard_required = $null
    $trusted_for_delegation = $null
    $reservedE = $null
    $domain_controller = $null
    $not_delegated = $null
    $use_des_key_only = $null
    $dont_req_preauth = $null
    $password_expired = $null
    $trusted_to_auth_for_delegation = $null
    $partial_secrets_account = $null

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
$timestampZero = $null
$nc = $null
$dateFormat = $null
$varTrue = $null
$varFalse = $null
$csvReportFileName = $null
$reportFilesPath = $null

# plik bazy danych json
$jsonBaseWorkFileName = $null
$jsonBaseWorkFilePath = $null
$dataFromjsonBaseWorkFile = $null

# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $null
$usersCountFromjsonBaseWorkFile = $null
$allUsersFromjsonBaseWorkFile = $null

# plik raportu csv
$csvReportFileName = $null
$csvReportFileNamePath = $null
$csvMainReportFile = $null

# FUNCTIONS
$correctFile = $null
$timestamp = $null
$dateFormated = $null
$dateFromTimestamp = $null
$clock = $null




# PROGRAM





$file = $null
$user = $null