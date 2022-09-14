# DataverseSQL

You can use these scripts as examples on how to use [Syanpse Serverless](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/on-demand-workspace-overview) [T-SQL](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/overview-features) to query [Dataverse](https://docs.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-intro) data stored by [Synapse Link for Dataverse](https://docs.microsoft.com/en-us/power-apps/maker/data-platform/export-to-data-lake) into an [Azure Data Lake](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction).

## [0. Initialize Security.sql](0. Initialize Security.sql)
This file contains two T-SQL variables that need to be customized:
- **@container** (the ]name of the container](https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#container-names) that stores the Dataverse data, including the **model.json** metadata descriptor).
- **@storageaccount** (just the [storage account name](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-name), without the *.dfs.core.windows.net*)

## [1. vDynamicsModel.sql](1. vDynamicsModel.sql)
This view parses the **[model.json](https://docs.microsoft.com/en-us/power-apps/maker/data-platform/azure-synapse-link-data-lake#view-your-data-in-azure-data-lake-storage-gen2)** file at the root of the container, and generates a T-SQL view that returns all the tables and columns with their respective datatypes. This information is going to be used by the next step.

## [2. sp_Rebuild_vDynamicsData.sql](2. sp_Rebuild_vDynamicsData.sql)
This stored procedure takes the data from **vDynamicsModel** and generates multiple views called **vDynamics_*TABLENAME*** in Synapse Serverless. The view name prefix can be customized.
