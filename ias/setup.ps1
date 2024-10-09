$GROUP = "rg-aks-fis"
$CLUSTER = "fisaks"
$ACR = "binarydad"
$VNET = "vnet"
$SUBNET_AKS = "aks"
$SUBNET_VMS = "vms"
$VM = "webserver"
$VM_IP = "vm-ip"
$VM_NIC = "vm-nic"
$VM_NSG = "vm-nsg"
$AKS_NSG = "aks-nsg"

# create the group
az group create -n $GROUP -l eastus2

# create the vnet and subnets
az network vnet create -n $VNET -g $GROUP --address-prefixes 10.0.0.0/16
$AKS_SUBNET_ID = az network vnet subnet create -n $SUBNET_AKS --vnet-name $VNET -g $GROUP --address-prefixes 10.0.1.0/24 --query id -o tsv
$VM_SUBNET_ID = az network vnet subnet create -n $SUBNET_VMS --vnet-name $VNET -g $GROUP --address-prefixes 10.0.2.0/24 --query id -o tsv

# create NSGs, add rules, and assign to subnets
az network nsg create -n $VM_NSG -g $GROUP
az network nsg create -n $AKS_NSG -g $GROUP
az network nsg rule create --nsg-name $VM_NSG -n AllowRdp --destination-port-ranges 3389 --priority 100 -g $GROUP
az network nsg rule create --nsg-name $AKS_NSG -n AllowWeb --destination-port-ranges 80 443 --priority 101 -g $GROUP
az network vnet subnet update --vnet-name $VNET -n $SUBNET_VMS -g $GROUP --network-security-group $VM_NSG
az network vnet subnet update --vnet-name $VNET -n $SUBNET_AKS -g $GROUP --network-security-group $AKS_NSG

# create cluster with workload identity and secrets provider add-on
az aks create -n $CLUSTER -c 1 -g $GROUP `
    --vnet-subnet-id $AKS_SUBNET_ID `
    --service-cidr 10.0.10.0/24 `
    --network-plugin azure `
    --dns-service-ip 10.0.10.3 `
    --attach-acr $ACR

# get credentials
az aks get-credentials -g $GROUP -n $CLUSTER

# create the public IP, NIC, and VM
$VM_IP_ADDRESS = az network public-ip create -n $VM_IP -g $GROUP --allocation-method Static --query publicIp.ipAddress -o tsv
az network nic create -g $GROUP -n $VM_NIC --vnet-name $VNET --subnet $VM_SUBNET_ID --public-ip-address $VM_IP
az vm create -n $VM -g $GROUP --nics $VM_NIC --image Win2022Datacenter --assign-identity --authentication-type Password --admin-username ryan

# get the private IP for VM
$VM_IP_ADDRESS_PRIVATE = az vm show -n $VM -g $GROUP -d -o tsv --query privateIps

# install SMB CSI driver
# SOURCE: https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-smb
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts   
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.13.0 --set windows.enabled=true

# dumps
"VM IP address (public): $($VM_IP_ADDRESS)"
"VM IP address (private): $($VM_IP_ADDRESS_PRIVATE)"