$targetPath = "G:\My Drive\"
$folders = @(
    "01_Development",
    "02_Personal",
    "03_Knowledge",
    "04_Family",
    "05_Media",
    "06_Masoneria",
    "07_Notes",
    "08_Writing",
    "09_Tech_Resources"
)

foreach ($folder in $folders) {
    New-Item -Path $targetPath -Name $folder -ItemType Directory -Force
}