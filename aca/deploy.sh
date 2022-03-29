RESOURCE_GROUP="dapr-bigpicture-aca"

az group create --name $RESOURCE_GROUP --location westeurope

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ./main.bicep