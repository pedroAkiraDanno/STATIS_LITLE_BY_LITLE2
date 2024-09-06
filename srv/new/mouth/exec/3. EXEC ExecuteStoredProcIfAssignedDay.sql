





	USE CloudAdm; 
	GO 



    DECLARE @CurrentDay INT;

	PRINT 'show the database TB_AuxTable_Statis'
	SELECT * FROM TB_AuxTable_Statis ORDER BY AssignedDay; 

    -- Get the current day of the month
    SET @CurrentDay = DAY(GETDATE());

    PRINT 'Current Day of the Month: ' + CAST(@CurrentDay AS VARCHAR(2));
	
	
	
	
	
		
	





	---- EXECUTE REBUILD and REOGANIZE. 
	EXEC ExecuteStoredProcIfAssignedDay;

































