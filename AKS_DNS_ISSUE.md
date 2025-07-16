# AKS DNS Resolution Issue in Hub-and-Spoke Architecture

## Problem Description
AKS private cluster deployment fails with `VMExtensionError_K8SAPIServerDNSLookupFail` in hub-and-spoke network architecture with custom DNS servers.

## Error Details
```
Status: "VMExtensionProvisioningError"
Code: ""
Message: "CSE failed with 'VMExtensionError_K8SAPIServerDNSLookupFail', which means agents are unable to resolve Kubernetes API server name. It's likely custom DNS server is not correctly configured"
```

## Root Cause
The AKS nodes cannot resolve the Kubernetes API server's private DNS name because:
1. **Custom DNS servers** in hub-and-spoke architecture don't have forwarders configured for AKS private link zones
2. **Private DNS zones** for AKS (*.privatelink.*.azmk8s.io) are not integrated with the hub DNS infrastructure
3. **DNS resolution chain** from spoke → hub → Azure DNS is broken for AKS-specific domains

## Network Architecture Context
- **Hub-and-spoke topology** with centralized DNS servers
- **Custom DNS servers** in hub handle all DNS resolution
- **Private endpoints** for other services (storage, Key Vault, etc.) work correctly
- **AKS requires** specific DNS resolution for private API server endpoints

## Technical Requirements for Network Team

### 1. DNS Forwarder Configuration
Configure DNS forwarders in the hub DNS servers for:
- `*.privatelink.*.azmk8s.io` → Forward to Azure DNS (168.63.129.16)
- `*.azmk8s.io` → Forward to Azure DNS (168.63.129.16)

### 2. Private DNS Zone Integration
Create private DNS zones in hub resource group:
- `privatelink.uaenorth.azmk8s.io` (for UAE North region)
- Link to hub virtual network for DNS resolution

### 3. DNS Server Configuration
Update custom DNS servers in hub to:
- Forward AKS-related queries to Azure DNS
- Maintain existing DNS forwarding for other services
- Ensure conditional forwarding rules are prioritized correctly

### 4. Network Connectivity Verification
Verify that:
- AKS subnet (SNET-AKS) can reach hub DNS servers
- Hub DNS servers can reach Azure DNS (168.63.129.16)
- DNS resolution works from AKS subnet to `*.azmk8s.io` domains

## Attempted Solutions
1. **`private_dns_zone_id = "System"`** → DNS lookup failure
2. **`private_dns_zone_id = "None"`** → Requires public FQDN (violates security policies)
3. **Auto-managed DNS zones** → Still DNS lookup failure
4. **Azure Firewall FQDN tags** → Resolves outbound connectivity but not DNS resolution

## Working Infrastructure
The following services deploy successfully with private endpoints:
- ✅ Azure Storage (3x accounts)
- ✅ PostgreSQL Flexible Server
- ✅ Redis Cache
- ✅ Azure Search
- ✅ Key Vault (3x instances)
- ✅ Azure Container Registry
- ❌ AKS (DNS resolution blocked)

## Recommended Actions
1. **Network Team**: Configure DNS forwarders for AKS domains
2. **Security Team**: Verify DNS configuration doesn't violate policies
3. **Testing**: Deploy test AKS cluster after DNS configuration
4. **Documentation**: Update DNS architecture documentation

## Alternative Workarounds (Not Recommended)
- Enable public FQDN (violates security policies)
- Use system-managed DNS zones (doesn't work with custom DNS)
- Deploy AKS in different network architecture (architectural change)

## Impact
- AKS deployment blocked until DNS configuration is resolved
- Container workloads cannot be deployed
- DevOps pipeline integration delayed
- Application containerization roadmap affected

## Next Steps
1. Engage network team for DNS forwarder configuration
2. Test DNS resolution from AKS subnet
3. Re-enable AKS module after DNS fixes
4. Validate complete container platform deployment

---
*This issue is infrastructure-level and requires network team intervention rather than Terraform configuration changes.*