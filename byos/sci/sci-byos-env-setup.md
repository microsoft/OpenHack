# Security, Compliance, and Identity OpenHack Execution Specifics

This document will discuss the prerequisites to run a Security, Compliance, and Identity (SCI) OpenHack. It includes assets you need to host/point to, coach resources, event structure, and TODOs for each section.

## Challenge resource deployment

OpenHack participants will create challenge personas and resources in Azure AD and Azure.

### TO DO
Each team will:
* Need to sign up for an Office 365 E5 trial account and associate an EMS E5 trial account and Azure trial subscription. This will create a single Azure AD directory and support the OpenHack's scenario that this is a single fictitious company using these Microsoft products.
* Create challenge personas and groups using a PowerShell script.
* Deploy resources in their Azure trial subscription.

#### Sign up for a Microsoft account and an Office 365 E5 trial subscription

In this task, you will create a new Microsoft account and use that account to sign up for an Office 365 E5 trial subscription.

1. Open an InPrivate or Incognito browser session and then browse to [https://outlook.com](https://outlook.com).

1. Select **Create free account**.

1. Complete the wizard to create a new Microsoft account.
    Use either outlook.com or hotmail.com as the suffix.

1. Record your new Microsoft account username and password, and then store them in a safe place.

1. Using the same tab or a new tab in the same browser session, browse to [https://products.office.com/en-us/business/compare-more-office-365-for-business-plans](https://products.office.com/en-us/business/compare-more-office-365-for-business-plans).

1. On the Office 365 Enterprise page, select **Try for free**.

1. Set up your trial using the Microsoft account you just created.
   Use the following information along with your own information to complete signing up for the trial:

    * Company name: Contoso Mortgage
    * Organization size: 50-249 people
    * Use a phone number you have access to for receiving text or call confirmation.
    * Business identity: This name must be unique. As a suggestion, you may use something similar to ContosoTeam1 and append team member initials or other values to help ensure the identity will be unique.

1. On the Create your business identity page, in the Name box, enter **SCIOHAdmin**.

1. Enter a password and then record the password in a safe place.

1. Select **Sign Up**.
   Be sure to **save your user ID and your password**. You will need them for the challenges in this OpenHack.

1. Select **Let's go**, and then wait for confirmation that your tenant has been successfully created before beginning the next task.

1. You do not need to complete the setup wizard. Select **Exit setup**.

1. Create another account the team will use or create an account for each team member and assign the Global Administrator role to the account(s).

#### Sign up for an Enterprise Mobility + Security E5 trial account

In this task, you will sign up for an Enterprise Mobility + Security (EMS) E5 trial account.

1. In the Microsoft 365 admin center, browse to **Billing** > **Purchase services**.

1. Search for **Enterprise Mobility** and, in the **Security and identity** section, select **Enterprise Mobility + Security**.

1. Select **Get free trial**.

1. On the Check out page, select **Try now** and then complete the order process.

1. When complete, assign the **Enterprise Mobility + Security E5** license to the **SCIOHAdmin** account.

#### Sign up for the Microsoft 365 E5 Insider Risk Management trial
In this task you will add the Microsoft 365 E5 Insider Risk Management trial subscription to your tenant and assign the license to your users.

1. In the Microsoft 365 admin center, browse to **Billing** > **Purchase services**.

1. Search for **insider risk** and then select **Microsoft 365 E5 Insider Risk Management**.

1. Select **Get free trial**.

1. On the Check out page, select **Try now** and then complete the order process.

1. When complete, in **Users** > **Active Users**, select all users and then select **Manage product licenses**.

1. Select **Assign more**, select **Microsoft 365 Insider Risk Management**, and then save your changes.

#### Sign up for an Azure trial

In this task, you will sign up for an Azure trial subscription that will use the same Azure AD directory as your Microsoft 365 subscription.

1. Open a new browser tab in the same browser session and then browse to [https://azure.microsoft.com/en-us/free](https://azure.microsoft.com/en-us/free).

1. Select **Start free**.

1. Verify the Your profile section displays the Microsoft account you created earlier and then select **Next**.

1. Complete the telephone number verification.

1. You must also add valid credit card and then complete the agreement.

1. When complete, browse to the Microsoft Azure portal at [https://portal.azure.com](https://portal.azure.com).

1. In the top left, select the portal menu.
   This is the hamburger icon.

1. Select **Azure Active Directory**.

1. In the Overview blade, under **Manage**, select **Properties**.

1. At the bottom of the page, select **Manage Security defaults**.

1. In the Enable Security defaults pane, select **No** to disable security defaults.
   The OpenHack team will be performing security configurations during the challenges.

1. Select one of the reasons for disabling security defaults and then select **Save**.

#### Create user accounts and groups

This task requires that you have installed the Microsoft Azure Active Directory Module for Windows PowerShell on your deployment workstation.
In this task you will run a PowerShell script to create user accounts and groups in your OpenHack Microsoft 365 subscription.

1. Download the user creation script from [https://github.com/microsoft/OpenHack/blob/main/byos/sci/scripts/sciohuserscreation.ps1](https://github.com/microsoft/OpenHack/blob/main/byos/sci/scripts/sciohuserscreation.ps1)

1. Download the user CSV file from [https://github.com/microsoft/OpenHack/blob/main/byos/sci/sciohusers.csv](https://github.com/microsoft/OpenHack/blob/main/byos/sci/sciohusers.csv)

1. Ensure both files are in the same folder on your deployment workstation.

1. Browse to the location where you saved the files.

1. Right-click on one of the files and then select **Properties**.

1. Select the **Unblock** check box and then select **OK**.

1. Perform the same procedure to unblock the second file.

1. Open an elevated Windows PowerShell console.

1. Change to the directory where you saved the sciohusers.csv and sciohuserscreation.ps1 files.
   The PowerShell script will be run using the Unrestricted execution policy. Open and review the PS1 file if you need to confirm the additions that will be made to your Office 365 subscription.

1. Run the following commands:

    ```PowerShell
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted

    sciohusercreation.ps1
    ```

1. When prompted, enter your Office 365 administrator username and password.

1. When complete, close Windows PowerShell.

1. Browse to the Microsoft 365 admin center and verify the newly added users are visible in the **Active Users** page.

#### Launch the Compliance Manager

In this task you will open the Compliance Manager which will start the collection of compliance data.

1. Browse to [https://compliance.microsoft.com](https://compliance.microsoft.com).

1. Open the Compliance Manager.

1. Complete or close the welcome wizard.

#### Launch Secure score

In this task you will open Secure score to start the collection of secure score data.

1. Browse to [https://security.microsoft.com](https://security.microsoft.com).

1. Open the Secure score.

1. Verify **Preparing score** is displayed.

#### Launch Advanced hunting

In this task you will open the Advanced hunting to prepare new spaces for data.

1. In the Microsoft 365 security center, select **Hunting** > **Advanced hunting**.

1. Verify the new spaces are being prepared for data.
   If the page fails to load, retry loading the page.

#### Create Azure resources

The Azure Resource Manager (ARM) template located at [https://github.com/microsoft/OpenHack/blob/main/byos/sci/scripts](https://github.com/microsoft/OpenHack/blob/main/byos/sci/scripts.zip) should be executed against a new resource group named **OpenHackRG** in the target Azure subscription.  The Azure resources are used throughout the OpenHack to provide basic elements used by the fictitious company.

There are no ARM template parameters to provide (resource names are hard-coded within the template).

Use the Microsoft Azure portal to create the resource group and deploy the custom template, or you may use the following commands:

```PowerShell
$location = "eastus"
$resourceGroupName = "OpenHackRG"
$deploymentName = "azuredeploy" + "-" + (Get-Date).ToUniversalTime().ToString('MMdd-HHmmss')

New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile './azure-deploy-scioh-env.json' -Name $deploymentName -Verbose
```

#### Upgrade to Azure Defender

1. In the Micsrosoft Azure portal, browse to the **Security Center**.

1. Under **Enable Azure Defender on 1 subscriptions**, verify your subscription is selected and then, at the bottom of the page, select **Upgrade**.

1. Under **Install agents automatically**, clear the checkbox associated with your subscription.
   Agent installation will occur during the OpenHack.

