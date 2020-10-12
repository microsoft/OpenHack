# Microsoft Data Science DevOps OpenHack 

These instructions are for coaches to upload the training data file required for the OpenHack to Azure.

This script sets up a storage account with a blobstore container, then uploads the a zip file containing the training data needed for the challenges to the blobstore.

The output of this script is a uri to download the file from the blobstore. This should be given to the team. The file can also be accessed via the Azure portal.

The script should be run on Opsgility subscriptions, to ensure that the files are cleaned up at the conclusion of the OpenHack. The script can optionally be run on only a single subscription, and the SAS link shared with all teams.

## Download the training data

1. Create a [Kaggle account](https://www.kaggle.com/), or log in with your existing account.
1. [Accept the rules](https://www.kaggle.com/c/porto-seguro-safe-driver-prediction/rules) for the Porto Seguro Safe Driver Prediction competition.
1. Download **train.csv** file.
    - [Direct link](https://www.kaggle.com/c/porto-seguro-safe-driver-prediction/download/bBLQO8KnNdteCQlNsrPc%2Fversions%2FAiNaEGp1G1uvRpJSjvtI%2Ffiles%2Ftrain.csv)
    - [UI link](https://www.kaggle.com/c/porto-seguro-safe-driver-prediction/data) (if the direct link isn't working)
1. Rename the 'train.csv' file to 'porto_seguro_safe_driver_prediction_input.csv'.

## Powershell setup

1. Open a PowerShell window, and run the following command:

    ```Powershell
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    ```

1. Install the latest version of the Azure Powershell module:

    ```Powershell
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    ```

1. If the module was updated, close the current PowerShell window and open a new one.

## Run the deploy script

1. Sign in to the Azure account:

    ```Powershell
    Connect-AzAccount
    ```

1. Invoke the deploy script. If you downloaded the training file, provide the path to the file as an argument

    ```Powershell
    .\deploy.ps1 [-TrainSource "c:\input.csv.zip"] [-Location "West US"] [-Verbose]
    ```

1. The output of the script is a uri containing a SAS token to download the file from blobstore. This should be given to the team.
