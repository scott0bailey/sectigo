## STANDALONE:
export CN=<CN>
export LOC=/path/to/certificates
acme.sh --issue --nginx -d $CN --fullchain-file $LOC/fullchain.pem --key-file $LOC/privkey.pem -k 2048


## MD
export CN=<CN>
export SAN1=<SAN1>
export SAN2=<SAN2>
export LOC=/path/to/certificates
acme.sh --issue --nginx -d $CN -d $SAN1 -d $SAN2 --fullchain-file $LOC/fullchain.pem --key-file $LOC/privkey.pem -k 2048


## With Post hooks
export CN=<CN>
export SAN1=<SAN1>
export SAN2=<SAN2>
export RESTART_CMD=<restart_cmd>
acme.sh --issue --nginx -d $CN -d $SAN1 -d $SAN2 --post-hook "cat /root/.acme.sh/$CN/$CN.cer /root/.acme.sh/$CN/$CN.key > /home/tls/tls.pem && $RESTART_CMD -k 2048


