# How to run WRF 3.8.1 with azbatch ?

After cloning the repo, change directory to the ncarwrf subdir and execute these steps

## Download WRF

Download the wrf.zip file with binaries and libraries from our storage by running these command

    ~/HPC-azbatch/ncarwrf$ wget "https://hpccenth2lts.blob.core.windows.net/wrf/wrf.zip" -O wrf.zip
    
    ~/HPC-azbatch/ncarwrf$ unzip wrf.zip
    ~/HPC-azbatch/ncarwrf$ mkdir wrf 
    ~/HPC-azbatch/ncarwrf$ cd wrf
    ~/HPC-azbatch/ncarwrf$ unzip wrf.zip

## Update **params.tpl**
Update the **params.tpl** file with the values specific to your environment :

* **subscription** : subscription id where your batch account is created
* **resource_group** : the resource group in which the batch account is 
* **AZURE_BATCH_ACCOUNT** : the name of the batch account
* **AZURE_BATCH_ACCESS_KEY** : batch account key
* **storage_account_name** : the storage account linked with your batch account



## Login to the Azure Batch account
When using several azure accounts you can use `az account list` to list the accounts.

    ../00-login.sh params.tpl


## Create the WRF application package


    ../01-createapppackage.sh params.tpl wrf.tpl


## Create the WRF Node Pool

    ../02-createpool.sh params.tpl ../pool-template.json


## Set the pool to use nodeprep.sh at startup

    ../03-nodeprep.sh params.tpl

## Scale your pool

    ../04-scale.sh params.tpl <nbnodes>


## Create the job. You can run this command multiple time

In the __ncarwrf-job.tpl__ file update these values to reflect the number of nodes you want to run on :



and then run


    ../05-createjob.sh params.tpl ncarwrf-job.tpl <nbnodes>
    
    The output of the statistics (stats_<numberofcores>.out will be copied to the storage_account_name in the container folder ncarwrf
    
    ---
    items:       149
      max:         1.318680
      min:         0.711050
      sum:       114.137140
     mean:         0.766021
    mean/max:         0.580900
you can compare this performance with the figure presented in this repository: https://github.com/schoenemeyer/WRF3.8-in-Azure/blob/master/README.md
In this case we measure 72 sec / 0.766 sec per time step = 94 (simulation speed)

## Monitor your job

Use [Batch Labs](https://azure.github.io/BatchLabs/) to monitor your pools and jobs. 

