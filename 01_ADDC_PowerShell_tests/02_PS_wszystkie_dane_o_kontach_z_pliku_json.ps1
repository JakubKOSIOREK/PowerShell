########################################################################################################################################
#
# skrypt pobiera dane na temat uzytkownikow bazy ldap z pliku roboczego JSON i wyswietla informacje na konsoli w postaci graficznej
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

# plik bazy danych json
$jsonBaseWorkFileName = $jsonBaseFileName + $systemName
$jsonBaseWorkFileName = "$jsonBaseWorkFileName.json"
$jsonBaseWorkFilePath = $workFilesPath + $jsonBaseWorkFileName
$dataFromjsonBaseWorkFile = Get-Content $jsonBaseWorkFilePath -Raw | ConvertFrom-Json

# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.systemName
$usersCountFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.usersCount
$allUsersFromjsonBaseWorkFile = $dataFromjsonBaseWorkFile.users

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
    Write-Host "*************************************************************************************************************"
    Write-Host "LISTA KONT DOMENY " -ForegroundColor Gray -NoNewline
    Write-Host "$systemNameFromjsonBaseWorkFile" -ForegroundColor Yellow -NoNewline
    Write-Host "`t liczba kont:  " -ForegroundColor Gray -NoNewline
    Write-Host "$usersCountFromjsonBaseWorkFile" -ForegroundColor Yellow
    Write-Host "*************************************************************************************************************"
    Write-Host "____________________________________________________________________________________________________________"
    
    foreach ($user in $allUsersFromjsonBaseWorkFile){
        Write-Progress -Activity "Users in domain" -Status "Check completed $i of $usersCountFromjsonBaseWorkFile" -PercentComplete (($i/$usersCountFromjsonBaseWorkFile)*100) # pasek postepu
        # dane personalne
        $userPersInf = $user.users_pers_inf
        $userPersData = $userPersInf.users_pers_data
        $userNumber = $userPersInf.userNumber
        $firstName = $userPersData.firstName
        $surname = $userPersData.surname
        $displayName = $userPersInf.displayName
        $principalName = $userPersInf.principalName
        # status konta
        $accountStatusInf = $user.account_status_inf
        $accountStatus = $accountStatusInf.accountStatus
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

        # daty aktywnosci na koncie
        $whenCreatedTimestamp = timestamp($accountStatusInf.whenCreatedTimestamp)
        $whenChangedTimestamp = timestamp($accountStatusInf.whenChangedTimestamp)
        $lastLogOnTimestamp = timestamp($accountStatusInf.lastLogOnTimestamp)
        $badPasswordTimestamp = timestamp($accountStatusInf.badPasswordTimestamp)
        $pwdLastSetTimestamp = timestamp($accountStatusInf.pwdLastSetTimestamp)
        $accountExpiresTimestamp = timestamp($accountStatusInf.accountExpiresTimestamp)

        $whenCreatedDate = dateFormated($whenCreatedTimestamp)
        $whenChangedDate = dateFormated($whenChangedTimestamp)
        $lastLogOnDate = dateFormated($lastLogOnTimestamp)
        $badPasswordDate = dateFormated($badPasswordTimestamp)
        $pwdLastSetDate = dateFormated($pwdLastSetTimestamp)
        $accountExpiresDate = dateFormated($accountExpiresTimestamp)

        $whenCreatedTime = timestampToDate($whenCreatedTimestamp)
        $whenChangedTime = timestampToDate($whenChangedTimestamp)
        $lastLogOnTime = timestampToDate($lastLogOnTimestamp)
        $badPasswordTime = timestampToDate($badPasswordTimestamp)
        $pwdLastSetTime = timestampToDate($pwdLastSetTimestamp)
        $accountExpiresTime = timestampToDate($accountExpiresTimestamp)

        $whenCreatedClok = clock($whenCreatedTime)
        $whenChangedClock = clock($whenChangedTime)
        $lastLogOnClock = clock($lastLogOnTime)
        $badPasswordClock = clock($badPasswordTime)
        $pwdLastSetClock = clock($pwdLastSetTime)
        $accountExpiresClock = clock($accountExpiresTime)

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
        Write-Host "First name:`t`t`t`t`t`t" -NoNewline
        Write-Host "[ " -NoNewline
        Write-Host "$firstName" -NoNewline -ForegroundColor DarkCyan
        Write-Host " ]"
        Write-Host "Surname:`t`t`t`t`t`t" -NoNewline
        Write-Host "[ " -NoNewline
        Write-Host "$surname" -NoNewline -ForegroundColor DarkCyan
        Write-Host " ]"

        Write-Host "Account status:`t`t`t`t`t" -NoNewline
        Write-Host "[ " -NoNewline
        if ($accountStatus -eq $true) {Write-Host "DISABLED" -NoNewline -ForegroundColor Red}
        if ($accountStatus -eq $false) {Write-Host "ACTIVE" -NoNewline -ForegroundColor Green}
        Write-Host " ]"
        
        Write-Host ""
        Write-Host "`t`t`t`t`t`t`t`t`t`t`tDATE`t`t`t`t`tTIMESTAMP`t`t`t`tCLOCK"

        Write-Host "Account created date:`t`t`t" -NoNewline
        Write-Host "| " -NoNewline
        Write-Host "$whenCreatedDate" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |`t| " -NoNewline
        Write-Host "$whenCreatedTimestamp" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |`t| " -NoNewline
        Write-Host "$whenCreatedClok" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |"

        Write-Host "Account last change date:`t`t" -NoNewline
        Write-Host "| " -NoNewline
        Write-Host "$whenChangedDate" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |`t| " -NoNewline
        Write-Host "$whenChangedTimestamp" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |`t| " -NoNewline
        Write-Host "$whenChangedClock" -NoNewline -ForegroundColor DarkCyan
        Write-Host " |"

        if($lastLogOnTimestamp -eq $nc){Write-Host "`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t" -BackgroundColor DarkRed}
        Write-Host "User last logon date:`t`t`t" -NoNewline
        Write-Host "| " -NoNewline
        if($lastLogOnDate -eq $nc){Write-Host "  $nc  " -NoNewline -ForegroundColor Gray}else{Write-Host "$lastLogOnDate" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($lastLogOnTimestamp -eq $nc){Write-Host "$nc " -NoNewline -ForegroundColor Gray}else{Write-Host "$lastLogOnTimestamp" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($lastLogOnClock -eq $nc){Write-Host "$nc" -NoNewline -ForegroundColor Gray}else{Write-Host "$lastLogOnClock" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |"

        if($badPasswordTimestamp -eq $nc){Write-Host "`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t" -BackgroundColor DarkRed}
        Write-Host "User last bad password date:`t" -NoNewline
        Write-Host "| " -NoNewline
        if($badPasswordDate -eq $nc){Write-Host "  $nc  " -NoNewline -ForegroundColor Gray}else{Write-Host "$badPasswordDate" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($badPasswordTimestamp -eq $nc){Write-Host "$nc " -NoNewline -ForegroundColor Gray}else{Write-Host "$badPasswordTimestamp" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($badPasswordClock -eq $nc){Write-Host "$nc" -NoNewline -ForegroundColor Gray}else{Write-Host "$badPasswordClock" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |"

        if($pwdLastSetTimestamp -eq $nc){Write-Host "`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t`tWARNING`t`tACHTUNG`t`tUWAGA`t" -BackgroundColor DarkRed}
        Write-Host "User password last set date:`t" -NoNewline
        Write-Host "| " -NoNewline
        if($pwdLastSetDate -eq $nc){Write-Host "  $nc  " -NoNewline -ForegroundColor Gray}else{Write-Host "$pwdLastSetDate" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($pwdLastSetTimestamp -eq $nc){Write-Host "$nc " -NoNewline -ForegroundColor Gray}else{Write-Host "$pwdLastSetTimestamp" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($pwdLastSetClock -eq $nc){Write-Host "$nc" -NoNewline -ForegroundColor Gray}else{Write-Host "$pwdLastSetClock" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |"

        Write-Host "Account expiration date:`t`t" -NoNewline
        Write-Host "| " -NoNewline
        if($accountExpiresDate -eq $nc){Write-Host "  $nc  " -NoNewline -ForegroundColor Gray}else{Write-Host "$accountExpiresDate" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($accountExpiresTimestamp -eq $nc){Write-Host "$nc " -NoNewline -ForegroundColor Gray}else{Write-Host "$pwdLastSetTimestamp" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |`t| " -NoNewline
        if($accountExpiresClock -eq $nc){Write-Host "$nc" -NoNewline -ForegroundColor Gray}else{Write-Host "$accountExpiresClock" -NoNewLine -ForegroundColor DarkCyan}
        Write-Host " |"

        Write-Host "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        Write-Host "User account control flags status:`t" -NoNewline
        Write-Host "| " -NoNewline
        Write-Host "$userAccountControl" -NoNewline -ForegroundColor Gray
        Write-Host " |"
        Write-Host ""

        Write-Host " | " -NoNewline
        if ($script -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($script -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0001`t`t| 1`t`t`t| SCRIPT"
        
        Write-Host " | " -NoNewline
        if ($accoundDisable -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($accoundDisable -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0002`t`t| 2`t`t`t| ACCOUNT_DISABLE"

        Write-Host " | " -NoNewline
        if ($reservedA -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($reservedA -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0004`t`t| 4`t`t`t| RESERVED"

        Write-Host " | " -NoNewline
        if ($homedir_required -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($homedir_required -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0008`t`t| 8`t`t`t| HOMEDIR_REQUIRED"

        Write-Host " | " -NoNewline
        if ($lockout -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($lockout -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0010`t`t| 16`t`t| LOCKOUT"

        Write-Host " | " -NoNewline
        if ($passwd_notreqd -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($passwd_notreqd -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0020`t`t| 32`t`t| PASSWD_NOTREQD"

        Write-Host " | " -NoNewline
        if ($passwd_cant_change -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($passwd_cant_change -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0040`t`t| 64`t`t| PASSWD_CANT_CHANGE"


        Write-Host " | " -NoNewline
        if ($encrypted_text_pwd_allowed -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($encrypted_text_pwd_allowed -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0080`t`t| 128`t`t| ENCRYPTED_TEXT_PWD_ALLOWED"

        Write-Host " | " -NoNewline
        if ($temp_duplicate_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($temp_duplicate_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0100`t`t| 256`t`t| TEMP_DUPLICATE_ACCOUNT"

        Write-Host " | " -NoNewline
        if ($normal_user -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($normal_user -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0200`t`t| 512`t`t| NORMAL_ACCOUNT"

        Write-Host " | " -NoNewline
        if ($reservedB -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($reservedB -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0400`t`t| 1024`t`t| RESERVED"

        $interdomain_trust_account = $userAccountControlInf.interdomain_trust_account_0x0800
        Write-Host " | " -NoNewline
        if ($interdomain_trust_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($interdomain_trust_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x0800`t`t| 2048`t`t| INTERDOMAIN_TRUST_ACCOUNT"

        $workstation_trust_account = $userAccountControlInf.workstation_trust_account_0x1000
        Write-Host " | " -NoNewline
        if ($workstation_trust_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($workstation_trust_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x1000`t`t| 4096`t`t| WORKSTATION_TRUST_ACCOUNT"

        $server_trust_account = $userAccountControlInf.server_trust_account_0x2000
        Write-Host " | " -NoNewline
        if ($server_trust_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($server_trust_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x2000`t`t| 8192`t`t| SERVER_TRUST_ACCOUNT"

        Write-Host " | " -NoNewline
        if ($reservedC -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($reservedC -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x04000`t| 16384`t`t| RESERVED"

        Write-Host " | " -NoNewline
        if ($reservedD -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($reservedD -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x08000`t| 32768`t`t| RESERVED"

        Write-Host " | " -NoNewline
        if ($dont_expire_password -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($dont_expire_password -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x10000`t| 65536`t`t| DONT_EXPIRE_PASSWORD"

        Write-Host " | " -NoNewline
        if ($msn_logon_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($msn_logon_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x20000`t| 131072`t| MNS_LOGON_ACCOUNT"

        Write-Host " | " -NoNewline
        if ($smartcard_required -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($smartcard_required -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x40000`t| 262144`t| SMARTCARD_REQUIRED"

        Write-Host " | " -NoNewline
        if ($trusted_for_delegation -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($trusted_for_delegation -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x80000`t| 524288`t| TRUSTED_FOR_DELEGATION"

        Write-Host " | " -NoNewline
        if ($reservedE -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($reservedE -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x81000`t| 528384`t| RESERVED"

        Write-Host " | " -NoNewline
        if ($domain_controller -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($domain_controller -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x82000`t| 532480`t| DOMAIN_CONTROLLER"

        Write-Host " | " -NoNewline
        if ($not_delegated -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($not_delegated -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x100000`t| 1048576`t| NOT_DELEGATED"

        Write-Host " | " -NoNewline
        if ($use_des_key_only -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($use_des_key_only -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x200000`t| 2097152`t| USE_DES_KEY_ONLY"

        Write-Host " | " -NoNewline
        if ($dont_req_preauth -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($dont_req_preauth -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x400000`t| 4194304`t| DONT_REQ_PREAUTH"

        Write-Host " | " -NoNewline
        if ($password_expired -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($password_expired -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x800000`t| 83388608`t| PASSWORD_EXPIRED"

        Write-Host " | " -NoNewline
        if ($trusted_to_auth_for_delegation -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($trusted_to_auth_for_delegation -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x1000000`t| 16777216`t| TRUSTED_TO_AUTH_FOR_DELEGATION"

        Write-Host " | " -NoNewline
        if ($partial_secrets_account -eq $true) {Write-Host "$varTrue" -NoNewline -ForegroundColor Green}
        if ($partial_secrets_account -eq $false) {Write-Host "$varFalse" -NoNewline -ForegroundColor Red}
        Write-Host " | - 0x4000000`t| 67108864`t| PARTIAL_SECRETS_ACCOUNT"
        
        $i++
        Write-Host "____________________________________________________________________________________________________________"
    } # end foreach ($user in $allUsers)
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
# plik bazy danych json
$jsonBaseWorkFileName = $null
$jsonBaseWorkFileName = $null
$jsonBaseWorkFilePath = $null
$dataFromjsonBaseWorkFile = $null
# zmienne z pliku json
$systemNameFromjsonBaseWorkFile = $null
$usersCountFromjsonBaseWorkFile = $null
$allUsersFromjsonBaseWorkFile = $null
# FUNCTIONS
$correctFile = $null
$timestamp = $null
$dateFormated = $null
$dateFromTimestamp = $null
$clock = $null
# PROGRAM
$file = $null
$user = $null