#!/bin/bash

# Define variables

# Dump all data (including all databases) from source pod
kubectl exec -n $NAMESPACE $SRC_POD_ID -- pg_dumpall -U postgres -f /tmp/alldata_dump.sql

sleep 20

# Copy the data dump file from the source pod to the local machine
kubectl cp $NAMESPACE/$SRC_POD_ID:/tmp/alldata_dump.sql ./alldata_dump.sql

sleep 20

# Copy the data dump file from the local machine to the destination pod
kubectl cp ./alldata_dump.sql $NAMESPACE/$DST_POD_ID:/tmp/alldata_dump.sql -c $CONTAINER_NAME

sleep 20

# Load all data into destination pod
kubectl exec -n $NAMESPACE $DST_POD_ID -c $CONTAINER_NAME -- psql -U postgres -f /tmp/alldata_dump.sql

sleep 20

# Cleanup
rm ./alldata_dump.sql
kubectl exec -n $NAMESPACE $SRC_POD_ID  -- rm /tmp/alldata_dump.sql
kubectl exec -n $NAMESPACE $DST_POD_ID -c $CONTAINER_NAME -- rm /tmp/alldata_dump.sql


# get permission to the users
sed -i '/^#users:/s/^#//' helm/postgres/values.yaml
sed -i '/^#  - name: postgres/s/^#//' helm/postgres/values.yaml
sed -i '/^#  - name: insait-azure/s/^#//' helm/postgres/values.yaml
sed -i '/^#    options: "SUPERUSER"/s/^#//' helm/postgres/values.yaml
helm upgrade postgres-operator -n $NAMESPACE helm/postgres
