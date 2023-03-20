CREATE OR ALTER VIEW [dbo].[v_D365__model] AS

WITH
    [model] AS
    (
        SELECT
            m.modelJSON
        FROM
            OPENROWSET
            (
                BULK '/model.json',
                DATA_SOURCE = 'DataSource',
                FORMAT = 'CSV',
                FIELDQUOTE = '0x0b',
                FIELDTERMINATOR ='0x0b',
                ROWTERMINATOR = '0x0b'
            )
            WITH (modelJSON NVARCHAR(MAX)) m
    )
SELECT
    entityID = DENSE_RANK() OVER (ORDER BY CONVERT(BIGINT, e.[key])),
    entityName = JSON_VALUE(e.[value], '$.name'),
    columnID = ROW_NUMBER() OVER (PARTITION BY e.[key] ORDER BY CONVERT(BIGINT, c.[key])),
    columnName = JSON_VALUE(c.[value], '$.name'),
    dataTypeOriginal = JSON_VALUE(c.[value], '$.dataType'),
    dataTypeTemp = 
        CASE JSON_VALUE(c.[value], '$.dataType')
            WHEN 'guid' THEN 'UNIQUEIDENTIFIER'
            WHEN 'dateTime' THEN 'NVARCHAR(4000)'
            WHEN 'int64' THEN 'BIGINT'
            WHEN 'decimal' THEN 'FLOAT'
            WHEN 'boolean' THEN 'BIT'
            ELSE 'NVARCHAR(4000)'
        END,
    dataTypeFinal = 
        CASE JSON_VALUE(c.[value], '$.dataType')
            WHEN 'guid' THEN 'UNIQUEIDENTIFIER'
            WHEN 'dateTime' THEN 'DATETIME2(0)'
            WHEN 'int64' THEN 'BIGINT'
            WHEN 'decimal' THEN 'FLOAT'
            WHEN 'boolean' THEN 'BIT'
            ELSE 'NVARCHAR(4000)'
        END
FROM
    model m
    CROSS APPLY OPENJSON(m.modelJSON, '$.entities') e
    CROSS APPLY OPENJSON(e.[value], '$.attributes') c
GO
