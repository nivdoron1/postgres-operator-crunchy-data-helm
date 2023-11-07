---

## Preparation

1. **Change Directory to postgres-operator**
Navigate to the `postgres-operator` directory in your terminal.
    
    ```bash
    cd postgres-operator
    
    ```
    
2. **Set App Label**
Choose the app label corresponding to the cluster you are working on.
    
    ```bash
    # Option 1
    export APPLABEL=app-deployment
    
    ```
    
3. **Set Namespace**
Specify the namespace of your cluster.
    
    ```bash
    export NAMESPACE="postgres-operator"
    
    ```
    
4. **Set Azure Container Name**
Specify the name of your Azure container.
    
    ```bash
    export AZURE_CONTAINER_NAME="infra-deployment-staging-backup"
    
    ```


5. **Add your app-deployment image**
Specify the name of your app-deployment image.

    ```bash
    export APP_IMAGE= <your-app-image>

    ```
    
6. **Configure Azure Account**
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

This document outlines the necessary steps to set up the Postgres Operator and perform a data transfer, including initial configuration and installation, data transfer steps, and how to retrieve the database password for data verification purposes.

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
