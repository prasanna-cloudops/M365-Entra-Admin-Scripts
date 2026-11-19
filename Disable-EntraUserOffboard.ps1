<#
.SYNOPSIS
    Disables a Microsoft Entra ID user account and revokes active sign-in sessions.
.DESCRIPTION
    Takes a UserPrincipalName, disables the account in Microsoft Entra ID via Microsoft Graph,
    and revokes active refresh tokens so existing sessions are invalidated during offboarding.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
)

# 1. Connect to Microsoft Graph with permissions to update users and revoke sessions
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

try {
    # 2. Look up the target user by UPN
    $User = Get-MgUser -UserId $UserPrincipalName -Property Id, DisplayName, UserPrincipalName, AccountEnabled

    if (-not $User) {
        Write-Warning "User not found: $UserPrincipalName"
        return
    }

    # 3. Disable the account
    Update-MgUser -UserId $User.Id -AccountEnabled:$false

    # 4. Revoke active sign-in sessions (invalidates refresh tokens)
    Revoke-MgUserSignInSession -UserId $User.Id | Out-Null

    Write-Host "Offboarding step complete: Disabled $($User.UserPrincipalName) and revoked active sessions." -ForegroundColor Green
}
catch {
    Write-Warning "Failed offboarding for $UserPrincipalName`: $($_.Exception.Message)"
}
