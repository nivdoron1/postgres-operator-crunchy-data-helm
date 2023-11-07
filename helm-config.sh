#!/bin/bash
kubectl create namespace $NAMESPACE
# Choose your app-label before the bash file

# Path to the Helm chart directory
CHART_DIR="helm/postgres"

# Full path to the .helmignore file
HELMIGNORE_FILE="$CHART_DIR/.helmignore"

# Add the image to the app-deployment
sed -i '/appDeployment:/!b;n;s|image: .*|image: '"${APP_IMAGE}"'|' helm/postgres/values.yaml

# Clear any existing .helmignore file
echo "" > $HELMIGNORE_FILE

# Add all the files to the .helmignore file
echo "templates/app-deployment.yaml" >> $HELMIGNORE_FILE
# Remove the chosen app-label file from the .helmignore file
if [[ $APPLABEL == "app-deployment" ]]; then
    sed -i '/templates\/app-deployment.yaml/d' $HELMIGNORE_FILE
fi

sed -i "s/^namespace: .*/namespace: $NAMESPACE/" helm/azure-secret-creds/kustomization.yaml
sed -i "s/^namespace: .*/namespace: $NAMESPACE/" helm/postgres/values.yaml
sed -i "s/namespace: .*/namespace: $NAMESPACE/g" helm/postgres/templates/app-deployment.yaml

kubectl apply --namespace=$NAMESPACE -k azure-secret-creds

sed -i "/container:/c\      container: \"${AZURE_CONTAINER_NAME}\"" helm/postgres/values.yaml

