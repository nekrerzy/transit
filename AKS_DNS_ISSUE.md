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
- **VNet**: `vnet-bain-dev-incp-uaen-001` (172.20.160.0/24) in `rg-bain-dev-incp-uaen-001`
- **Hub peering**: Connected to `vnet-ihub-prd-incp-uaen` for centralized services
- **Custom DNS server**: `172.20.1.132` configured for all DNS resolution
- **Default route**: Traffic routed through Azure Firewall at `172.20.0.4`
- **Private endpoints**: 9 successfully deployed in SNET-PE (172.20.160.128/25)
- **AKS subnet**: SNET-AKS (172.20.160.0/25) ready for deployment
- **AKS requires**: specific DNS resolution for private API server endpoints

## Technical Requirements for Network Team

### 1. CONFIRMED: Use Existing Private DNS Zone (per Mohamed Soliman)
**IMPORTANT UPDATE**: Mohamed confirmed we should use the existing Private DNS Zone:
- **Zone**: `privatelink.uaenorth.azmk8s.io` (already exists)
- **Status**: Not a custom zone (managed by Azure/organization)
- **Action**: Use this existing zone instead of creating new one

### 2. DNS Forwarder Configuration  
Configure DNS forwarders in the hub DNS server (`172.20.1.132`) for:
- `*.privatelink.uaenorth.azmk8s.io` → Forward to Azure DNS (168.63.129.16)
- `*.uaenorth.azmk8s.io` → Forward to Azure DNS (168.63.129.16)
- `*.privatelink.*.azmk8s.io` → Forward to Azure DNS (168.63.129.16) (wildcard for all regions)

### 3. DNS Server Configuration
Update custom DNS servers in hub to:
- Forward AKS-related queries to Azure DNS
- Maintain existing DNS forwarding for other services
- Ensure conditional forwarding rules are prioritized correctly

### 4. Network Connectivity Verification
Verify that:
- AKS subnet (SNET-AKS: 172.20.160.0/25) can reach hub DNS server (172.20.1.132)
- Hub DNS server (172.20.1.132) can reach Azure DNS (168.63.129.16)
- DNS resolution works from AKS subnet to `*.azmk8s.io` domains
- Route table `rt-bain-dev-incp-uaen-001` properly routes AKS traffic through hub firewall
- NSG `nsg-bain-dev-incp-uaen-001` allows DNS traffic (port 53) between subnets

## Attempted Solutions
1. **`private_dns_zone_id = "System"`** → DNS lookup failure
2. **`private_dns_zone_id = "None"`** → Requires public FQDN (violates security policies)
3. **Auto-managed DNS zones** → Still DNS lookup failure
4. **Azure Firewall FQDN tags** → Resolves outbound connectivity but not DNS resolution

## Working Infrastructure
The following services deploy successfully with private endpoints in SNET-PE (172.20.160.128/25):
- ✅ Azure Storage (3x accounts: general, ragdata, logs)
- ✅ PostgreSQL Flexible Server (with delegated subnet)
- ✅ Redis Cache
- ✅ Azure Search
- ✅ Key Vault (3x instances: app, ai, cert)
- ✅ Azure Container Registry
- ❌ AKS (DNS resolution blocked for private API server)

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

## Network Infrastructure Analysis

### Current VNet Configuration
```json
{
  "name": "vnet-bain-dev-incp-uaen-001",
  "addressSpace": "172.20.160.0/24",
  "location": "UAE North",
  "dnsServers": ["172.20.1.132"],
  "resourceGroup": "rg-bain-dev-incp-uaen-001"
}
```

### Subnet Configuration
| Subnet | CIDR | Purpose | Status |
|--------|------|---------|--------|
| SNET-PE | 172.20.160.128/25 | Private Endpoints | ✅ 9 PEs deployed |
| SNET-AKS | 172.20.160.0/25 | AKS Node Pools | ⚠️ Ready for deployment |

### Hub-and-Spoke Connectivity
- **Hub VNet**: `vnet-ihub-prd-incp-uaen` (peering active)
- **DNS Server**: `172.20.1.132` (centralized in hub)
- **Default Gateway**: `172.20.0.4` (Azure Firewall in hub)
- **Route Table**: `rt-bain-dev-incp-uaen-001` (0.0.0.0/0 → 172.20.0.4)

### Existing Private Endpoints (Working)
All 9 private endpoints successfully resolve DNS through the hub architecture:
- Storage accounts (3x), PostgreSQL, Redis, Search, Key Vaults (3x), ACR

### DNS Resolution Chain
**Current (Working)**: App → SNET-PE → Hub DNS (172.20.1.132) → Azure DNS (168.63.129.16)
**AKS (Failing)**: AKS Nodes → SNET-AKS → Hub DNS (172.20.1.132) → ❌ No forwarder for `*.azmk8s.io`

## Next Steps
1. **UPDATED**: Use existing Private DNS Zone `privatelink.uaenorth.azmk8s.io` per Mohamed
2. **Network Team**: Configure DNS forwarders for AKS domains on `172.20.1.132`
3. **Testing**: Verify DNS resolution from AKS subnet (172.20.160.0/25)  
4. **Deployment**: Re-enable AKS module after DNS forwarders configured
5. **Validation**: Test complete container platform deployment

## Terraform Configuration Updated
- **AKS module**: Now uses existing Private DNS Zone ID
- **Variable**: `aks_private_dns_zone_id` updated with correct resource ID
- **Ready**: AKS deployment ready once DNS forwarders configured

---
*This issue is infrastructure-level and requires network team intervention rather than Terraform configuration changes.*