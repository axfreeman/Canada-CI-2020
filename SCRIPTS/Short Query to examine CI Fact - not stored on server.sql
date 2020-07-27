/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [CI FactPK]
      ,[Source]
      ,[Indicator]
      ,[ANAICS4]
      ,[NAICS description]
      ,[GeoName]
      ,[Year]
      ,[Value]
  FROM [CANADA_CI_OLTP].[dbo].[CI Fact]
  where Geoname=N'Canada' and year = '2016'