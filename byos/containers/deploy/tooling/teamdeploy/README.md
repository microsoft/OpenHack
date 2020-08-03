# Deploying Services to Team Sub

This directory contains the contents of the Containers v2 Openhack team deployment container.

## Prereqs

- Docker

### Note

The following environment variables are optional:

- RESOURCEGROUPNAME
- TENANTID -- *Required if using a service principal*
- CHATCONNECTIONSTRING
- CHATMSGQUEUE
- RECIPIENTEMAIL

```shell
docker build -t teamdeploy .
docker run -it /
    -e AZUREUSER="" /
    -e AZUREPASS="" /
    -e SUBID="" /
    -e CHATCONNECTIONSTRING="" /
    -e CHATMSGQUEUE="" /
    -e LOCATION="" /
    -e RECIPIENTEMAIL="" /
    -e TENANTID="" / # (Required if AZUREUSER is a service principal)
    -e PROCTORRESOURCEGROUP="" / # Optional, added for build pipeline
    -e RESOURCEGROUPNAME="" # Optional
    teamDeploy
```
