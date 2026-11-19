<#
.SYNOPSIS
    Creates new Microsoft Entra ID user accounts in bulk from a CSV file.
.DESCRIPTION
    Reads new hire details from a CSV (DisplayName, UserPrincipalName, MailNickname,
    Department, JobTitle, TempPassword), creates the Entra ID accounts via Microsoft Graph,
    and requires a password change at next sign-in.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

# 1. Connect to Microsoft Graph with permission to create users
Connect-MgGraph -Scopes "User.ReadWrite.All"

# 2. Import the CSV file into a PowerShell variable
$NewUsers = Import-Csv -Path $CsvPath

# 3. Loop through each row in the CSV and create the account
foreach ($User in $NewUsers) {
    # Define password profile so the user must change their temporary password on first login
    $PasswordProfile = @{
        Password                      = $User.TempPassword
        ForceChangePasswordNextSignIn = $true
    }

    # Build parameters for the new Entra ID user
    $UserParams = @{
        AccountEnabled    = $true
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        MailNickname      = $User.MailNickname
        Department        = $User.Department
        JobTitle          = $User.JobTitle
        PasswordProfile   = $PasswordProfile
    }

    try {
        New-MgUser @UserParams | Out-Null
        Write-Host "Created account: $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create $($User.UserPrincipalName): $($_.Exception.Message)"
    }
}
