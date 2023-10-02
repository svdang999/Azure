## Create SP with 100 years lifetime

```
https://stackoverflow.com/questions/74527037/azure-cli-how-to-create-a-new-client-secret-with-a-specific-description
```

```
az login
az account set --subscription "Dev_Test"
az ad app credential list --id <ApplicationID>
az ad app credential reset --id <ApplicationID> --display-name <Enter description here> --append --years 99
```

## Example
```
az ad app credential reset --id 99629ba2-ea49-4251-8265-0db135fccdd8 --display-name rbac100years --append
son [ ~ ]$ az ad app credential reset --id 99629ba2-ea49-4251-8265-0db135fccdd8 --display-name rbac100years --append --years 99
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "99629ba2-ea49-4251-8265-0db135fccdd8",
  "password": "xxx",
  "tenant": "c8482830-6d15-4014-a427-xxx"
}
```
