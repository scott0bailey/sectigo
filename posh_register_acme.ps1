$eabKID = '<eab>'
$eabHMAC = '<hmac>'
$email = '<email>'
Set-PAServer https://acme.enterprise.sectigo.com
New-PAAccount -ExtAcctKID $eabKID -ExtAcctHMACKey $eabHMAC -Contact $email -AcceptTOS
