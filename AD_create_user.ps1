# THIS SCRIPT IS USED TO CREATE BULK AD USERS FROM A CSV FILE

# IT DOES NOT ADD AD GROUPS OR ASSIGN LICENSES IN MSONLINE

# THE CSV REQUIRES THE FOLLOWING HEADERS: name, distinguishedName, description, office, company, department, manager

# location of csv file

$newUser = Import-Csv -Path ''

foreach($user in $newUser) {

    # whole name

    $name = $user.name

    # first name

    $fn = $name.Split(" ")[0]

    # last name

    $ln = $name.Split("")[1]

    # sam

    $sam = $name[0] + $ln

    # sam lowercase

    $samLower = $sam.ToLower()

    $GetUser = Get-ADUser -Filter "samaccountname -eq '$($samLower)'"

    # if user account already exists, write a warning

    if ($GetUser -ne $Null) {

        Write-Warning "$($samLower) belongs to an existing account."

        Write-Warning "User with existing account is: $($GetUser.DistinguishedName)"

        Continue

    # otherwise, create a new account

    } else {

        Write-Host 'Creating account, please wait...' -ForegroundColor Yellow

        # user principal name (sign on)

        $upn = "$($samLower)@domain.com"

        # user folder location

        $ou = $user.distinguishedName

        # description

        $desc = $user.description

        # office

        $office = $user.office

        # email

        $email = "$($samLower)@emailaddress.com"

        # company

        $company = $user.company

        # department

        $dep = $user.department

        # manager

        $manager = $user.manager

        # proxy email

        $proxy = "SMTP:$($email)"

        New-ADUser `

        -Name $name `

        -DisplayName $name `

        -GivenName $fn `

        -Surname $ln `

        -SamAccountName $samLower `

        -UserPrincipalName $upn `

        -Path $ou `

        -AccountPassword(Read-Host -AsSecureString 'Input password.') `

        -PasswordNeverExpires $true `

        -CannotChangePassword $true `

        -Enabled $true

        Set-ADUser `

        -Identity $samLower `

        -Description $desc `

        -Office $office `

        -EmailAddress $email `

        -Company $company `

        -Department $dep `

        -Manager $manager `

        -Title $desc `

        -Add @{proxyAddresses=$proxy}

        Write-Host 'Account was created successfully.' -ForegroundColor Green

        # get newly created user info

        Get-ADUser -Identity $sam -Properties displayName, emailAddress, proxyAddresses

    }

}