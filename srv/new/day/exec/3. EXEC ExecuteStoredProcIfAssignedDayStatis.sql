


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT 

	 USE CloudAdm; 
	 GO 



		
	 USE CloudAdm; 
	 GO   
	
	 PRINT 'show the database TB_AuxTableStatis'
	 SELECT * FROM TB_AuxTableStatis ORDER BY AssignedDay; 
	
	 DECLARE @CurrentDay INT;
	 -- Get the current day of the month
	 SET @CurrentDay = DAY(GETDATE());
	
	 PRINT 'Current Day of the Month: ' + CAST(@CurrentDay AS VARCHAR(2));
		
	
	
	
	




    	-- Get the current day of the month
    	 SELECT DATEPART(WEEKDAY, GETDATE()) AS WEEKDAY;
	 GO

    	-- Get the current day of the month
    	 SELECT DATENAME(dw,GETDATE()) AS WEEKNAME;
	  GO
		  
	   


           --- principal	  
           USE CloudAdm; 
	   GO 		  
	   DECLARE @CurrentDay INT;
	    -- Get the current day of the month
	    SET @CurrentDay =DATEPART(WEEKDAY, GETDATE());		
	    PRINT 'database of current day'
	    SELECT * FROM TB_AuxTableStatis WHERE AssignedDay = @CurrentDay ORDER BY AssignedDay; 	
	    GO



	

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE 

	USE CloudAdm; 
	GO 
		
	---- EXECUTE REBUILD and REOGANIZE. 
 	EXEC ExecuteStoredProcIfAssignedDayStatis;





























