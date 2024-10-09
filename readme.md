# AKS Demo using Windows SMB File Share

This example shows how to bind a Windows SMB share to pods running in AKS. The PV uses the `smb.csi.k8s.io` driver to access the SMB share. 

## Running the Demo

The demo includes a simple .NET Web API application that retrieves a value from the file `./configuration/data.json` and outputs the property for "connection". The file should look like the following:

```json
{
    "connection": "<this value is coming from a windows file share on a VM>"
}
```

Once the VM is deployed, this file will need to be placed on a SMB file share and the deployment to be configured to mount the SMB share as a volume at the path `/app/configuration` (where "app" is the name of the working folder for the .NET application)

### Build and Deploy Application

Update the contents of `.\app\deploy.ps1` with the ACR name and run the script. The application is built/tagged as `"YOURACRNAME.azurecr.io/apiservice:latest"` and pushed to the registry.

```powershell
# build and push the application to the registry
.\app\deploy.ps1
```

### Deploy Infrastructure

Run the following script to create the necessary supporting resources:

- Resource group
- VNET/Subnets (for AKS and VM)
- NSGs and rules for subnets to allow RDP (VM) and web (AKS) access
- AKS cluster
- Public IP, NIC, and VM
- SMB CSI driver for file share access (requires Helm)

```powershell
# deploy infrastructure (group, vnet/subnets, AKS, VM, NSGs, etc)
.\ias\setup.ps1
```

As part of the execution of this script, it will prompt for the password of the VM. Once this is complete, verify that there are no errors and the cluster is accessible. 

In addition, ensure that the SMB CSI driver pods were deployed via Helm:

```powershell
kubectl -n kube-system get pods --selector="app.kubernetes.io/name=csi-driver-smb" --watch
```

Finally, log onto the VM using the public IP provided in the output, set up a file share, and provide access credentials. 

### Deploy Kubernetes Resources

Once the cluster has been provisioned, the following script will deploy the necessary namespace, deployment, service, PVC/PV, and SMB secret to access the share. 

**Be sure to update the following:**
- Set the username and password (base64 encoded) in [`smb-secret.yaml`](./aks/smb-secret.yaml).
- The internal IP of the VM that contains the SMB share and the name of the share in [volume.yaml](./aks/volume.yaml)

```powershell
# deploy the kubernetes resources
.\aks\deploy.ps1
```

*The output of the execution should show the public IP of the `LoadBalancer` service used by the web API application.*

## Links
- [Provision Azure NetApp Files SMB volumes for Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-smb)