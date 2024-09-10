

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- drop all tables and procedures related with STATISTICS. 





USE [CloudADM]
GO
/****** Object:  StoredProcedure [dbo].[DisableTriggerInDatabase]    Script Date: 9/9/2024 12:11:39 PM ******/
DROP PROCEDURE [dbo].[DisableTriggerInDatabase]
GO




USE [CloudADM]
GO
/****** Object:  StoredProcedure [dbo].[EnableTriggerInDatabase]    Script Date: 9/9/2024 12:11:49 PM ******/
DROP PROCEDURE [dbo].[EnableTriggerInDatabase]
GO





USE [CloudADM]
GO
/****** Object:  StoredProcedure [dbo].[ExecuteStoredProcIfAssignedDayStatis]    Script Date: 9/9/2024 12:12:15 PM ******/
DROP PROCEDURE [dbo].[ExecuteStoredProcIfAssignedDayStatis]
GO





USE [CloudADM]
GO
/****** Object:  StoredProcedure [dbo].[UpdateAllTableStatistics]    Script Date: 9/9/2024 12:13:06 PM ******/
DROP PROCEDURE [dbo].[UpdateAllTableStatistics]
GO




USE [CloudADM]
GO
/****** Object:  Table [dbo].[TB_AuxTable_Statis]    Script Date: 9/9/2024 12:13:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TB_AuxTable_Statis]') AND type in (N'U'))
DROP TABLE [dbo].[TB_AuxTable_Statis]
GO





-----------------------------------------------------------------------------------------------------------------------------------------------------------------------





