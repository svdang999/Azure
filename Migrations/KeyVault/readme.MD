Remember to check if the secret names **follow the pattern,** for example paypense-database-user, to avoid conflicts in the future.

Make sure you have permission to create/view keyvaults

The primary code formula we use for adding a secret to keyvault is:
```
az keyvault secret set --vault-name akv-dev-test --name ahoangtest --value 123456 `
```
Since we will migrate from akv-ntc-test to **existing keyvault** akv-dev-test, we 
won't use Terraform to provision resources. The following code runs on Powershell with az cli

**Export all secrets from source keyvault**


```
# Log in to the source tenant

$source_tenant_id=""
$source_sub_id="5ea488d9-2175-4b0b-a192-aa43b29dcdd4"
$source_kv_name="akv-ntc-test"

$dest_tenant_id=""
$dest_sub_id=""
$dest_kv_name="akv-dev-test"

az login --tenant $source_tenant_id

# Set the subscription context
az account set --subscription $source_sub_id

# Get the list of secrets
$secrets=(az keyvault secret list --vault-name $source_kv_name --query "[].id" -o tsv)

# Export secrets to local files
foreach ($secret_id in $secrets) {
    $secret_name = ($secret_id -split "/")[-1]
    $secret_value = az keyvault secret show --id $secret_id --query "value" -o tsv
    $secret_value | Out-File -FilePath "$secret_name.txt" -Encoding utf8
}
```
**Set secret to destination keyvault**


```
# Log in to the destination tenant
az login --tenant <dest_tenant_id>

# Set the subscription context
az account set --subscription <dest_sub_id>

# Get the list of all .txt files in the current directory
$secret_files = Get-ChildItem -Filter *.txt

# Import the secrets from the files
foreach ($secret_file in $secret_files) {
    $secret_name = $secret_file.BaseName  # Get the file name without the extension
    $secret_value = Get-Content -Path $secret_file.FullName  # Read the content of the file
    az keyvault secret set --vault-name <dest_kv_name> --name $secret_name --value $secret_value
}
```
