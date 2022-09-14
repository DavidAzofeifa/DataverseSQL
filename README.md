# DataverseSQL

You can use these scripts as examples on how to use [Syanpse Serverless](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/on-demand-workspace-overview) [T-SQL](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/overview-features) to query [Dataverse](https://docs.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-intro) data stored by [Synapse Link for Dataverse](https://docs.microsoft.com/en-us/power-apps/maker/data-platform/export-to-data-lake) into an [Azure Data Lake](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction). **Please read the [LICENSE](https://github.com/DavidAzofeifa/DataverseSQL/blob/main/LICENSE) file that applies to this repo.**



## 0. [Initialize Security.sql](https://github.com/DavidAzofeifa/DataverseSQL/blob/main/0.%20Initialize%20Security.sql)
This file contains two T-SQL variables that need to be customized:
- **@container** (the ]name of the container](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#container-names) that stores the Dataverse data, including the **[model.json](https://docs.microsoft.com/en-us/common-data-model/model-json)** metadata descriptor).
- **@storageaccount** (just the [storage account name](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-name), without the *.dfs.core.windows.net*)
This step assumes that Synapse's [Managed Identity](https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-managed-identity) is already authorized to read data from the Data Lake storage account.

## 1. [vDynamicsModel.sql](https://github.com/DavidAzofeifa/DataverseSQL/blob/main/1.%20vDynamicsModel.sql)
This view parses the **[model.json](https://docs.microsoft.com/en-us/common-data-model/model-json)** file at the root of the container, and generates a T-SQL view that returns all the tables and columns with their respective datatypes. This information is going to be used by the next step.


## 2. [sp_Rebuild_vDynamicsData.sql](https://github.com/DavidAzofeifa/DataverseSQL/blob/main/2.%20sp_Rebuild_vDynamicsData.sql)
This stored procedure takes the data from **vDynamicsModel** and generates multiple views called **vDynamics_*TABLENAME*** in Synapse Serverless. The view name prefix can be customized.
