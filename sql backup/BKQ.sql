USE acct2007

GO
DECLARE @backupTime VARCHAR(20)
DECLARE @sqlCommand NVARCHAR(1000)
--設定檔名的執行時間.例如以下的@backupTime將會是200904221156(yyyyMMddHHmm)
--此值可以視需求進行調整,如果是每小時備份,就只要2009042211(yyyyMMddHH)
SELECT @backupTime=(CONVERT(VARCHAR(8), GETDATE(), 112)
         +REPLACE(CONVERT(VARCHAR(5), GETDATE(), 114), ':', ''))
--設定LYTDB資料庫的備份命令
--可視需要修改備份檔存放的位置
SET @sqlCommand = 'BACKUP DATABASE acct2007 TO DISK=''D:\SOFTEK_bk\acct2007\acct2007_'
                  + @backupTime+'.bak'''
EXECUTE sp_executesql @sqlCommand  
GO

USE erp2012a

GO
DECLARE @backupTime VARCHAR(20)
DECLARE @sqlCommand NVARCHAR(1000)
--設定檔名的執行時間.例如以下的@backupTime將會是200904221156(yyyyMMddHHmm)
--此值可以視需求進行調整,如果是每小時備份,就只要2009042211(yyyyMMddHH)
SELECT @backupTime=(CONVERT(VARCHAR(8), GETDATE(), 112)
         +REPLACE(CONVERT(VARCHAR(5), GETDATE(), 114), ':', ''))
--設定LYTDB資料庫的備份命令
--可視需要修改備份檔存放的位置
SET @sqlCommand = 'BACKUP DATABASE acct2007 TO DISK=''D:\SOFTEK_bk\erp2012a\erp2012a_'
                  + @backupTime+'.bak'''
EXECUTE sp_executesql @sqlCommand  
GO

USE erp2012m

GO
DECLARE @backupTime VARCHAR(20)
DECLARE @sqlCommand NVARCHAR(1000)
--設定檔名的執行時間.例如以下的@backupTime將會是200904221156(yyyyMMddHHmm)
--此值可以視需求進行調整,如果是每小時備份,就只要2009042211(yyyyMMddHH)
SELECT @backupTime=(CONVERT(VARCHAR(8), GETDATE(), 112)
         +REPLACE(CONVERT(VARCHAR(5), GETDATE(), 114), ':', ''))
--設定LYTDB資料庫的備份命令
--可視需要修改備份檔存放的位置
SET @sqlCommand = 'BACKUP DATABASE acct2007 TO DISK=''D:\SOFTEK_bk\erp2012m\erp2012m_'
                  + @backupTime+'.bak'''
EXECUTE sp_executesql @sqlCommand  
GO

USE mf2007

GO
DECLARE @backupTime VARCHAR(20)
DECLARE @sqlCommand NVARCHAR(1000)
--設定檔名的執行時間.例如以下的@backupTime將會是200904221156(yyyyMMddHHmm)
--此值可以視需求進行調整,如果是每小時備份,就只要2009042211(yyyyMMddHH)
SELECT @backupTime=(CONVERT(VARCHAR(8), GETDATE(), 112)
         +REPLACE(CONVERT(VARCHAR(5), GETDATE(), 114), ':', ''))
--設定LYTDB資料庫的備份命令
--可視需要修改備份檔存放的位置
SET @sqlCommand = 'BACKUP DATABASE acct2007 TO DISK=''D:\SOFTEK_bk\mf2007\mf2007_'
                  + @backupTime+'.bak'''
EXECUTE sp_executesql @sqlCommand  
GO
