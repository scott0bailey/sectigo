#!/usr/bin/env python3
import requests

# ids.txt should be in the same directory as the script and be one line per
# Change this to the correct DELETE endpoint you need
# Example for deleting an SSL cert in legacy SCM:
# url = "https://cert-manager.com/api/ssl/v1/"
#
# If you are deleting *device* certificates instead:
# url = "https://cert-manager.com/api/device/v1/"
#
# Just append the ID afterward.
url = "https://cert-manager.com/api/ssl/v1/"

headers = {
    'login': '',
    'password': '',
    'customerUri': '',
}

with open('ids.txt', 'r') as file:
    ids = [line.strip() for line in file.readlines()]

for id in ids:
    if not id:
        continue  # skip just in case
    api_url = f"{url}{id}"
    response = requests.request("DELETE", api_url, headers=headers)
    print(f"{id} → {response.status_code} → {response.text}")
