# CrushFTP for Kubernetes

Share your files securely with FTP, Implicit FTPS, SFTP, HTTP, or HTTPS using CrushFTP using Helm and docker.

This Helm chart will perform the following actions:
1. Create the desired number of CrushFTP instances.
2. Create a Persistent Volume Claim for all of the instances to store config data.
3. Create a secret that stores Azure File Share account information.
4. Mount a directory on each container instance that connects to the Azure File Share.  This is used for FTP files.
5. Create an Ingress for the K8s cluster that can handle certificates.
6. Create LoadBalancer instance and setup CrushFTP ports.

# Getting started with helm

Prerequisites:
1. Create Azure Storage Account and Azure File Share.  Note the Storage Account Key.
2. Create a DNS record for the desired host name of CrushFTP (ftp.company.com).  This should be an A record that points to the K8s Ingress controller.

Install the chart.

```
helm install crushftp . -f values.yaml -n namespace --create-namespace --set azure.client.default.key=foo
```

## Helm chart values

Override helm chart values with the settings you want.

| Parameter                    | Description                                                                                             | Default      |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- | ------------ |
| admin.username               | Username for the initial admin account.                                                                 | crushadmin   |
| admin.password               | Password for the initial admin account.                                                                 | *generated*  |
| admin.protocol               | Protocol for health checks and probs.                                                                   | http         |
| admin.port                   | Port for health checks and probs.                                                                       | 8080         |
| features.enableFtp           | Used to enable FTP protocol if needed.                                                                  | false        |
| tls.secretName               | Name of the secret to use for the TLS certificate.                                                      | crushftp-tls |
| volumes                      | Volume to mount for FTP root folder.                                                                    | /ftproot     |
| configVolume.size            | Size of the CrushFTP configuration volume.                                                              | 8Gi          |
| loadBalancerIp               | IP address of the ingress to use.                                                                       | 127.0.0.1    |
| shared.hosts.crushFtp.root   | Root domain of the sftp site.                                                                           | .local.com   |
| shared.hosts.crushFtp.prefix | Prefix or sub-domain of the sftp site.                                                                  | \ ftp        |
| shared.ingress.clusterIssuer | Used to enable a cluster certificate issuer such as cert-manager and lets-encrypt.                      | ''           |
| shared.storageClassName      | Sets the storage class to use for the config volume.                                                    | default      |

## Volumes

| Volume                | Required | Function                                                   | Example                                               |
| --------------------- | -------- | ---------------------------------------------------------- | ----------------------------------------------------- |
| `/var/opt/crushftp`   | Yes      | Persistent storage for CrushFTP config                     | `/your/config/path/:/var/opt/crushftp`.               |
| `/ftproot`            | No       | Mounts Azure File Share to this directory in the container | `/StorageAccount/FileShare/ShareName/:/ftproot`       |

* You can add as many volumes as you want between host and the container and change their mount location within the container. You will configure individual folder access and permissions for each user in CrushFTPs User Manager.

## Ports

| Port        | Proto | Required | Function          | Example               |
| ----------- | ----- | -------- | ----------------- | --------------------- |
| `21`        | TCP   | Yes      | FTP Port          | `21:21`               |
| `443`       | TCP   | Yes      | HTTPS Port        | `443:443`             |
| `2000-2100` | TCP   | Yes      | Passive FTP Ports | `2000-2100:2000-2100` |
| `2222`      | TCP   | Yes      | SFTP Port         | `2222:2222`           |
| `8080`      | TCP   | Yes      | HTTP Port         | `8080:8080`           |
| `9090`      | TCP   | Yes      | HTTP Alt Port     | `9090:9090`           |

* If you wish to run certain protocols on different ports you will need to change these to match the CrushFTP config. If you enable implicit or explicit FTPS those ports will also need to be opened.

## Environment Variables

| Variable               | Description               | Default      |
| :--------------------- | :------------------------ | :----------- |
| `CRUSH_ADMIN_USER`     | Admin user of CrushFTP    | `crushadmin` |
| `CRUSH_ADMIN_PASSWORD` | Password for admin user   | `crushadmin` |
| `CRUSH_ADMIN_PROTOCOL` | Protocol for health cecks | `http`       |
| `CRUSH_ADMIN_PORT`     | Port for health cecks     | `8080`       |

## Installation

Run this container and mount the containers `/var/opt/crushftp` volume to the host to keep CrushFTP's configuration persistent. Open a browser and go to `http://<IP>:8080`. Note that the default username and password are both `crushadmin` unless the default environment variables are changed.

This command will create a new container and expose all ports. Remember to change the `<volume>` to a location on your host machine.

```
docker run -p 21:21 -p 443:443 -p 2000-2100:2000-2100 -p 2222:2222 -p 8080:8080 -p 9090:9090 -v <volume>:/var/opt/crushftp netlah/crushftp:latest
```

# CrushFTP Configuration

Visit the [CrushFTP 10 Wiki](https://www.crushftp.com/crush10wiki/)


## Publishing docker image

1. Set the `.env` file `DOCKER_TAG` variable to the new version
2. Build the image:

    ```bash
    docker-compose build --no-cache
    ```

- Docker image based on https://github.com/NetLah/docker-crushftp
- [CrushFTP - Linux Install](https://www.crushftp.com/crush10wiki/Wiki.jsp?page=Linux%20Install)
