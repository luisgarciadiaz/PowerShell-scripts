# 1. Sub-folders for 02 Library
$librarySubs = @(
    "01 Technical and Programming",
    "02 Kindle and Fiction",
    "03 Training and Courses",
    "04 Audiobooks"
)

# 2. Sub-folders for 04 Archive
$archiveSubs = @(
    "01 Old Web Backups",
    "02 Past Client Projects",
    "03 Legacy Software",
    "04 Personal History"
)

# 3. Sub-folders for 05 Inbox
$inboxSubs = @(
    "01 To Sort",
    "02 Downloads Temp",
    "03 For Review"
)

# Function to create folders safely
function Create-SubFolders($Parent, $Subs) {
    foreach ($sub in $Subs) {
        $path = "D:\$Parent\$sub"
        if (-not (Test-Path -Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
}

# Execute creation
Create-SubFolders "02 Library" $librarySubs
Create-SubFolders "04 Archive" $archiveSubs
Create-SubFolders "05 Inbox" $inboxSubs

Write-Host "All sub-folders for Library, Archive, and Inbox have been created." -ForegroundColor Green