# GITHUB ACTIONS AZURE

1. <https://github.com/features/actions>.
1. Sign-in + 2FA.
1. Create a new repository: <https://github.com/new>.
1. Click on `Actions` tab.
1. Click `Set up a workflow yourself`.
1. Edit `.github/workflows/main.yml`.
1. Click `Start commit`.
1. Click `Commit new file`.
1. Click `Actions` tab.
1. Click workflow name (`CI`).
1. Click `Settings` tab.
1. Click `Secrets` on the left.
1. Click `Add a new secret`.
1. Type `Name:`, Type `Value:`
1. Open <https://portal.azure.com>
1. Create a new `Resource Group` called `200200-actions`.
1. Open `Cloud Shell`.
1. Paste the following snippet:
    ```bash
    RESOURCE_GROUP='200200-actions'
    LOCATION='eastus'
    SUBSCRIPTION_ID=$(az account show | jq -r .id)

    az group create -n $RESOURCE_GROUP -l $LOCATION

    SP=$(az ad sp create-for-rbac --sdk-auth -n $RESOURCE_GROUP --role contributor \
        --scopes "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}")
    echo $SP | jq -c
    ```
1. Copy the `Service Principal` (JSON) to the clipboard.
1. Open the `Resource Group` and click `Access control (IAM)`.
1. Click `Add` > `Add role assignment`.
1. Type `Role: Contributor`. 
1. Select: `200200-github`.
1. Click `Save`.
1. Open GitHub repo Secrets. Add a secret named `AZURE_CREDENTIALS`.
1. Paste `Service Principal` (JSON) into `Value:`.
1. Click `Add Secret`.
1. Open <https://github.com/Azure/actions>.
1. Copy the following snippet:
    ```yaml
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    ```
1. Open respository and Edit `.github/workflows/main.yml`.
1. Paste the above snippet.
1. Add snippet:
    ```yaml
    - name: az group show
      env:
        RESOURCE_GROUP: 200200-actions
      run: |
        az group show --name $RESOURCE_GROUP
    ```
1. Commit changes.
1. Click on `Actions`.
1. Click on Workflow (`CI`).
1. Click on Step (`az group show`).
1. Fork repo and add a new `Secret` (as above).
