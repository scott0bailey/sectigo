# Needs to be run once time pwer server
# Install posh acme
Install-Module -Name Posh-ACME.Deploy -Scope CurrentUser
Install-Module PANOShell -scope CurrentUser

# Register acme account
$eabKID = '<eab>'
$eabHMAC = '<hmac>'
$email = '<email>'
Set-PAServer https://acme.enterprise.sectigo.com
New-PAAccount -ExtAcctKID $eabKID -ExtAcctHMACKey $eabHMAC -Contact $email -AcceptTOS
