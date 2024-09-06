

USE master; 
GO 






IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'CloudAdm')
  BEGIN
    CREATE DATABASE CloudAdm;
  END








