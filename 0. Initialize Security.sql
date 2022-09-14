/*
DROP EXTERNAL DATA SOURCE DataSource
DROP DATABASE SCOPED CREDENTIAL ManagedIdentity
DROP MASTER KEY
*/

DECLARE @container NVARCHAR(MAX) = '{name of the Dataverse container}'
DECLARE @storageaccount NVARCHAR(MAX) = '{name of your storage account}'
DECLARE @url NVARCHAR(MAX) = CONCAT('abfss://', @container, '@', @storageaccount, '.dfs.core.windows.net')

CREATE MASTER KEY
CREATE DATABASE SCOPED CREDENTIAL ManagedIdentity WITH IDENTITY = 'Managed Identity'

DECLARE @sql NVARCHAR(MAX) = CONCAT('CREATE EXTERNAL DATA SOURCE DataSource WITH (LOCATION = ''', @url, ''', CREDENTIAL = ManagedIdentity)')
EXEC sp_executesql @sql
