########################################################################################################################################
#
# skrypt przeszukuje baze danych LDAP i zapisuje dane o kontach do pliku JSON w dwoch wersjach:
# - robocza dla bierzacej obrobki danych przez inne skrypty
# - archiwum w celu budowania historii kont
#
# skrypt czesciowo bazuje na zmiennych pobieranych z pliku konfiguracyjnego
#
########################################################################################################################################

# VARIABLES
########################################################################################################################################
Clear-Host

# to do ustawienia pod system
$configFilePath = "C:\01_ADDC_PowerShell_tests\" # sciezka do pliku konfiguracyjnego

# zmienne globalne
$i = 1
$date = Get-Date

# plik konfiguracyjny
$configFileName = "addc_tests_config_file.txt" # nazwa pliku konfiguracyjnego
$configFile = $configFilePath + $configFileName

# zmienne z pliku konfiguracyjnego
$configFileValues = Get-Content $configFile | Out-String | ConvertFrom-StringData
$jsonBaseFileName = $configFileValues.jsonBaseFileName
$systemName = $configFileValues.systemName
$timestampFormat = $configFileValues.timestampFormat
$workFilesPath = $configFileValues.workFilesPath
$archivesFilesPath = $configFileValues.archivesFilesPath
$addcLdapPath = $configFileValues.addcLdapPath
$timestampZero = $configFileValues.timestampZero



# zmienne przeszukiwanej domeny
$objSearch = New-Object System.DirectoryServices.DirectorySearcher
$objSearch.PageSize = 15000
$objSearch.Filter = "(objectClass=user)"
$objSearch.SearchRoot = $addcLdapPath
$allUsers = $objSearch.FindAll()
$usersCount = $allUsers.Count

# plik bazy danych json
$jsonBaseWorkFileName = $jsonBaseFileName + $systemName
$jsonBaseWorkFileName = "$jsonBaseWorkFileName.json"

# plik archiwum bazy danych json
$jsonArchivesBaseFileName = ($date).ToString($timestampFormat) + "_" + $jsonBaseWorkFileName

# sciezki do zapisu plikow json
$jsonBaseWorkFilePath = $workFilesPath + $jsonBaseWorkFileName
$jsonArchivesFilePath = $archivesFilesPath + $jsonArchivesBaseFileName

# FUNCTIONS
########################################################################################################################################

 # funkcja zwracajaca status konta czy jest aktywne lub wylaczone

 function czyKontoJestAktywne($status){
    $accountStatus = $false
    if(($status -band 2) -eq 0x0002){$accountStatus = $true}
    $status = $null
 Return $accountStatus
 }

function czyJestTimestamp($timestampToCheck){
    if($timestampToCheck -eq 0){
        $timestamp = $null
    }elseif($timestampToCheck -eq $timestampZero){
        $timestamp = $null
    }else{
        $timestamp = $timestampToCheck
    }
    $timestampToCheck = $null
Return $timestamp
}

# PROGRAM
########################################################################################################################################

# tu tworzymy obiekt json
$jsonData = [pscustomobject]@{
    systemName = $systemName
    usersCount = $usersCount
    users = @()
}

foreach ( $user in $allUsers ) {
    Write-Progress -Activity "Users in domain" -Status "Check completed $i of $usersCount" -PercentComplete (($i/$usersCount)*100) # pasek postepu
    $properties = $user.Properties # wejscie do obiektu user w bazie
    
    # dane personalne
    $displayName = $properties.name
    $principalName = $properties.userprincipalname
    $firstName = $properties.givenname
    $surname = $properties.sn
    
    # daty aktywnosci na koncie
    $whenCreated = [String]$properties.whencreated.ToFileTimeUtc()
    $whenChanged = [String]$properties.whenchanged.ToFileTimeUtc()
    $lastLogOn = [String]$properties.lastlogon
    $lastLogOn = [DateTime]::FromFileTimeUtc($lastLogOn)
    $lastLogOn = [String]$lastLogOn.ToFileTimeUtc()
    $badPassword = [String]$properties.badpasswordtime
    $badPassword = [DateTime]::FromFileTimeUtc($badPassword)
    $badPassword = [String]$badPassword.ToFileTimeUtc()
    $pwdLastSet = [String]$properties.pwdlastset
    $pwdLastSet = [DateTime]::FromFileTimeUtc($pwdLastSet)
    $pwdLastSet = [String]$pwdLastSet.ToFileTimeUtc()
    $accountExpires = [String]$properties.accountexpires
    $userAccountControl = [String]$properties.useraccountcontrol

    # atrybuty konta  
    if(($userAccountControl -band 1) -eq 0x0001)           {$script = $true}else{$script = $false}
    if(($userAccountControl -band 2) -eq 0x0002)           {$accoundDisable = $true}else{$accoundDisable = $false}
    if(($userAccountControl -band 4) -eq 0x0004)           {$reservedA = $true}else{$reservedA = $false} # do odszukania co to
    if(($userAccountControl -band 8) -eq 0x0008)           {$homedir_required = $true}else{$homedir_required = $false}
    if(($userAccountControl -band 16) -eq 0x0010)          {$lockout = $true}else{$lockout = $false}
    if(($userAccountControl -band 32) -eq 0x0020)          {$passwd_notreqd = $true}else{$passwd_notreqd = $false}
    if(($userAccountControl -band 64) -eq 0x0040)          {$passwd_cant_change = $true}else{$passwd_cant_change = $false}
    if(($userAccountControl -band 128) -eq 0x0080)         {$encrypted_text_pwd_allowed = $true}else{$encrypted_text_pwd_allowed = $false}
    if(($userAccountControl -band 256) -eq 0x0100)         {$temp_duplicate_account = $true}else{$temp_duplicate_account = $false}
    if(($userAccountControl -band 512) -eq 0x0200)         {$normal_user = $true}else{$normal_user = $false}
    if(($userAccountControl -band 1024) -eq 0x0400)        {$reservedB = $true}else{$reservedB=$false} # do odszukania co to
    if(($userAccountControl -band 2048) -eq 0x0800)        {$interdomain_trust_account = $true}else{$interdomain_trust_account = $false}
    if(($userAccountControl -band 4096) -eq 0x1000)        {$workstation_trust_account = $true}else{$workstation_trust_account = $false}
    if(($userAccountControl -band 8192) -eq 0x2000)        {$server_trust_account = $true}else{$server_trust_account = $false}
    if(($userAccountControl -band 16384) -eq 0x4000)       {$reservedC = $true}else{$reservedC = $false} # do odszukania co to
    if(($userAccountControl -band 32768) -eq 0x8000)       {$reservedD = $true}else{$reservedD = $false} # do odszukania co to
    if(($userAccountControl -band 65536) -eq 0x10000)      {$dont_expire_password = $true}else{$dont_expire_password = $false}
    if(($userAccountControl -band 131072) -eq 0x20000)     {$msn_logon_account = $true}else{$msn_logon_account = $false}
    if(($userAccountControl -band 262144) -eq 0x40000)     {$smartcard_required = $true}else{$smartcard_required = $false}
    if(($userAccountControl -band 524288) -eq 0x80000)     {$trusted_for_delegation = $true}else{$trusted_for_delegation = $false}
    if(($userAccountControl -band 528384) -eq 0x81000)     {$reservedE = $true}else{$reservedE = $false} # do odszukania co to
    if(($userAccountControl -band 532480) -eq 0x82000)     {$domain_controller = $true}else{$domain_controller = $false}
    if(($userAccountControl -band 1048576) -eq 0x100000)   {$not_delegated = $true}else{$not_delegated = $false}
    if(($userAccountControl -band 2097152) -eq 0x200000)   {$use_des_key_only = $true}else{$use_des_key_only = $false}
    if(($userAccountControl -band 4194304) -eq 0x400000)   {$dont_req_preauth = $true}else{$dont_req_preauth = $false}
    if(($userAccountControl -band 83388608) -eq 0x800000)  {$password_expired = $true}else{$password_expired = $false}
    if(($userAccountControl -band 16777216) -eq 0x1000000) {$trusted_to_auth_for_delegation = $true}else{$trusted_to_auth_for_delegation = $false}
    if(($userAccountControl -band 67108864) -eq 0x04000000){$partial_secrets_account = $true}else{$partial_secrets_account = $false}

    # obiekty pliku json
    $jsonData.users += @{
        users_pers_inf = @{
            userNumber = $i
            displayName = "$displayName"
            principalName = "$principalName"
            users_pers_data = @{
                firstName = "$firstName"
                surname = "$surname"
            } #end users_pers_data
        } # end users_pers_inf
        account_status_inf = @{
            accountStatus = czyKontoJestAktywne($userAccountControl)
            whenCreatedTimestamp = czyJestTimestamp($whenCreated)
            whenChangedTimestamp = czyJestTimestamp($whenChanged)
            lastLogOnTimestamp = czyJestTimestamp($lastLogOn)
            badPasswordTimestamp = czyJestTimestamp($badPassword)
            pwdLastSetTimestamp = czyJestTimestamp($pwdLastSet)
            accountExpiresTimestamp = czyJestTimestamp($accountExpires)
        } # end account_status_inf
        account_control_flags_status = @{
            accountControlFlagsStatus = $userAccountControl
            script_0x0001 = $script
            accoundDisable_0x0002 = $accoundDisable
            reservedA_0x0004 = $reservedA
            homedir_required_0x0008 = $homedir_required
            lockout_0x0010 = $lockout
            passwd_notreqd_0x0020 = $passwd_notreqd
            passwd_cant_change_0x0040 = $passwd_cant_change
            encrypted_text_pwd_allowed_0x0080 = $encrypted_text_pwd_allowed
            temp_duplicate_account_0x0100 = $temp_duplicate_account
            normal_user_0x0200 = $normal_user
            reservedB_0x0400 = $reservedB
            interdomain_trust_account_0x0800 = $interdomain_trust_account
            workstation_trust_account_0x1000 = $workstation_trust_account
            server_trust_account_0x2000 = $server_trust_account
            reservedC_0x4000 = $reservedC
            reservedD_0x8000 = $reservedD
            dont_expire_password_0x10000 = $dont_expire_password
            msn_logon_account_0x20000 = $msn_logon_account
            smartcard_required_0x40000 = $smartcard_required
            trusted_for_delegation_0x80000 = $trusted_for_delegation
            reservedE_0x81000 = $reservedE
            domain_controller_0x82000 = $domain_controller
            not_delegated_0x100000 = $not_delegated
            use_des_key_only_0x200000 = $use_des_key_only
            dont_req_preauth_0x400000 = $dont_req_preauth
            password_expired_0x800000 = $password_expired
            trusted_to_auth_for_delegation_0x1000000 = $trusted_to_auth_for_delegation
            partial_secrets_account_0x4000000 = $partial_secrets_account
        } # end account_control_flags_status
    } # end $data.users
    $i++

    $user = $null
    $properties = $null
    $displayName = $null
    $principalName = $null
    $firstName = $null
    $surname = $null
    $whenCreated = $null
    $whenChanged = $null
    $lastLogOn = $null
    $lastLogOn = $null
    $lastLogOn = $null
    $badPassword = $null
    $badPassword = $null
    $badPassword = $null
    $pwdLastSet = $null
    $pwdLastSet = $null
    $pwdLastSet = $null
    $accountExpires = $null
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
} # end foreach ( $user in $allUsers )

# zapis danych do plikow
$jsonData = $jsonData | ConvertTo-Json -Depth 5
$jsonData | Out-File -FilePath $jsonBaseWorkFilePath
$jsonData | Out-File -FilePath $jsonArchivesFilePath

# CLEANER
########################################################################################################################################

# VARIABLES

# to do ustawienia pod system
$configFilePath = $null

# zmienne globalne
$i = $null
$date = $null

# plik konfiguracyjny
$configFileName = $null
$configFile = $null

# zmienne z pliku konfiguracyjnego
$configFileValues = $null
$jsonBaseFileName = $null
$systemName = $null
$timestampFormat = $null
$workFilesPath = $null
$archivesFilesPath = $null
$addcLdapPath = $null
$timestampZero = $null

# zmienne przeszukiwanej domeny
$objSearch = $null
$allUsers = $null
$usersCount = $null

# plik bazy danych json
$jsonBaseWorkFileName = $null
$jsonBaseWorkFileName = $null

# plik archiwum bazy danych json
$jsonArchivesBaseFileName = $null

# sciezki do zapisu plikow json
$jsonBaseWorkFilePath = $null
$jsonArchivesFilePath = $null

# FUNCTIONS
$accountStatus = $null
$timestamp = $null

# PROGRAM
$jsonData = $null