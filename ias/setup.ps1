$GROUP = "rg-aks-fis-poc"
$CLUSTER = "fisaks"
$ACR = "binarydad"
$VNET = "vnet"
$SUBNET_AKS = "aks"
$SUBNET_VMS = "vms"
$VM = "test"
$VM_IP = "vm-ip"
$VM_NIC = "vm-nic"
$VM_NSG = "vm-nsg"
$VM_IDENTITY = "configuration" # identity used for accessing the VM
$AZURE_MANAGED_IDENTITY = "ryan-workload" # workload managed identity in Azure
$FEDERATED_NAME = "federated-workload-user" # id used for federated credential
$SERVICE_ACCOUNT_NAME = "cluster-workload-user" # kubernetes service account name
$NAMESPACE = "managedidentity" # kubernetes namespace of the service account

# create the group
#az group create -n $GROUP -l eastus2

# create the vnet and subnets
#az network vnet create -n $VNET -g $GROUP --address-prefixes 10.0.0.0/16
#$AKS_SUBNET_ID = az network vnet subnet create -n $SUBNET_AKS --vnet-name $VNET -g $GROUP --address-prefixes 10.0.1.0/24 --query id -o tsv
$VM_SUBNET_ID = az network vnet subnet create -n $SUBNET_VMS --vnet-name $VNET -g $GROUP --address-prefixes 10.0.2.0/24 --query id -o tsv

# create cluster with workload identity and secrets provider add-on
#az aks create -n $CLUSTER -c 1 -g $GROUP --vnet-subnet-id $AKS_SUBNET_ID --service-cidr 10.0.10.0/24 --network-plugin azure --dns-service-ip 10.0.10.3 --enable-oidc-issuer --enable-workload-identity --attach-acr $ACR

# create the azure managed identity
#$USER_ASSIGNED_CLIENT_ID = az identity create -n $AZURE_MANAGED_IDENTITY -g $GROUP --query clientId -o tsv

# get OIDC issuer
#$OIDC_ISSUER = az aks show -n $CLUSTER -g $GROUP --query oidcIssuerProfile.issuerUrl -o tsv

# create the federated credential
#az identity federated-credential create --name $FEDERATED_NAME --identity-name $AZURE_MANAGED_IDENTITY -g $GROUP --issuer $OIDC_ISSUER --subject system:serviceaccount:$($NAMESPACE):$($SERVICE_ACCOUNT_NAME) --audience api://AzureADTokenExchange

# get credentials
#az aks get-credentials -g $GROUP -n $CLUSTER

# create the public IP, NIC, and VM
#az network public-ip create -n $VM_IP -g $GROUP --allocation-method Static
#az network nic create -g $GROUP -n $VM_NIC --vnet-name $VNET --subnet $VM_SUBNET_ID --public-ip-address $VM_IP
#az vm create -n $VM -g $GROUP --nics $VM_NIC --image Win2022Datacenter --assign-identity --authentication-type Password --admin-username ryan

# open the NSG rule (created NSG vnet-vms-nsg-eastus2)
#az network nsg create -n $VM_NSG -g $GROUP
#az network nsg rule create --nsg-name $VM_NSG -n AllowRdp --destination-port-ranges 3389 --priority 100 -g $GROUP
#az network vnet subnet update --vnet-name $VNET -n $SUBNET_VMS -g $GROUP --network-security-group $VM_NSG

# add the entra ID VM extension and assign role
az identity create -n $VM_IDENTITY -g $GROUP
az vm extension set --publisher Microsoft.Azure.ActiveDirectory --name AADLoginForWindows -g $GROUP --vm-name $VM
az role assignment create --role "Virtual Machine Administrator Login" --assignee $VM_IDENTITY --scope $GROUP

# dumps
#$OIDC_ISSUER
#$USER_ASSIGNED_CLIENT_ID