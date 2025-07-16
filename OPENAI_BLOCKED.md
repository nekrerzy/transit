# Azure OpenAI Blocked by Network Security Perimeter

## Original Error
```
Error: creating Account (Subscription: "b65e6929-28d1-4b59-88f3-570a0df91662"
Resource Group Name: "rg-bain-app-dev-incp-uaen-002"
Account Name: "oai-bain-app-dev-incp-uaen-002"): unexpected status 401 (401 Unauthorized) with error: NetworkSecurityPerimeterTrafficDenied: The outbound request to target resource is denied by NetworkSecurityPerimeter.

with module.openai.azurerm_cognitive_account.openai,
on modules/openai/main.tf line 2, in resource "azurerm_cognitive_account" "openai":
2: resource "azurerm_cognitive_account" "openai" {
```

## Problem Summary
Azure OpenAI deployment fails with `NetworkSecurityPerimeterTrafficDenied` error due to Network Security Perimeter restrictions blocking cognitive services API calls during resource creation.

## Root Cause
- Network Security Perimeter blocks the **deployment API calls** from jumpbox to Azure
- This happens during creation, before the service exists
- Not related to the service's own outbound traffic settings

## The `outbound_network_access_restricted = true` Setting
- This setting is **required by Azure Policy** for compliance
- It configures the service's outbound traffic **after** it's created
- It does **NOT** fix the NSP blocking issue
- It's needed for when/if the service gets deployed

## Resolution Required
- Security team needs to allow cognitive services API calls through NSP, OR
- Deploy OpenAI through different process/location with NSP permissions

## Current Status
- OpenAI module commented out in main.tf
- All other services deploy successfully
- OpenAI code ready for when NSP restrictions are resolved

---
*The outbound restriction setting is correct and required - the blocking happens at network level during deployment*