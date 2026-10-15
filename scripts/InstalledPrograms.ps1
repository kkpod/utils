
# Installed Programs - Add or Remove Programs
# $OutputFolder = "$env:USERPROFILE\Desktop\InstalledPrograms"
$OutputFolder = Join-Path $PSScriptRoot "InstalledPrograms"

New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

$Paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$Apps = foreach ($Path in $Paths) {
    Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object @{
            Name = "Application"; Expression = { $_.DisplayName }
        }, @{
            Name = "Version"; Expression = { $_.DisplayVersion }
        }, @{
            Name = "Publisher"; Expression = { $_.Publisher }
        }, @{
            Name = "InstallDate"; Expression = { $_.InstallDate }
        }, @{
            Name = "SizeKB"; Expression = { $_.EstimatedSize }
        }, @{
            Name = "InstallLocation"; Expression = { $_.InstallLocation }
        }, @{
            Name = "UninstallCommand"; Expression = { $_.UninstallString }
        }
}

$Apps = @($Apps | Sort-Object Application, Version -Unique)

# Export CSV
$Apps | Export-Csv "$OutputFolder\InstalledPrograms.csv" `
    -NoTypeInformation -Encoding UTF8

# Export HTML
$Apps | ConvertTo-Html `
    -Title "Installed Programs" `
    -PreContent "<h1>Installed Programs</h1><p>Computer: $env:COMPUTERNAME</p><p>Total entries: $($Apps.Count)</p>" `
    -Property Application, Version, Publisher, InstallDate, SizeKB, InstallLocation |
    Out-File "$OutputFolder\InstalledPrograms.html" -Encoding utf8

Write-Host "Found $($Apps.Count) program entries."
Write-Host "Reports saved to: $OutputFolder"

Start-Process "$OutputFolder\InstalledPrograms.html"
