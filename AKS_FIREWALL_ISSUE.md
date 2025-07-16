# AKS Deployment Issue - Azure Firewall Configuration Required

## Problem Summary
AKS cluster deployment fails with `VMExtensionError_OutBoundConnFail` error due to insufficient outbound connectivity through Azure Firewall in hub/spoke architecture.

## Original Error
```
Error: creating Kubernetes Cluster
Status: "VMExtensionProvisioningError"
Code: ""
Message: "CSE failed with 'VMExtensionError_OutBoundConnFail', which means the agents are unable to establish outbound connection, please see https://aka.ms/aks/vmextensionerror_outboundconnfail and https://aka.ms/aks-required-ports-and-addresses for more information."
```

## Current Network Configuration
- **Hub/Spoke Architecture**: Traffic routed through Azure Firewall at `172.20.0.4`
- **Outbound Type**: `userDefinedRouting` (correct for hub/spoke)
- **Route Table**: `rt-default-dev-incp-uaen-001` with default route `0.0.0.0/0` → `172.20.0.4`
- **Azure Firewall Policy**: `afwp-hub-prd-incp-uaen-001` (has AKS rule collections but incomplete)

## Root Cause
The Azure Firewall policy contains AKS-related rule collections but is missing critical configuration required for AKS node provisioning:

**Existing Rule Collections** (from firewall policy screenshot):
- ✅ `aks-core-services-collection`
- ✅ `aks-monitoring`
- ✅ `AKS-NodeProvisioning`
- ✅ `AKS-CSE-Requirements`
- ✅ `AKS-Bootstrap-Essential`
- ✅ `AKS-Essential-Apps`
- ✅ `AKS-Essential-Network`

**Missing Critical Configuration**:
1. **AzureKubernetesService FQDN Tag** in application rules
2. **DNS Proxy enabled** on Azure Firewall
3. **Required network rules** for DNS and service tags

## Required Azure Firewall Fixes

### 1. Application Rule with FQDN Tag (CRITICAL)
Create application rule with `AzureKubernetesService` FQDN tag:
```bash
az network firewall application-rule create \
  --resource-group rg-network-prd-incp-uaen-001 \
  --firewall-name afw-hub-prd-incp-uaen-001 \
  --collection-name 'aks-fqdn-collection' \
  --name 'aks-fqdn-rule' \
  --source-addresses '*' \
  --protocols 'http=80' 'https=443' \
  --fqdn-tags "AzureKubernetesService" \
  --action allow \
  --priority 100
```

### 2. Enable DNS Proxy
Enable DNS proxy on Azure Firewall for reliable FQDN filtering:
```bash
az network firewall update \
  --resource-group rg-network-prd-incp-uaen-001 \
  --name afw-hub-prd-incp-uaen-001 \
  --enable-dns-proxy true
```

### 3. Network Rules
Ensure network rules exist for:
- **DNS**: Traffic to Azure DNS `168.63.129.16:53` (TCP/UDP)
- **Time Sync**: Port `123` UDP
- **Service Tags**: `AzureContainerRegistry`, `MicrosoftContainerRegistry`, `AzureActiveDirectory`, `AzureMonitor`

## Testing Connectivity
Once firewall is configured, test from AKS subnet:
```bash
# Test Azure Container Registry
nc -vz mcr.microsoft.com 443
dig mcr.microsoft.com

# Test Azure DNS
nslookup mcr.microsoft.com 168.63.129.16
```

## Impact
- AKS cluster cannot be deployed in current configuration
- All other infrastructure (PostgreSQL, Redis, Storage, Search) deploys successfully
- Issue is specific to AKS outbound connectivity requirements

## Terraform Configuration Status
- All Azure Policy compliance issues resolved
- Network CIDR conflicts resolved  
- Authentication and encryption properly configured
- Ready for deployment once firewall is configured

## References
- [AKS Outbound Connectivity Requirements](https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress)
- [VMExtensionError_OutBoundConnFail Troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-outboundconnfail)
- [Azure Firewall for AKS](https://learn.microsoft.com/en-us/azure/firewall/protect-azure-kubernetes-service)

---
*Issue documented for network team resolution - AKS module temporarily commented out in main.tf*