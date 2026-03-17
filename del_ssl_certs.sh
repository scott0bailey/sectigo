#!/usr/bin/env python3
import requests

# ids.txt file must be in the same directory as the script and be one line per
# chmod +x del_ssl_certs.sh
# ./del_ssl_certs.sh
#
# Change this to the correct DELETE endpoint you need
# Example for deleting an SSL cert in SCM:
# url = "https://cert-manager.com/api/ssl/v1/"
#
# If you are deleting *device* certificates instead:
# url = "https://cert-manager.com/api/device/v1/"
#
url = "https://cert-manager.com/api/ssl/v1/"

headers = {
    'login': '<username>',
    'password': '<password>',
    'customerUri': '<URI>',
}

with open('ids.txt', 'r') as file:
    ids = [line.strip() for line in file.readlines()]

for id in ids:
    if not id:
        continue  # skip just in case
    api_url = f"{url}{id}"
    response = requests.request("DELETE", api_url, headers=headers)
    print(f"{id} → {response.status_code} → {response.text}")
