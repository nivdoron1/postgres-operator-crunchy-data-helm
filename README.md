---

## Preparation
    
1. **Set App Label**
Choose the app label corresponding to the cluster you are working on.
    
    ```bash
    # Option 1
    export APPLABEL=app-deployment
    
    ```
    
2. **Set Namespace**
Specify the namespace of your cluster.
    
    ```bash
    export NAMESPACE="postgres-operator"
    
    ```
    
3. **Set Azure Container Name**
Specify the name of your Azure container.
    
    ```bash
    export AZURE_CONTAINER_NAME=<your-azure-container-name>
    
    ```


4. **Add your app-deployment image**
Specify the name of your app-deployment image.

    ```bash
    export APP_IMAGE= <your-app-image>

    ```
    
5. **Configure Azure Account**
Edit the `azure.conf` file to include your Azure account details.
    
    ```bash
    mv example.azure.conf azure.conf
    vim azure-secret-creds/azure.conf
    
    ```
    
    ```
    [global]
    repo1-azure-account=<azure-account-name>
    repo1-azure-key=<azure-account-key>
    
    ```
    

---

## Installation

1. **Run Configuration Script**
    
    ```bash
    bash helm-config.sh
    
    ```
    
2. **Install PGO, Postgres Operator, and Monitoring**
    
    ```bash
    helm install pgo -n $NAMESPACE helm/install
    helm install postgres-operator -n $NAMESPACE helm/postgres
    helm install monitoring -n $NAMESPACE helm/monitoring
    
    ```
    

---

## Data Transfer

1. **Get Source Pod ID**
    
    ```bash
    export SRC_POD_ID=$(kubectl get pods -n $NAMESPACE --selector=app.kubernetes.io/name=$APPLABEL -o jsonpath='{.items[0].metadata.name}')
    
    ```
    
2. **Get Destination Pod ID**
    
    ```bash
    export DST_POD_ID=$(kubectl get pods -n $NAMESPACE --selector=postgres-operator.crunchydata.com/role=master -o jsonpath='{.items[0].metadata.name}')
    
    ```
    
3. **Define Container Name**
    
    ```bash
    export CONTAINER_NAME="database"
    
    ```
    
4. **Execute Data Transfer Script**
    
    ```bash
    bash data-transfer.sh  # This might take some time
    
    ```
    
5. **Access Pod for Data Verification**
    
    ```bash
    kubectl exec -it -n $NAMESPACE $SRC_POD_ID -- /bin/bash
    psql -h $(echo $DB_ADDR) -p $(echo $DB_PORT) -U $(echo $DB_USER) -d $(echo $DB_DATABASE)
    ```
    

---

## Retrieving Password

1. **Retrieve Database Password**
In a new terminal, retrieve the database password using the following command.
    
    ```bash
    kubectl -n postgres-operator get secrets insait-azure-pguser-insait-azure -o jsonpath="{.data['\\password']}" | base64 -d
    
    ```
    

---
# install the PGO client
This document outlines the necessary steps to set up the Postgres Operator and perform a data transfer, including initial configuration and installation, data transfer steps, and how to retrieve the database password for data verification purposes.


This README provides step-by-step instructions for installing and configuring the PostgreSQL Operator (pgo) Client. This guide assumes that the Crunchy PostgreSQL Operator is already deployed.

## Prerequisites

- For Kubernetes deployments: `kubectl` configured to communicate with Kubernetes
- For OpenShift deployments: `oc` configured to communicate with OpenShift
- Client CA Certificate
- Client TLS Certificate
- Client Key

**Note**: Obtain the above requirements from an administrator who has installed the Crunchy PostgreSQL Operator.

---

## Linux

### Installing the Client

1. Download the pgo client from the [GitHub official releases](https://github.com/CrunchyData/postgres-operator/releases).

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/c3464975-dff4-4c5a-9152-efffe539e298/7e9ecc4b-b639-461e-b5ab-e41ae26838d2/Untitled.png)

1. Move the downloaded `pgo` binary to `/usr/local/bin` and set the executable permission:
    
    ```bash
    sudo mv /PATH/TO/pgo /usr/local/bin
    sudo chmod +x /usr/local/bin/pgo
    
    ```
    
2. Verify the installation:
    
    ```bash
    pgo --help
    
    ```
    

### Configuring Client TLS

If you dont have Client TLS please follow the instruction on this page: 

[Creating TLS Certificates for Client Authentication:](https://www.notion.so/Creating-TLS-Certificates-for-Client-Authentication-a52e8d7bf99d4407b3cd7db71f3fcee9?pvs=21) 

1. Create a directory to store the TLS files:
    
    ```bash
    mkdir ${HOME?}/.pgo
    chmod 700 ${HOME?}/.pgo
    
    ```
    
2. Copy the certificates:
    
    ```bash
    cp /PATH/TO/client-cert.pem ${HOME?}/.pgo/client.crt && chmod 600 ${HOME?}/.pgo/client.crt
    cp /PATH/TO/client-key.pem ${HOME?}/.pgo/client.pem && chmod 400 ${HOME?}/.pgo/client.pem
    
    ```
    
3. Set the environment variables:
    
    ```bash
    echo 'export PGO_CA_CERT="${HOME?}/.pgo/client.crt"' >> ${HOME?}/.bashrc
    echo 'export PGO_CLIENT_CERT="${HOME?}/.pgo/client.crt"' >> ${HOME?}/.bashrc
    echo 'export PGO_CLIENT_KEY="${HOME?}/.pgo/client.pem"' >> ${HOME?}/.bashrc
    source ~/.bashrc
    
    ```
    

### Configuring `pgouser`

1. Set up the `pgouser` file: 
    
    ```bash
    echo "<USERNAME_HERE>:<PASSWORD_HERE>" > ${HOME?}/.pgo/pgouser
    
    #if you want some default user:
    echo "postgres:postgres" > ${HOME?}/.pgo/pgouser
    
    ```
    
2. Set the environment variable:
    
    ```bash
    echo 'export PGOUSER="${HOME?}/.pgo/pgouser"' >> ${HOME?}/.bashrc
    source ~/.bashrc
    
    ```
    

### Configuring the API Server URL

1. For port forwarding:
    
    ```bash
    # If deployed to Kubernetes
    kubectl port-forward -n pgo svc/postgres-operator 8443:8443
    
    ```
    
2. Set the API server URL:
    
    ```bash
    echo 'export PGO_APISERVER_URL="https://<IP_OF_OPERATOR_API>:8443"' >> ${HOME?}/.bashrc
    source ~/.bashrc
    
    ```
    

**Note**: If using port-forwarding, set the IP to `127.0.0.1`.

---

## Verify the Installation

Run the following command to verify your installation:

```bash
pgo version

```

If the command outputs the versions of both the client and API server, your installation is successful.

---
# install the CA Certificate
For Windows installation and using PGO-Client in a containerized environment, please refer to the detailed documentation.

Happy Postgres Managing!

This README provides instructions for generating a Client CA Certificate and Client TLS Certificate. These certificates are essential for secure client-server communication in various applications, including secure REST APIs, databases, and more.

## Prerequisites

- OpenSSL installed on your system

## Generating Client CA Certificate

### Step 1: Generate the CA Private Key

## 1. Create a private key:

```bash
openssl genpkey -algorithm RSA -out ca-key.pem
```

### Step 2: Create the CA Certificate

Using the private key, we'll create a self-signed CA certificate. The certificate will be used to sign the client certificates.

```bash
openssl req -new -x509 -key ca-key.pem -out ca-cert.pem -days 365

```

You will be prompted to enter details like country, state, and more. These will be embedded in the CA certificate.

## Generating Client TLS Certificate

### Step 3: Generate the Client Private Key

Create a private key for the client certificate.

```bash
openssl genpkey -algorithm RSA -out client-key.pem

```

### Step 4: Create a Certificate Signing Request (CSR) for the Client

Now, we'll create a Certificate Signing Request (CSR) for the client. This request will include the public key and additional details like Common Name (CN), Organization (O), etc.

```bash
openssl req -new -key client-key.pem -out client-csr.pem

```

You will be prompted to enter details that will be included in the certificate. The most important is the Common Name (CN), which should match the domain name of the service you're connecting to.

### Step 5: Sign the Client Certificate using the CA

Finally, we'll use our CA to sign the client's CSR, resulting in the client certificate.

```bash
openssl x509 -req -in client-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365

```

## Verifying the Certificates

You can use OpenSSL to view the details of the certificates.

To view the CA certificate:

```bash
openssl x509 -in ca-cert.pem -text -noout

```

To view the Client certificate:

```bash
openssl x509 -in client-cert.pem -text -noout

```

## Conclusion

Now you have a Client CA certificate (`ca-cert.pem`) and a Client TLS certificate (`client-cert.pem`). Keep these files secure and distribute them only to trusted parties. Follow your application's documentation on how to use these certificates for secure communication.

Remember that these certificates have a limited validity period (365 days as configured), so you'll need to renew them before they expire.


# install the PGO Kubectl client 

This README guide is aimed at helping you download and install version 0.3.0 of the `pgo` Client Plugin for kubectl. The plugin facilitates the creation and management of PostgreSQL clusters created using Crunchy Postgres for Kubernetes.

## Prerequisites

- kubectl installed on your machine
- Access to the internet to download the plugin

## Features in v0.3.0

- Support Export command collects various resources from the PostgresCluster's namespace, such as LimitRanges, Ingresses, and running processes.
- Enhanced logging and user output for the Support Export command.
- The archive file from Support Export is now compressed in tar.gz format and includes version information.
- ... and more.

## How to Download and Install

### AMD64 Architecture

```bash
curl -L -o kubectl-pgo https://github.com/CrunchyData/postgres-operator-client/releases/download/v0.3.0/kubectl-pgo-linux-amd64
chmod +x kubectl-pgo
sudo mv kubectl-pgo /usr/local/bin
```

### For Windows

Download the `kubectl-pgo-windows-386` file from the [GitHub Releases Page](https://github.com/CrunchyData/pgo/releases/tag/v0.3.0) and add it to your system's PATH.

## Verification

To verify the installation, you can run the following command:

```bash
kubectl pgo version

```

This should display the current version of the PGO CLI, which should be `v0.3.0`.

## Conclusion

You have successfully downloaded and installed version 0.3.0 of the `pgo` kubectl plugin. For more information on how to use the plugin, refer to the official `pgo CLI` and `CPK` documentation.

Note: Replace the '#' in the Additional Resources section with the actual URLs to the pgo CLI and CPK documentation.

## Commands

while installing the PGO client you can also access the backup and restore through the CLI.

### Backup

### Backup Command

### Backup Command for insait with Azure

```bash
kubectl pgo backup insait-azure --repoName repo1 -n postgres-operator

```

### Restore Using PITR

### Restore Command for insait with Azure

```bash
kubectl pgo restore insait-azure --repoName repo1 --options '--type=time' --options '--target="2023-10-31 13:34:02"' -n postgres-operator

```

### Show Backup History

```bash
kubectl pgo show backup insait-azure -n postgres-operator

```

## Monitoring

Grafana monitoring

### monitoring Command

```bash
kubectl -n postgres-operator port-forward service/crunchy-grafana 3000:3000

```
