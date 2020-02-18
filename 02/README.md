# README

## subscription
```bash
# az login
SUBSCRIPTION='ca-aawislan-demo-test'
az account set --subscription $SUBSCRIPTION
az account show
```

## variables
```bash
# variables
RESOURCE_GROUP='200200-hello-azure'
LOCATION='eastus'
# RANDOM_STR='0dd2f6'
[[ -z "$RANDOM_STR" ]] && RANDOM_STR=$(openssl rand -hex 3)
STORAGE_ACCOUNT="storage2002${RANDOM_STR}"
STORAGE_CONTAINER='container1'
SQL_SERVER_NAME="sql2002${RANDOM_STR}"
SQL_DB_NAME='db1'
SQL_USER='username'
SQL_PASSWORD=$(openssl rand -hex 12)'A1!'
COSMOS_NAME="cosmos2002${RANDOM_STR}"
APPSERVICE_NAME="appservice200200"
REGISTRY_NAME="acr${RANDOM_STR}"
WEBAPP_NAME="web${RANDOM_STR}"
```

## resource group
```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

## storage
```bash
az storage account create -g $RESOURCE_GROUP -l $LOCATION \
    -n $STORAGE_ACCOUNT \
    --kind StorageV2 \
    --sku Standard_LRS

export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | jq -r .connectionString)

az storage container create -n $STORAGE_CONTAINER --public-access container

mkdir -p container1 && cd container1/
for n in {1..100}; do
    dd if=/dev/urandom of=file$( printf %03d "$n" ).bin bs=1 count=$(( RANDOM + 1024 ))
done
az storage blob upload-batch --source . --destination $STORAGE_CONTAINER
# az storage blob list -c $STORAGE_CONTAINER | jq '.[].name'
# az storage blob delete-batch --source $STORAGE_CONTAINER

ACCOUNT_BLOB_URL=$(az storage account show  --name $STORAGE_ACCOUNT | jq -r '.primaryEndpoints.blob')
CONTAINER_URL="${ACCOUNT_BLOB_URL}${STORAGE_CONTAINER}"
```

## storage - static website & sas url
```bash
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --404-document error.html \
    --index-document index.html

# update: AZURE_STORAGE_CONTAINER_URL (if required) and AZURE_STORAGE_SAS_TOKEN
AZURE_STORAGE_CONTAINER_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}/"

AZURE_STORAGE_SAS_TOKEN=$(az storage container generate-sas --account-name $STORAGE_ACCOUNT -n $STORAGE_CONTAINER --permissions rwdl --expiry '2022-01-01T00:00:00Z' | jq -r .)

CONTAINER_URL="${AZURE_STORAGE_CONTAINER_URL}?${AZURE_STORAGE_SAS_TOKEN}"

WEB_ENDPOINT=$(az storage account show -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT | jq -r .primaryEndpoints.web)

echo "CONTAINER_URL: $CONTAINER_URL"
echo "WEB_ENDPOINT: $WEB_ENDPOINT"
```

## storage - azcopy
```bash
# sync into subdirectory
azcopy sync . "${AZURE_STORAGE_CONTAINER_URL}subdir/?${AZURE_STORAGE_SAS_TOKEN}"

# sync with --delete-destination=true
azcopy sync . $CONTAINER_URL --delete-destination=true 

azcopy ls $CONTAINER_URL

# --recursive handles subdirectories
azcopy rm $CONTAINER_URL --recursive=true
```

## cosmos db
```bash
az cosmosdb create --name $COSMOS_NAME --resource-group $RESOURCE_GROUP --kind MongoDB

# COSMOS_CONNECTION_STRING=$(az cosmosdb list-connection-strings --name $COSMOS_NAME --resource-group $RESOURCE_GROUP --query 'connectionStrings[0].connectionString' -o tsv)
# echo $COSMOS_CONNECTION_STRING
```

## azure sql
```bash
az sql server create --resource-group $RESOURCE_GROUP --location $LOCATION --name $SQL_SERVER_NAME --admin-user $SQL_USER --admin-password $SQL_PASSWORD

az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name azure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name $SQL_DB_NAME --family Gen4 --capacity 1

# (optional) delete database
# az sql db delete --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name $SQL_DB_NAME

# (optional) output connection strings
# SQL_CONNECTION_STRING=$(az sql db show-connection-string --server $SQL_SERVER_NAME --name $SQL_DB_NAME -c ado.net -o tsv)
# echo $SQL_CONNECTION_STRING
```

## container registry
```bash
# create registry
az acr create -g $RESOURCE_GROUP -l $LOCATION --name $REGISTRY_NAME --sku Basic --admin-enabled

# build image
cd ../1-1/golang-web/
IMAGE_NAME='golang-web:v1'
az acr build --registry $REGISTRY_NAME --image $IMAGE_NAME .
```

## app service plan
```bash
az appservice plan create -g $RESOURCE_GROUP --name $APPSERVICE_NAME --sku B1 --is-linux
```

## web app for containers
```bash
# nginx
az webapp create -g $RESOURCE_GROUP --plan $APPSERVICE_NAME -n $WEBAPP_NAME \
    --deployment-container-image-name nginx

# deploy container
REGISTRY_PASSWORD=$(az acr credential show -n $REGISTRY_NAME | jq -r .passwords[0].value)
az webapp config container set -g $RESOURCE_GROUP -n $WEBAPP_NAME \
    --docker-registry-server-url "https://${REGISTRY_NAME}.azurecr.io/" \
    --docker-registry-server-user $REGISTRY_NAME \
    --docker-registry-server-password $PASSWORD \
    --docker-custom-image-name "${REGISTRY_NAME}.azurecr.io/${IMAGE_NAME}"

az webapp config container set -g $RESOURCE_GROUP -n $WEBAPP_NAME \
   --docker-custom-image-name nginx

az webapp log tail -g $RESOURCE_GROUP -n $WEBAPP_NAME
```

## web app settings
```bash
# sql server
# we can't change the admin user, but if we don't know it, we can get it
SQL_USER=$(az sql server show --resource-group $RESOURCE_GROUP --name $SQL_SERVER_NAME | jq -r '.administratorLogin')
# let's generate a new password
SQL_PASSWORD=$(openssl rand -hex 12)'A1!'
# set the new password
az sql server update --resource-group $RESOURCE_GROUP --name $SQL_SERVER_NAME --admin-password $SQL_PASSWORD
# get the connection string and sed the values into it
SQL_CONNECTION_STRING=$(az sql db show-connection-string --server $SQL_SERVER_NAME --name $SQL_DB_NAME -c ado.net | jq -r . | sed 's/<username>/'$SQL_USER'/' | sed 's/<password>/'$SQL_PASSWORD'/')
# (optional) output the connection string
# echo $SQL_CONNECTION_STRING

# cosmos db
COSMOS_CONNECTION_STRING=$(az cosmosdb list-connection-strings --resource-group $RESOURCE_GROUP --name $COSMOS_NAME | jq -r '.connectionStrings[0].connectionString')
# (optional) output the connection string
# echo $COSMOS_CONNECTION_STRING

# set appsettings
az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --settings \
    MongoConnectionString=$COSMOS_CONNECTION_STRING \
    SqlConnectionString=$SQL_CONNECTION_STRING

APP_HOSTNAME=$(az webapp show -g $RESOURCE_GROUP -n $APP_NAME | jq -r .defaultHostName)
echo "https://${APP_HOSTNAME}"
```

## arm template
```bash
az group deployment create --resource-group $RESOURCE_GROUP \
    --template-uri https://raw.githubusercontent.com/asw101/cloud-snips/master/arm/empty/empty.json \
    --mode 'Complete'
```

## service principal - basic
```bash
SUBSCRIPTION_ID=$(az account show | jq -r .id)
RESOURCE_GROUP='200200-actions'
LOCATION='eastus'

az group create -n $RESOURCE_GROUP -l $LOCATION

SP=$(az ad sp create-for-rbac -n $RESOURCE_GROUP --role contributor \
    --scopes "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}")
echo $SP
```

## service principal - advanced
```bash
SUBSCRIPTION_ID=$(az account show | jq -r .id)
RESOURCE_GROUP='200200-actions'
LOCATION='eastus'
SP_NAME=$RESOURCE_GROUP

# create service principal
SP=$(az ad sp create-for-rbac --skip-assignment --sdk-auth -n "http://${SP_NAME}")
SP_ID=$(echo $SP | jq -r .clientId)
az ad app update --id $SP_ID --set displayName=$SP_NAME

# create resource group
az group create -n $RESOURCE_GROUP -l $LOCATION
# assign contributor role to service principal at resource group scope
az role assignment create --assignee $SP_ID --role Contributor \
    --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

# (optional) output service principal
# echo $SP

# (optional) persist to file
# cd 
# mkdir -p _/ && echo $SP > _/sp-${SP_NAME}.json

# (optional) load from file
# SP=$(cat _/sp-${SP_NAME}.json)

# (optional) delete
# az ad sp delete --id $SP_ID
```

## service principal - bash variables

```bash
# set variables
# RESOURCE_GROUP='200200-actions'
# SP=$(cat "_/sp-${RESOURCE_GROUP}.json")
SP_CLIENT_ID=$(echo $SP | jq -r .clientId)
SP_CLIENT_SECRET=$(echo $SP | jq -r .clientSecret)
SP_TENANT_ID=$(echo $SP | jq -r .tenantId)
# check variables
[[ -z "$RESOURCE_GROUP" ]] && echo 'RESOURCE_GROUP not set!'
[[ -z "$SP" ]] && echo 'SP not set!'
[[ -z "$SP_CLIENT_ID" ]] && echo 'SP_CLIENT_ID not set!'
[[ -z "$SP_CLIENT_SECRET" ]] && echo 'SP_CLIENT_SECRET not set!'
[[ -z "$SP_TENANT_ID" ]] && echo 'SP_TENANT_ID not set!'
```

## Resources
See: [RESOURCES.md](../RESOURCES.md#storage)
