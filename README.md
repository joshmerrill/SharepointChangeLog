# SharepointChangeLog
This PowerShell script audits changes in a SharePoint Online document library over a specified time range. It identifies files or folders that were created or modified, exports detailed logs to CSV, and reports total counts.

SharePoint Change Tracker (PowerShell)

This PowerShell script audits changes in a SharePoint Online document library over a specified time range. It identifies files or folders that were created or modified, exports detailed logs to CSV, and reports total counts.

🔧 Features

Connects using Azure AD App Registration with modern authentication (interactive login)

Tracks both Created and Modified timestamps

Reports user, action type, path, and object type

Supports OneDrive-synced SharePoint activity

Exports results to .csv for easy analysis

📁 Output CSV Fields

Field

Description

Action

Created or Modified

TimeStamp

Timestamp of the action (created or modified)

Created

Original created time

Modified

Last modified time

User

User who performed the action

ItemType

File or Folder

Path

SharePoint server-relative path

🚀 Usage

🔐 Prerequisites

PowerShell 7+

PnP.PowerShell module (installs automatically if missing)

Azure AD App Registration with delegated permissions:

Microsoft Graph: Sites.Read.All, User.Read

SharePoint: AllSites.Read

Authentication > Allow Public Client Flows: ✅ Enabled

Redirect URI: http://localhost

🛠️ Replace the following placeholders in the script:

$siteUrl = "https://yourtenant.sharepoint.com/sites/yoursite"
$clientId = "'<YOUR-CLIENT-ID>'"
$tenantId = "'<YOUR-TENANT-ID>'"

▶️ Run the Script

./SharePointLogs.ps1 -StartTime "07/01/2025" -EndTime "07/30/2025"

The script will prompt for login, connect to SharePoint, and export results to ./SharePointChanges.csv.

📊 Example Output

Exported 3101 changes to ./SharePointChanges.csv
Total Created: 243
Total Modified: 2858

📌 Notes

Items may show as Modified if OneDrive created them locally, then synced after creation time.

This script only audits one document library (Documents).

To track more libraries, update the script with additional Get-PnPListItem calls.

📄 License

MIT License

🤝 Contributing

Feel free to fork this repository, open pull requests, or suggest improvements!

👨‍💻 Author

Josh Merrill
