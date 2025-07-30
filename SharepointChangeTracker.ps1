# SharePoint Change Tracker - PowerShell Version
# Tracks file/folder changes within a SharePoint site based on date/time range
# Dependencies: PnP.PowerShell, Microsoft Graph permissions for audit logs or activity API

param(
    [Parameter(Mandatory=$true)][datetime]$StartTime,
    [Parameter(Mandatory=$true)][datetime]$EndTime,
    [string]$OutputPath = "./SharePointChanges.csv"
)

# Replace the placeholders below before running the script
$siteUrl = "https://yourtenant.sharepoint.com/sites/yoursite"
$clientId = "'<YOUR-CLIENT-ID>'"
$tenantId = "'<YOUR-TENANT-ID>'"

# Ensure PnP PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name "PnP.PowerShell")) {
    Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser
}

Import-Module PnP.PowerShell

# Normalize Site URL (strip out /Shared Documents if accidentally appended)
if ($siteUrl -like "*/Shared Documents/*") {
    $siteUrl = $siteUrl -replace "/Shared Documents.*$", ""
}

# Connect using Azure AD App Registration with modern auth
try {
    Write-Host "Connecting to SharePoint site $siteUrl using Azure AD app registration..."
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -Interactive
} catch {
    Write-Error "Connection failed: $($_.Exception.Message)"
    exit 1
}

# Get items from the 'Documents' library and filter by modified date
Write-Host "Collecting changes from $StartTime to $EndTime..."

try {
    $items = Get-PnPListItem -List "Documents" -PageSize 1000 -Fields "FileRef","Editor","Modified","Created","Author","FSObjType"
    $changes = $items | Where-Object {
        $_.FieldValues.Modified -ge $StartTime -and $_.FieldValues.Modified -le $EndTime
    }
} catch {
    Write-Error "Failed to fetch change data: $_"
    exit 1
}

if (-not $changes) {
    Write-Host "No changes found in the specified time range."
    exit 0
}

# Convert to report format and tally created vs modified
$results = @()
$createdCount = 0
$modifiedCount = 0

foreach ($item in $changes) {
    $createdTime = $item.FieldValues.Created
    $modifiedTime = $item.FieldValues.Modified
    $isCreated = $createdTime -ge $StartTime -and $createdTime -le $EndTime
    $action = if ($isCreated) { "Created" } else { "Modified" }

    if ($action -eq "Created") { $createdCount++ } else { $modifiedCount++ }

    $results += [PSCustomObject]@{
        Action     = $action
        TimeStamp  = if ($action -eq "Created") { $createdTime } else { $modifiedTime }
        Created    = $createdTime
        Modified   = $modifiedTime
        User       = if ($action -eq "Created") { $item.FieldValues.Author.LookupValue } else { $item.FieldValues.Editor.LookupValue }
        ItemType   = if ($item.FieldValues.FSObjType -eq 1) { "Folder" } else { "File" }
        Path       = $item.FieldValues.FileRef
    }
}

# Export to CSV
$results | Export-Csv -Path $OutputPath -NoTypeInformation

Write-Host "Exported $($results.Count) changes to $OutputPath"
Write-Host "Total Created: $createdCount"
Write-Host "Total Modified: $modifiedCount"
