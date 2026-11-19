# M365 & Entra ID Administration Scripts

A collection of PowerShell scripts using **Microsoft Graph** to automate routine identity and Microsoft 365 administration tasks, reduce manual errors, and support license governance.

## Scripts Included

### 1. `Find-DisabledUsersWithLicenses.ps1`
* **Purpose:** Identifies disabled Microsoft Entra ID user accounts that still have active licenses assigned and exports a dated CSV report.
* **Use Case:** Helps IT and MSP teams reclaim unused license seats and control Microsoft 365 licensing costs during offboarding audits.
* **Key Concepts:** Microsoft Graph (`Get-MgUser`), filtering disabled accounts, checking `AssignedLicenses`, and exporting to CSV (`Export-Csv`).

### 2. `New-EntraUsersFromCsv.ps1`
* **Purpose:** Bulk-creates Microsoft Entra ID user accounts from a CSV input file and enforces a password reset at next sign-in.
* **Use Case:** Speeds up new-hire onboarding while maintaining identity security standards and handling per-user errors gracefully.
* **Key Concepts:** Parameterized input (`-CsvPath`), `Import-Csv`, `foreach` loops, `PasswordProfile` (`ForceChangePasswordNextSignIn`), and `try / catch` error handling.

## Prerequisites
* PowerShell 7+ (or Windows PowerShell 5.1)
* **Microsoft Graph PowerShell SDK** (`Microsoft.Graph.Users`)
* Appropriate Microsoft Entra ID permissions/scopes (`User.Read.All`, `Directory.Read.All`, or `User.ReadWrite.All` depending on the script)

## Disclaimer
Test all scripts in a non-production or sandbox environment first and verify permissions before running them in production.
