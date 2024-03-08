param(
  [string]$SubscriptionName = "PAYG-Sandboxes",

  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,

  [string]$GitHubOrganizationName = "nenad0707",
  [string]$GitHubRepositoryName = "toy-reusable",
  [string]$DisplayName = "toy-reusable"
)

# Connecting to Azure account
Connect-AzAccount

# Selecting Azure subscription
$context = Get-AzSubscription -SubscriptionName $SubscriptionName
Set-AzContext $context

# Registering a new Azure AD application
$applicationRegistration = New-AzADApplication -DisplayName $DisplayName
Write-Host "Azure AD Application created with ID: $($applicationRegistration.AppId)"

# Adding federated credential to the application
New-AzADAppFederatedCredential -Name "$DisplayName-branch" `
  -ApplicationObjectId $applicationRegistration.Id `
  -Issuer 'https://token.actions.githubusercontent.com' `
  -Audience 'api://AzureADTokenExchange' `
  -Subject "repo:$GitHubOrganizationName/$GitHubRepositoryName:ref:refs/heads/main" `

Write-Host "Federated Credential added to the application"

# Getting the Resource Group
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

# # Creating a Service Principal for the Azure AD application
New-AzADServicePrincipal -AppId $applicationRegistration.AppId

# Assigning a role to the application
New-AzRoleAssignment `
  -ApplicationId $applicationRegistration.AppId `
  -RoleDefinitionName Contributor `
  -Scope $resourceGroup.ResourceId

Write-Host "Role 'Contributor' assigned to the application within the resource group scope"

# Displaying important information
$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"