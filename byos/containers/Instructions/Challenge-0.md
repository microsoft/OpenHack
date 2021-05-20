
# Getting Ready to Go

Before you get started with these challenges, you'll want to make sure your environment has the tools and setup to work with the environment.

## Tools

All the tools used for these challenges are cross platform available and are usable on Mac OS X, Linux, and Windows environments.  

> **NOTE**: If you are using a Linux platform, it is recommended to use one of [these Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) to ensure the full funcionality with the environment.

| Tool | Examples / Download Links | Purpose |
| ---- | ------- | ------- |
| Integrated Development Environment (IDE) | [Visual Studio Code](https://code.visualstudio.com/download) or [Visual Studio](https://visualstudio.microsoft.com/vs/community/) | Editing and updating of code and configuratoin with the environment |
| Terminal Environment | PowerShell: [Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1), [Mac](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7.1), [Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1), or Bash: [Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (included in Mac and Linux) |  Used for running commands and scripts |
| Command Line Interface (CLI) | [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) | Used for sending commands to the Azure environment |
| Docker | Docker for [Windows](https://docs.docker.com/docker-for-windows/install/), [Mac](https://docs.docker.com/docker-for-mac/install/), or [Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) | Allowing management and development of Docker locally on your system |
| Kubernetes command-line tool | [kubectl](https://kubernetes.io/docs/tasks/tools/) | Used for control and management of a Kubernetes environment, such as [Azure Kubernetes Services (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) |
| Helm | [helm](https://helm.sh/docs/intro/install/) | Used for package management within Kubernetes |
| Git | [Git](https://git-scm.com/downloads), or one of the many [GUI Clients](https://git-scm.com/downloads/guis/) | for use with code management repositories either locally or online like GitHub |

## Installation

There are two main methods for getting these tools in your environment.  You can either install these tools on your local machine or a machine in your environment; alternatively, you can install them as a Virtual Machine (VM) in an Azure subscription.

> **NOTE:** Use **either** Option A or Option B, but you ***do not need both***.

### Option A - Local machine setup

1. Ensure all the [tools](#Tools) listed above are installed:

    * Integrated Development Environment (IDE)
    * Terminal Environment
    * Command Line Interface (CLI)
    * Docker
    * Kubernetes command-line tool (kubectl)
    * Helm
    * Git

1. Pull SQL Server Docker image to your local docker:

```bash
docker pull mcr.microsoft.com/mssql/server:2017-latest
```

### Option B - Azure VM setup

If you would rather deploy the resources in an Azure Subscription, follow these steps.

#### Create the VM for management

This will allow you to deploy a Linux VM that can be used to manage, deploy, and control the environment with the tools needed:

1. Logon to the [Azure Portal](https://portal.azure.com)
1. Go to **Resource groups**
1. Create the following 2 resource groups in the region closest to you:

* `teamResources`
* `ProctorVMRG`

1. Go to **Create a resource** to create a new resource from the Marketplace
1. Choose the **Ubuntu Server**
![Create an Ubunut Server 18.04 LTS](images/createUbuntuServer.png)
1. Use the following values:

| Field | Value |
| - | - |
| Resource group | teamResources |
| VM Name | OHLabVM |
| Size | D2s v3 |
| Username | demouser |
| Auth type | Password (unless you're familiar with using SSH pub keys) |
| Inbound ports | Allow SSH (22) |

![Azure create Ubuntu Server resource](images/ubuntuCreation.png)

1. The click **Next : Disks >**
1. Click **Next : Networking >** to continue on to networks
1. Ensure the VM is attaching to a subnet (existing or new) with at least a `/27` mask, a public IP, and basic NIC NSG that allows SSH
![Basic networking settings with creating a new VNet](images/ubuntuNetworking.png)
1. Click **Review + create** and **Create** this VM

#### Install Tools on VM

Once the Ubuntu VM has been created, these are the commands to install the tools that will be useful to use with the resources.

1. Go to the **OHLabVM** in your subscription
1. From the Overview, tab click **Connect** and **SSH**

![Connect to SSH on Ubuntu](images/connectToUbuntu.png)

1. This page will have the instructions for connecting to the VM.  Step 4 on this screen will list the username and public IP to use to connect with.
1. Once connected, use this command to install **Azure CLI**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

1. Install **Docker** using `snap`

```bash
sudo snap install docker
```

1. Install **Kubernetes** with `helm` using `snap`

```bash
sudo snap install kubectl --classic
sudo snap install helm --classic
```

1. Install **git**:

```bash
apt-get install git
```

1. Clean up the installation packages with `autoremove`

```bash
sudo apt -y autoremove
```

1. Pull SQL docker image:

```bash
docker pull mcr.microsoft.com/mssql/server:2017-latest
```

Alternatively, all of those commands can be run using this script together:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo snap install docker

sudo snap install kubectl --classic
sudo snap install helm --classic

apt-get install git

sudo apt -y autoremove

docker pull mcr.microsoft.com/mssql/server:2017-latest
```

## References

* [Install Azure CLI on Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
* [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/)
* [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/)
* [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
* [Installing docker on Ubuntu](https://snapcraft.io/install/docker/ubuntu)
* [Kubernetes on Ubuntu](https://ubuntu.com/kubernetes)
* [Git SCM](https://git-scm.com/)
* [Create Linux VM in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
