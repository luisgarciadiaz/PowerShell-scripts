$root = "D:\"
$folders = @(
    "[01] Work & Projects (Active)",
    "[02] Library (Consolidated)",
    "[03] Media & Assets",
    "[04] Archive (Historical)",
    "[05] Inbox / Processing"
)

$folders | ForEach-Object {
    $path = Join-Path -Path $root -ChildPath $_
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
}