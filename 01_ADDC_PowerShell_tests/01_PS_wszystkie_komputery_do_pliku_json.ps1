Clear-Host


# to do ustawienia pod system
$configFilePath = "C:\01_ADDC_PowerShell_tests\" # sciezka do pliku konfiguracyjnego

# plik konfiguracyjny
$configFileName = "addc_tests_config_file.txt" # nazwa pliku konfiguracyjnego
$configFile = $configFilePath + $configFileName

# zmienne globalne
$i = 1
$date = Get-Date

# zmienne z pliku konfiguracyjnego
$configFileValues = Get-Content $configFile | Out-String | ConvertFrom-StringData
$addcLdapCmptrPath = $configFileValues.addcLdapCmptrPath
$jsonCmptrBaseFileName = $configFileValues.jsonCmptrBaseFileName
$systemName = $configFileValues.systemName
$timestampFormat = $configFileValues.timestampFormat
$workFilesPath = $configFileValues.workFilesPath
$archivesFilesPath = $configFileValues.archivesFilesPath
$timestampZero = $configFileValues.timestampZero

# zmienne przeszukiwanej domeny
$objSearch = New-Object System.DirectoryServices.DirectorySearcher
$objSearch.PageSize = 15000
$objSearch.Filter = "(objectClass=Computer)"
$objSearch.SearchRoot = $addcLdapCmptrPath
$allCmptrs = $objSearch.FindAll()
$cmptrCount = $allCmptrs.Count

# plik bazy danych json
$jsonBaseWorkFileName = $jsonCmptrBaseFileName + $systemName
$jsonBaseWorkFileName = "$jsonBaseWorkFileName.json"

# plik archiwum bazy danych json
$jsonArchivesBaseFileName = ($date).ToString($timestampFormat) + "_" + $jsonBaseWorkFileName

# sciezki do zapisu plikow json
$jsonBaseWorkFilePath = $workFilesPath + $jsonBaseWorkFileName
$jsonArchivesFilePath = $archivesFilesPath + $jsonArchivesBaseFileName

# FUNCTIONS
########################################################################################################################################
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
    cmptrCount = $cmptrCount
    computers = @()
}

foreach ( $cmptr in $allCmptrs ) {
    Write-Progress -Activity "Users in domain" -Status "Check completed $i of $cmptrCount" -PercentComplete (($i/$cmptrCount)*100) # pasek postepu
    $properties = $cmptr.Properties
    
    # dane identyfikacyjne
    $cmptrName = $properties.name
    $cmptrCn = $properties.cn
    $dnsHostName = $properties.dnshostname
    $operatingSystem = $properties.operatingsystem
    
    $primaryGroupId = $properties.primarygroupid

    # daty aktywnosci konta
    $whenCreated = [String]$properties.whencreated.ToFileTimeUtc()
    $whenChanged = [String]$properties.whenchanged.ToFileTimeUtc()
    $lastLogOn = [String]$properties.lastlogon
    $lastLogOn = [DateTime]::FromFileTimeUtc($lastLogOn)
    $lastLogOn = [String]$lastLogOn.ToFileTimeUtc()
    $lastLogOff = [String]$properties.lastlogoff
    $lastLogOff = [DateTime]::FromFileTimeUtc($lastLogOff)
    $lastLogOff = [String]$lastLogOff.ToFileTimeUtc()
    $badPassword = [String]$properties.badpasswordtime
    $badPassword = [DateTime]::FromFileTimeUtc($badPassword)
    $badPassword = [String]$badPassword.ToFileTimeUtc()
    $pwdLastSet = [String]$properties.pwdlastset
    $pwdLastSet = [DateTime]::FromFileTimeUtc($pwdLastSet)
    $pwdLastSet = [String]$pwdLastSet.ToFileTimeUtc()
    $accountExpires = [String]$properties.accountexpires
    $userAccountControl = [String]$properties.useraccountcontrol

    
    
    
    
    
    








    $jsonData.computers += @{
        cmptr_id_data = @{
            cmptrNumber = $i
            cmptrName = "$cmptrName"
            dnsHostName = "$dnsHostName"
            cmptrCn = "$cmptrCn"
            operatingSystem = "$operatingSystem"
        } # end users_pers_inf
        cmptr_status_inf = @{
            primaryGroupId = "$primaryGroupId"
            accountStatus = czyKontoJestAktywne($userAccountControl)
            whenCreatedTimestamp = czyJestTimestamp($whenCreated)
            whenChangedTimestamp = czyJestTimestamp($whenChanged)
            lastLogOnTimestamp = czyJestTimestamp($lastLogOn)
            lastLogOffTimestamp = czyJestTimestamp($lastLogOff)
            badPasswordTimestamp = czyJestTimestamp($badPassword)
            pwdLastSetTimestamp = czyJestTimestamp($pwdLastSet)
            accountExpiresTimestamp = czyJestTimestamp($accountExpires)
        } # end account_status_inf
        cmptr_control_flags_status = @{
#            accountControlFlagsStatus = $userAccountControl
#            script_0x0001 = $script
#            accoundDisable_0x0002 = $accoundDisable
#            reservedA_0x0004 = $reservedA
#            homedir_required_0x0008 = $homedir_required
#            lockout_0x0010 = $lockout
#            passwd_notreqd_0x0020 = $passwd_notreqd
#            passwd_cant_change_0x0040 = $passwd_cant_change
#            encrypted_text_pwd_allowed_0x0080 = $encrypted_text_pwd_allowed
#            temp_duplicate_account_0x0100 = $temp_duplicate_account
#            normal_user_0x0200 = $normal_user
#            reservedB_0x0400 = $reservedB
#            interdomain_trust_account_0x0800 = $interdomain_trust_account
#            workstation_trust_account_0x1000 = $workstation_trust_account
#            server_trust_account_0x2000 = $server_trust_account
#            reservedC_0x4000 = $reservedC
#            reservedD_0x8000 = $reservedD
#            dont_expire_password_0x10000 = $dont_expire_password
#            msn_logon_account_0x20000 = $msn_logon_account
#            smartcard_required_0x40000 = $smartcard_required
#            trusted_for_delegation_0x80000 = $trusted_for_delegation
#            reservedE_0x81000 = $reservedE
#            domain_controller_0x82000 = $domain_controller
#            not_delegated_0x100000 = $not_delegated
#            use_des_key_only_0x200000 = $use_des_key_only
#            dont_req_preauth_0x400000 = $dont_req_preauth
#            password_expired_0x800000 = $password_expired
#            trusted_to_auth_for_delegation_0x1000000 = $trusted_to_auth_for_delegation
#            partial_secrets_account_0x4000000 = $partial_secrets_account
        } # end account_control_flags_status
    } # end $data.users

































    echo $i
    echo "computer name: `t`t$cmptrName"
    echo "computer cn: `t`t$cmptrCn"
    echo "computer host name: $dnsHostName"
    echo "operatingSystem: `t$operatingSystem"
    echo ""
    echo "whencreated:`t`t`t $whencreated"
    echo "whenchanged:`t`t`t $whenchanged"
    echo "lastlogon:`t`t`t`t $lastlogon"
    echo "lastlogontimestamp:`t`t $lastlogontimestamp"
    echo "lastlogoff:`t`t`t`t $lastlogoff"
    echo "pwdlastset:`t`t`t`t $pwdlastset"
    echo "badpasswordtime:`t`t $badpasswordtime"
    echo "accountexpires:`t`t`t $accountexpires"


    echo ""
    echo "primarygroupid:`t`t`t $primarygroupid"



    echo ""
    $userAccountControl = [String]$properties.useraccountcontrol

    $accountStatus = czyKontoJestAktywne($userAccountControl)
    Write-Host "Account status:`t`t`t`t`t" -NoNewline
    Write-Host "[ " -NoNewline
    if ($accountStatus -eq $true) {Write-Host "DISABLED" -NoNewline -ForegroundColor Red}
    if ($accountStatus -eq $false) {Write-Host "ACTIVE" -NoNewline -ForegroundColor Green}
    Write-Host " ]"
    
    
    
    
    echo ""
    $samaccounttype = $properties.samaccounttype
    echo "samaccounttype:`t`t`t $samaccounttype"




    
    

    echo "-----------------------------------------"


    $i++

    $cmptr = $null
    $properties = $null

    $cmptrName = $null
    $cmptrCn = $null
    $dnsHostName = $null
    $operatingSystem = $null

    $primaryGroupId = $null

    $whenCreated = $null
    $whenChanged = $null
    $lastLogOn = $null
    $badPassword = $null
    $pwdLastSet = $null
    $accountExpires = $null
    $lastLogOff = $null



} # end foreach ( $cmptr in $allCmptrs )

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
$addcLdapCmptrPath = $null
$jsonCmptrBaseFileName = $null
$systemName = $null
$timestampFormat = $null
$workFilesPath = $null
$archivesFilesPath = $null
$timestampZero = $null

# zmienne przeszukiwanej domeny
$objSearch = $null
$allCmptrs = $null
$cmptrCount = $null

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


