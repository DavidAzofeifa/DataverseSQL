CREATE OR ALTER PROCEDURE [dbo].[sp_D365__RebuildViews] AS

BEGIN

    DECLARE @viewprefix NVARCHAR(MAX) = 'vD365'; -- You can change the prefix of the views here
    DECLARE @sql NVARCHAR(MAX) = '';
	
    WITH

        enabledEntities (entityName) AS
        (
            SELECT entityName FROM
            (
                VALUES
                    ('account') /* Add more lines to include other entities */
                    --,('dp_country')
                    --,('dp_manufacturer') 
            ) e(entityName)
        ),

        columnDefinitions AS
        (
            SELECT

                entityName,

                columns4select = 
                    STRING_AGG
                    (
                        CONCAT
                        (
                            CONVERT(NVARCHAR(MAX), QUOTENAME(columnName)),
                            CASE
                                WHEN dataTypeTemp = dataTypeFinal THEN ''
                                ELSE CONCAT(' = CONVERT(', dataTypeFinal, ', ', CONVERT(NVARCHAR(MAX), QUOTENAME(columnName)), ')')
                            END                    
                        ),
                        CONCAT(',', CHAR(13), CHAR(10), SPACE(4*7))
                    )
                    WITHIN GROUP (ORDER BY columnID),  

                columns4with = 
                    STRING_AGG
                    (
                        CONCAT
                        (
                            CONVERT(NVARCHAR(MAX), QUOTENAME(columnName)),
                            ' ',
                            dataTypeTemp, 
                            ' ', 
                            columnID
                        ),
                        CONCAT(',', CHAR(13), CHAR(10), SPACE(4*8))
                    )
                    WITHIN GROUP (ORDER BY columnID)
            
                FROM
                    vD365__Model
                GROUP BY
                    entityName
        )
        
        SELECT
            @sql = 
                STRING_AGG
                (
                    CONCAT
                    (
                        '
                        EXEC(''

                        CREATE OR ALTER VIEW [', @viewprefix, '_', UPPER(cd.entityName), '] AS

                        SELECT
                            ', cd.columns4select, '
                        FROM
                            OPENROWSET
                            (
                                BULK ''''/', cd.entityName, '/*.csv'''',
								DATA_SOURCE = ''''DataSource'''',
                                FORMAT = ''''CSV'''',
                                PARSER_VERSION = ''''2.0''''
                            )
                            WITH
                            (
                                ', cd.columns4with,'
                            ) AS [result]
                
                        '')
                        '
                    ),
                    '; ' /* separator */
                ) WITHIN GROUP (ORDER BY cd.entityName)
        FROM
            columnDefinitions cd
            INNER JOIN enabledEntities e ON e.entityName = cd.entityName

    PRINT @sql
    EXEC (@sql)

END

GO
