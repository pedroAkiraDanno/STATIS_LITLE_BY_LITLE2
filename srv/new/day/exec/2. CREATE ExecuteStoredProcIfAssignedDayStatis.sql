




USE CLOUDADM; 
GO 






CREATE OR ALTER PROCEDURE UpdateAuxTableStatis
AS
BEGIN
    -- Step 1: Drop and recreate the TB_AuxTableStatis
    IF OBJECT_ID('TB_AuxTableStatis', 'U') IS NOT NULL
    BEGIN
        DROP TABLE TB_AuxTableStatis;
        PRINT 'TB_AuxTableStatis dropped.';
    END

    CREATE TABLE TB_AuxTableStatis (
        DatabaseName VARCHAR(255),
        AssignedDay INT
    );
    PRINT 'TB_AuxTableStatis created.';


    -- add new 02-09-24
     -- add primary key to improve performace
    -- ALTER TABLE TB_AuxTableStatis
    -- ADD CONSTRAINT PK_DatabaseName PRIMARY KEY (DatabaseName);
   -- PRINT 'add primary key to improve performace.';




    -- Step 2: Insert databases into TB_AuxTableStatis if they are not already present
    INSERT INTO TB_AuxTableStatis (DatabaseName)
    SELECT UPPER(Name)
    FROM sys.databases
    WHERE UPPER(Name) NOT LIKE '%HOMOLOG%'
      AND UPPER(Name) NOT LIKE '%CANCELADO%'
      AND UPPER(Name) NOT LIKE '%CANCELAMENTO%'    
      AND UPPER(Name) NOT LIKE '%REPLICADOR%'
      AND UPPER(Name) NOT LIKE '%BLOQUEADO%'
      AND UPPER(Name) NOT LIKE '%MIGRANDO%'
      AND UPPER(Name) NOT LIKE '%DEMONSTRACAO%'
      AND UPPER(Name) NOT LIKE '%SKY%'
      AND UPPER(Name) NOT LIKE '%DESENV%'  
      AND UPPER(Name) NOT LIKE '%EQUIPEF4%'
      AND UPPER(Name) NOT LIKE '%TesteUnitario%'    
      AND UPPER(Name) NOT LIKE '%CLOUDADM%'    
      AND UPPER(Name) NOT LIKE '%VIXENPOSSUPORTE%' 	
      AND UPPER(Name) NOT LIKE '%VolpeEventoOtica%'    
      AND UPPER(Name) NOT LIKE '%FALTA_PAGAMENTO%'   
      AND UPPER(Name) NOT LIKE '%_APAGAR%'    	    
      -- about cloud07 dbs with very large size
      AND UPPER(Name) NOT LIKE '%VOLPEEVENTOOTICA%'     
      AND UPPER(Name) NOT LIKE '%VIXENPOS%'   
      AND UPPER(Name) NOT LIKE '%VIXENWEB%'       
      AND UPPER(Name) NOT LIKE '%VIXENSKYNET%'      
      AND UPPER(Name) NOT LIKE '%VOLPETONINHOHOMOLOGACAO%'      
      AND UPPER(Name) NOT LIKE '%VOLPEEMBAVIDROHOMOLOG%'   
      AND UPPER(Name) NOT LIKE '%VOLPELABDEMO%' 
      AND UPPER(Name) NOT LIKE '%LABDEMO%' 	            
      AND UPPER(Name) NOT LIKE '%VOLPEMEDIAMONKS_HOMOLOG%'    
      AND UPPER(Name) NOT LIKE '%VIXENOTICAWEBAPI_TESTEUNITARIO%'    -- in SBD    
      --AND UPPER(Name) NOT LIKE '%VOLPEOTICACRISLEN%'      	    
      --AND UPPER(Name) NOT LIKE '%VOLPEFEIRA%'  	    
      --AND UPPER(Name) NOT LIKE '%OTICACORPWIZARD%'    	    
      --AND UPPER(Name) NOT LIKE '%VOLPEOTICAECIA%'   	    
      AND DATABASE_ID > 4;



    PRINT 'Databases inserted into TB_AuxTableStatis.';

    -- Step 3: Update AssignedDay with a value from 1 to 7
    WITH NumberedDatabases AS (
        SELECT
            DatabaseName,
            ROW_NUMBER() OVER (ORDER BY DatabaseName) AS RowNum -- ROW_NUMBER() is a window function that assigns a unique sequential integer to rows within the result set of a query. 
        FROM TB_AuxTableStatis
    )
    UPDATE TB_AuxTableStatis
    SET AssignedDay = ((RowNum - 1) % 7) + 1
    FROM NumberedDatabases
    WHERE TB_AuxTableStatis.DatabaseName = NumberedDatabases.DatabaseName;

    PRINT 'AssignedDay updated for each database.';
    




    -- Display contents of TB_AuxTableStatis
    SELECT * FROM TB_AuxTableStatis ORDER BY AssignedDay;


	-- CREATE INDEX 
	PRINT 'Cretae index with [DatabaseName] to performace.';
        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_DATABASENAME ON [dbo].[TB_AuxTableStatis]
        (
            [DatabaseName] ASC
        ); --WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);


     PRINT 'Cretae index with [AssignedDay] to performace.';		
        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_ASSIGNEDDAY ON [dbo].[TB_AuxTableStatis]
        (
            [AssignedDay] ASC
        ); --WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);



END;
GO





  EXEC UpdateAuxTableStatis;




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



















    	-- Get the current day of the month
    	 SELECT DATEPART(WEEKDAY, GETDATE()) AS WEEKDAY;
	 GO



    	-- Get the current day of the month
    	 SELECT DATENAME(dw,GETDATE()) AS WEEKNAME;
	  GO


		   
	   DECLARE @CurrentDay INT;
	    -- Get the current day of the month
	    SET @CurrentDay =DATEPART(WEEKDAY, GETDATE());		
	    PRINT 'database of current day'
	    SELECT * FROM TB_AuxTableStatis WHERE AssignedDay = @CurrentDay ORDER BY AssignedDay; 	
	    GO




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------







CREATE OR ALTER PROCEDURE [dbo].[UpdateAllTableStatistics]
    @dbname VARCHAR(255)
AS
BEGIN
    -- Ensure no extra messages interfere with the output
    SET NOCOUNT ON;

    -- Declare variables for dynamic SQL
    DECLARE @SQL NVARCHAR(MAX);
    --DECLARE @tablename NVARCHAR(128);
    --DECLARE @Statement NVARCHAR(300);

    -- Build dynamic SQL to switch database context
    SET @SQL = N'
    -- Declare variables for dynamic SQL
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @tablename NVARCHAR(300);
    DECLARE @Statement NVARCHAR(MAX);

    USE ' + QUOTENAME(@dbname) + ';
    
    -- Declare a cursor for selecting table names from the specified database
    DECLARE updatestats CURSOR FOR
    SELECT table_name
    FROM information_schema.tables
    WHERE TABLE_TYPE = ''BASE TABLE'';

    -- Open the cursor
    OPEN updatestats;

    -- Fetch the first row
    FETCH NEXT FROM updatestats INTO @tablename;

    -- Loop through all rows in the cursor
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        -- Construct the UPDATE STATISTICS command
        PRINT N''UPDATING STATISTICS '' + @tablename;
        -- SET @Statement = ''UPDATE STATISTICS '' + QUOTENAME(@tablename) + '' WITH FULLSCAN'';
        SET @Statement = ''UPDATE STATISTICS '' + QUOTENAME(@tablename);        
        PRINT @Statement;

        -- Execute the dynamic SQL command
        EXEC sp_executesql @Statement;

        -- Fetch the next row
        FETCH NEXT FROM updatestats INTO @tablename;
    END

    -- Close and deallocate the cursor
    CLOSE updatestats;
    DEALLOCATE updatestats;
    ';

	--print @SQL;
    -- Execute the dynamic SQL
    EXEC sp_executesql @SQL;
    
    -- Restore NOCOUNT setting
    SET NOCOUNT OFF;
END;
GO


        









-- reference: https://www.sqlservercentral.com/scripts/update-statistics-for-all-tables-in-any-db

        
        
        
--  exec [UpdateAllTableStatistics] @dbname=  'VOLPEGILLANCASTER'
	
	
	
	
	
	
	
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

    -- Get the current day of the week (1 = Monday, ..., 7 = Sunday)
    SET @CurrentDay = DATEPART(WEEKDAY, GETDATE());

    PRINT 'Current Day of the Week: ' + CAST(@CurrentDay AS VARCHAR(2));

    -- Refresh the TB_AuxTableStatis
    EXEC UpdateAuxTableStatis;

    -- Declare the cursor
    DECLARE db_cursor CURSOR FOR
    SELECT DatabaseName, AssignedDay
    FROM TB_AuxTableStatis;

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



                EXEC('USE CloudADM;');
                PRINT 'Current day matches AssignedDay for ' + @DatabaseName + '. Executing stored procedure.';
                -- Prepare dynamic SQL to use the database and execute the stored procedure
                SET @SQL = 'EXEC UpdateAllTableStatistics @dbname = ' + QUOTENAME(@DatabaseName) + ';';

                -- Print and execute the dynamic SQL
                PRINT @SQL;
                EXEC sp_executesql @SQL;




                -- Enable TRIGGER
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
GO

















-- EXEC ExecuteStoredProcIfAssignedDayStatis;



































-- INDEX


/*
        USE [CloudADM]

        GO

        SET ANSI_PADDING ON


        GO

        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_DATABASENAME ON [dbo].[TB_AuxTableStatis]
        (
            [DatabaseName] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

        GO








        USE [CloudADM]

        GO

        CREATE NONCLUSTERED INDEX IDXP_AUXTABLE_ASSIGNEDDAY ON [dbo].[TB_AuxTableStatis]
        (
            [AssignedDay] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)

        GO

*/











