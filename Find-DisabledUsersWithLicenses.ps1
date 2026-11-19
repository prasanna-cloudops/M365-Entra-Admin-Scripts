<#
.SYNOPSIS
    Finds disabled Microsoft Entra ID accounts that still have paid M365 licenses assigned.
.DESCRIPTION
    Connects to Microsoft Graph, retrieves all disabled user accounts, checks if they hold 
    assigned licenses, and exports a clean CSV audit report for license reclamation.
#>

# 1. Connect to Microsoft Graph with read-only permissions for Users and Directory
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# 2. Fetch all user accounts where AccountEnabled is False (Disabled)
# We explicitly request DisplayName, UserPrincipalName, AccountEnabled, and AssignedLicenses
$DisabledUsers = Get-MgUser -All -Filter "accountEnabled eq false" -Property DisplayName, UserPrincipalName, AccountEnabled, AssignedLicenses

# 3. Filter down to ONLY the disabled users who still have at least 1 license attached
$UsersToReclaim = $DisabledUsers | Where-Object { $_.AssignedLicenses.Count -gt 0 }

# 4. Format the output cleanly into a custom object list
$Report = foreach ($User in $UsersToReclaim) {
    [PSCustomObject]@{
        Name              = $User.DisplayName
        Email_UPN         = $User.UserPrincipalName
        AccountStatus     = "Disabled"
        LicenseCount      = $User.AssignedLicenses.Count
    }
}

# 5. Export the results to a CSV file with today's date in the filename
$Date = Get-Date -Format "yyyy-MM-dd"
$ExportPath = ".\Disabled_Licensed_Users_$Date.csv"

$Report | Export-Csv -Path $ExportPath -NoTypeInformation

Write-Host "Audit complete! Found $($Report.Count) disabled accounts with active licenses." -ForegroundColor Green
Write-Host "Report saved to: $ExportPath" -ForegroundColor Cyan
