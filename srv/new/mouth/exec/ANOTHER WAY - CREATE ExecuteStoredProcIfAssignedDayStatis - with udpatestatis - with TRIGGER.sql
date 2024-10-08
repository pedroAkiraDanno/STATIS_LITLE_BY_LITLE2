





USE CloudAdm; 
GO 



CREATE OR ALTER PROCEDURE UpdateAuxTable
AS
BEGIN
    -- Step 1: Drop and recreate the TB_AuxTable
    IF OBJECT_ID('TB_AuxTable', 'U') IS NOT NULL
    BEGIN
        DROP TABLE TB_AuxTable;
        PRINT 'TB_AuxTable dropped.';
    END

    CREATE TABLE TB_AuxTable (
        DatabaseName VARCHAR(255),
        AssignedDay INT
    );
    PRINT 'TB_AuxTable created.';

    -- Display contents of TB_AuxTable
    --SELECT * FROM TB_AuxTable;


    -- add new 02-09-24
     -- add primary key to improve performace
    -- ALTER TABLE TB_AuxTable
    -- ADD CONSTRAINT PK_DatabaseName PRIMARY KEY (DatabaseName);
   -- PRINT 'add primary key to improve performace.';





    -- Step 2: Insert databases into TB_AuxTable if they are not already present
    INSERT INTO TB_AuxTable (DatabaseName)
    SELECT UPPER(Name)
    FROM sys.databases
    WHERE UPPER(Name) NOT LIKE '%HOMOLOG%'
      AND UPPER(Name) NOT LIKE '%CANCELADO%'
      AND UPPER(Name) NOT LIKE '%REPLICADOR%'
      AND UPPER(Name) NOT LIKE '%BLOQUEADO%'
      AND UPPER(Name) NOT LIKE '%MIGRANDO%'
      AND UPPER(Name) NOT LIKE '%DEMONSTRACAO%'
      AND UPPER(Name) NOT LIKE '%SKY%'
      AND UPPER(Name) NOT LIKE '%DESENV%'  
      AND UPPER(Name) NOT LIKE '%EQUIPEF4%'
      AND UPPER(Name) NOT LIKE '%FALTA_PAGAMENTO%'      
      AND DATABASE_ID > 4;

    PRINT 'Databases inserted into TB_AuxTable.';

    -- Step 3: Update AssignedDay with the current day of the month
    WITH NumberedDatabases AS (
        SELECT
            DatabaseName,
            ROW_NUMBER() OVER (ORDER BY DatabaseName) AS RowNum -- ROW_NUMBER() is a window function that assigns a unique sequential integer to rows within the result set of a query. 
        FROM TB_AuxTable
    )
    UPDATE TB_AuxTable
    SET AssignedDay = ((RowNum - 1) % 30) + 1
    FROM NumberedDatabases
    WHERE TB_AuxTable.DatabaseName = NumberedDatabases.DatabaseName;

    -- Display contents of TB_AuxTable
    SELECT * FROM TB_AuxTable ORDER BY 2;
    PRINT 'AssignedDay updated for each database.';


	-- CREATE INDEX 
	PRINT 'Cretae index with [DatabaseName] to performace.';
        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_DATABASENAME ON [dbo].[TB_AuxTable]
        (
            [DatabaseName] ASC
        ); --WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);


        PRINT 'Cretae index with [AssignedDay] to performace.';		
        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_ASSIGNEDDAY ON [dbo].[TB_AuxTable]
        (
            [AssignedDay] ASC
        ); --WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);



END;
GO




-- EXEC UpdateAuxTable;
















































	   PRINT 'show the database TB_AuxTable'
	   SELECT * FROM TB_AuxTable ORDER BY AssignedDay; 
	   DECLARE @CurrentDay INT;

	    -- Get the current day of the month
	    SET @CurrentDay = DAY(GETDATE());
	    PRINT 'Current Day of the Month: ' + CAST(@CurrentDay AS VARCHAR(2));
		
	    PRINT 'database of current day'
	    SELECT * FROM TB_AuxTable WHERE AssignedDay = @CurrentDay ORDER BY AssignedDay; 
	    GO


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	





CREATE OR ALTER PROCEDURE  DisableTriggerInDatabase
    @DatabaseName NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Build the dynamic SQL to switch databases and perform operations
    SET @SQL = '
        USE ' + QUOTENAME(@DatabaseName) + ';

        PRINT ''Disable a Trigger if it exists in database: ' + @DatabaseName + ', : '';

        -- Check if the trigger exists
        IF EXISTS (SELECT * FROM sys.triggers WHERE name = ''tr_logdatabase'')
        BEGIN
            -- Disable the trigger
            EXEC(''DISABLE TRIGGER [tr_logdatabase] ON DATABASE;'');
            PRINT ''Trigger [tr_logdatabase] has been disabled on database ' + @DatabaseName + '. '';
        END
        ELSE
        BEGIN
            PRINT ''Trigger [tr_logdatabase] does not exist on database ' + @DatabaseName + '. '';
        END
    ';

    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL;
END
GO 


















CREATE OR ALTER PROCEDURE  EnableTriggerInDatabase
    @DatabaseName NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Build the dynamic SQL to switch databases and perform operations
    SET @SQL = '
        USE ' + QUOTENAME(@DatabaseName) + ';

        PRINT ''Enable a Trigger if it exists in database: ' + @DatabaseName + ', : '';

        -- Check if the trigger exists
        IF EXISTS (SELECT * FROM sys.triggers WHERE name = ''tr_logdatabase'')
        BEGIN
            -- Enable the trigger
            EXEC(''Enable TRIGGER [tr_logdatabase] ON DATABASE;'');
            PRINT ''Trigger [tr_logdatabase] has been disabled on database ' + @DatabaseName + '. '';
        END
        ELSE
        BEGIN
            PRINT ''Trigger [tr_logdatabase] does not exist on database ' + @DatabaseName + '. '';
        END
    ';

    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL;
END
GO 







-- DisableTriggerInDatabase @DatabaseName = 'CloudADM';
-- EnableTriggerInDatabase @DatabaseName = 'CloudADM';




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------




	
	
	
	
	




CREATE OR ALTER PROCEDURE ExecuteStoredProcIfAssignedDayStatis
AS
BEGIN
    DECLARE @DatabaseName VARCHAR(255);
    DECLARE @AssignedDay INT;
    DECLARE @CurrentDay INT;
    DECLARE @SQL NVARCHAR(MAX);

    -- Get the current day of the month
    SET @CurrentDay = DAY(GETDATE());

    PRINT 'Current Day of the Month: ' + CAST(@CurrentDay AS VARCHAR(2));

    -- Refresh the TB_AuxTable
    EXEC UpdateAuxTable;

    -- Declare the cursor
    DECLARE db_cursor CURSOR FOR
    SELECT DatabaseName, AssignedDay
    FROM TB_AuxTable;

    -- Open the cursor
    OPEN db_cursor;

    -- Fetch the first row
    FETCH NEXT FROM db_cursor INTO @DatabaseName, @AssignedDay;

    -- Loop through the rows
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Processing Database: ' + @DatabaseName + ', AssignedDay: ' + CAST(@AssignedDay AS VARCHAR(2));
        
        -- Check if today matches the AssignedDay
        IF @CurrentDay = @AssignedDay
        BEGIN
            PRINT 'Current day matches AssignedDay for ' + @DatabaseName + '. Executing stored procedure.';
            

                -- DISABLE TRIGGER
                -- Prepare dynamic SQL to use the database and execute the stored procedure
                SET @SQL = 'EXEC DisableTriggerInDatabase @DatabaseName = ' + QUOTENAME(@DatabaseName) + ';';
                -- Print and execute the dynamic SQL
                PRINT @SQL;
                EXEC sp_executesql @SQL;



            
                -- Prepare dynamic SQL to use the database and execute the stored procedure
                SET @SQL = '
                    USE ' + QUOTENAME(@DatabaseName) + ';
                    EXEC sp_updatestats;
                ';

                -- Print and execute the dynamic SQL
                PRINT @SQL;
                EXEC sp_executesql @SQL;







                -- DISABLE TRIGGER
                -- Prepare dynamic SQL to use the database and execute the stored procedure
                SET @SQL = 'EXEC EnableTriggerInDatabase @DatabaseName = ' + QUOTENAME(@DatabaseName) + ';';
                -- Print and execute the dynamic SQL
                PRINT @SQL;
                EXEC sp_executesql @SQL;








        END
        ELSE
        BEGIN
            PRINT 'Current day does not match AssignedDay for ' + @DatabaseName + '. Skipping stored procedure execution.';
        END

        -- Fetch the next row
        FETCH NEXT FROM db_cursor INTO @DatabaseName, @AssignedDay;
    END

    -- Close and deallocate the cursor
    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    PRINT 'Cursor processing complete.';
END;
















-- EXEC ExecuteStoredProcIfAssignedDayStatis;

















































-- INDEX

/*
	USE [CloudADM];
	GO

	-- Check if the index IDXP_AUXTABLE_DATABASENAME exists
	IF NOT EXISTS (
		SELECT 1 
		FROM sys.indexes 
		WHERE name = 'IDXP_AUXTABLE_DATABASENAME' 
		AND object_id = OBJECT_ID('dbo.TB_AuxTable')
	)
	BEGIN
		-- Create the index if it does not exist
		CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_DATABASENAME 
		ON [dbo].[TB_AuxTable] ([DatabaseName] ASC)
		WITH (
			PAD_INDEX = OFF, 
			STATISTICS_NORECOMPUTE = OFF, 
			SORT_IN_TEMPDB = OFF, 
			DROP_EXISTING = OFF, 
			ONLINE = OFF, 
			ALLOW_ROW_LOCKS = ON, 
			ALLOW_PAGE_LOCKS = ON, 
			OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
		);
	END
	GO

	-- Check if the index IDXP_AUXTABLE_ASSIGNEDDAY exists
	IF NOT EXISTS (
		SELECT 1 
		FROM sys.indexes 
		WHERE name = 'IDXP_AUXTABLE_ASSIGNEDDAY' 
		AND object_id = OBJECT_ID('dbo.TB_AuxTable')
	)
	BEGIN
		-- Create the index if it does not exist
		CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_ASSIGNEDDAY 
		ON [dbo].[TB_AuxTable] ([AssignedDay] ASC)
		WITH (
			PAD_INDEX = OFF, 
			STATISTICS_NORECOMPUTE = OFF, 
			SORT_IN_TEMPDB = OFF, 
			DROP_EXISTING = OFF, 
			ONLINE = OFF, 
			ALLOW_ROW_LOCKS = ON, 
			ALLOW_PAGE_LOCKS = ON, 
			OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
		);
	END
	GO

*/
















-- INDEX


/*
        USE [CloudADM]

        GO

        SET ANSI_PADDING ON


        GO

        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_DATABASENAME ON [dbo].[TB_AuxTable]
        (
            [DatabaseName] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

        GO








        USE [CloudADM]

        GO

        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_ASSIGNEDDAY ON [dbo].[TB_AuxTable]
        (
            [AssignedDay] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

        GO

*/










