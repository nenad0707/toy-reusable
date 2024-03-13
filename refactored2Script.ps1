param(
  [string]$SubscriptionName = "PAYG-Sandboxes",
  [Parameter(Mandatory)]
  [string]$ResourceGroupName,
  [string]$GitHubOrganizationName = "nenad0707",
  [string]$GitHubRepositoryName = "toy-reusable",
  [string]$DisplayName = "toy-reusable"
)

function Connect-ToAzure {
  # Connecting to Azure account
  Connect-AzAccount

  # Selecting Azure subscription
  $context = Get-AzSubscription -SubscriptionName $SubscriptionName
  Set-AzContext $context
}

function Register-AzADApplication {
  # Registering a new Azure AD application and adding federated credential
  $applicationRegistration = New-AzADApplication -DisplayName $DisplayName
  Write-Host "Azure AD Application created with ID: $($applicationRegistration.AppId)"

  New-AzADAppFederatedCredential -Name "$DisplayName-branch" `
    -ApplicationObjectId $applicationRegistration.Id `
    -Issuer 'https://token.actions.githubusercontent.com' `
    -Audience 'api://AzureADTokenExchange' `
    -Subject "repo:$($GitHubOrganizationName)/$($GitHubRepositoryName):ref:refs/heads/main"
  Write-Host "Federated Credential added to the application"

  return $applicationRegistration
}

function 
New-ServicePrincipalAndAssignRole {
  param(
    [Parameter(Mandatory)]
    [string]$AppId,
    [string]$ResourceGroupName
  )

  # Creating a Service Principal for the Azure AD application
  New-AzADServicePrincipal -AppId $AppId

  # Getting the Resource Group
  $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

  # Assigning a role to the application
  New-AzRoleAssignment `
    -ApplicationId $AppId `
    -RoleDefinitionName Contributor `
    -Scope $resourceGroup.ResourceId
  Write-Host "Role 'Contributor' assigned to the application within the resource group scope"
}

function Get-AzureInfo {
  param(
    [Parameter(Mandatory)]
    [string]$AppId
  )

  $azureContext = Get-AzContext
  Write-Host "AZURE_CLIENT_ID: $AppId"
  Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
  Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"   ## write these secrets to GitHub secrets
}

# Main script execution
Connect-ToAzure
$applicationRegistration = Register-AzADApplication
New-ServicePrincipalAndAssignRole -AppId $applicationRegistration.AppId -ResourceGroupName $ResourceGroupName
Output-AzureInfo -AppId $applicationRegistration.AppId