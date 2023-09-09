# Script to check client's secret expiration date

#1. Login to Azure using Service Principal
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
$azureAplicationId = 'xxx-xxx-xxx-xxx-xxx' #spp
$azureTenantId = 'c8482830-6d15-4014-a427-155b23c5cdcd' #Itelya Tenant
$azurePassword = ConvertTo-SecureString $env:spappsecret -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword) 

Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal

$context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
$aadToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.windows.net").AccessToken

Connect-AzureAD -AadAccessToken $aadToken -AccountId $context.Account.Id -TenantId $context.tenant.id


#2 Set secret expiration date filter (45 days)
$LimitExpirationDays = 45

#3 Retrieving the list of secrets that expires in the above range of days
$SecretsToExpire = Get-AzureADApplication -All:$true | ForEach-Object {
    $app = $_
    @(
        Get-AzureADApplicationPasswordCredential -ObjectId $_.ObjectId
        Get-AzureADApplicationKeyCredential -ObjectId $_.ObjectId
    ) | Where-Object {
        $_.EndDate -lt (Get-Date).AddDays($LimitExpirationDays)
    } | ForEach-Object {
        $id = "Not set"
        if($_.CustomKeyIdentifier) {
            $id = [System.Text.Encoding]::UTF8.GetString($_.CustomKeyIdentifier)
        }
        [PSCustomObject] @{
            App = $app.DisplayName
            ObjectID = $app.ObjectId
            AppId = $app.AppId
            Type = $_.GetType().name
            KeyIdentifier = $id
            EndDate = $_.EndDate
        }
    }
}


#4 Printing the list of secrets that are near to expire
if($SecretsToExpire.Count -EQ 0) {
    Write-Output "No secrets found that will expire in this range"
}
else {
    Write-Output "Secrets that will expire in this range:"
    Write-Output $SecretsToExpire.Count
    Write-Output $SecretsToExpire
}
