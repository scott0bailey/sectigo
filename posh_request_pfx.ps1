# Must register posh acme account prior to running this (posh_register_acme.ps1)
# 1. Gather Inputs
$domainName = Read-Host "Enter the Main Domain (CN)"
$sanInput = Read-Host "Enter any SAN names (comma-separated, or leave blank)"

# Process SANs into an array
$allDomains = @($domainName)
if ($sanInput) {
    $allDomains += $sanInput.Split(',').Trim()
}

# 2. Silence background noise
$ProgressPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'

# Generate password
$passwordLength = 16
$pfxPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count $passwordLength | ForEach-Object {[char]$_})

# 3. Create the .\$CN\ directory (Silent)
$targetDir = Join-Path -Path (Get-Location) -ChildPath $domainName
if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory | Out-Null
}

# 4. Request the certificate SILENTLY
New-PACertificate -Domain $allDomains -AcceptTOS -Install *>$null

# 5. Grab the resulting object quietly
$certOrder = Get-PACertificate -MainDomain $domainName

# 6. Setup PFX Path inside the new folder
$pfxPath = Join-Path -Path $targetDir -ChildPath "$domainName.pfx"

# 7. Copy the PFX Posh-ACME already created
if (Test-Path $certOrder.PfxFullChain) {
    Copy-Item -Path $certOrder.PfxFullChain -Destination $pfxPath -Force
}

# 8. Final Display
Write-Host "`n----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Certificate Request Complete!" -ForegroundColor Green
Write-Host "Directory:   $targetDir"
Write-Host "PFX File:    $domainName.pfx"
Write-Host "PFX Password: $pfxPassword" 
Write-Host "----------------------------------------------------" -ForegroundColor Cyan
