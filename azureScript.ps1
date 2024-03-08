Connect-AzAccount

$context = Get-AzSubscription -SubscriptionName PAYG-Sandboxes

Set-AzContext $context


Set-AzDefault -ResourceGroupName rg_sb_eastus_89803_1_170993436984  ##change resourse group name

$githubOrganizationName = 'nenad0707'

$githubRepositoryName = 'toy-reusable'

$applicationRegistration = New-AzADApplication -DisplayName 'toy-reusable'
New-AzADAppFederatedCredential `
  -Name 'toy-reusable-branch' `
  -ApplicationObjectId $applicationRegistration.Id `
  -Issuer 'https://token.actions.githubusercontent.com' `
  -Audience 'api://AzureADTokenExchange' `
  -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

$resourceGroup = Get-AzResourceGroup -Name rg_sb_eastus_89803_1_170993436984

New-AzADServicePrincipal -AppId $applicationRegistration.AppId
New-AzRoleAssignment `
  -ApplicationId $applicationRegistration.AppId `
  -RoleDefinitionName Contributor `
  -Scope $resourceGroup.ResourceId

$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"   ## write these secrets to github secrets

