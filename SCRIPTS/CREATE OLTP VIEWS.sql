USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP VIEW IF EXISTS [dbo].[Creative Industries]
GO

CREATE VIEW [dbo].[Creative Industries] AS

SELECT        
Industries.Value, 
Industries.Year, 
Industries.Indicator, 
Industries.[Standardised Province], 
Industries.Source, 
Industries.[Creative Sector], 
Industries.NAICS4, 
dbo.industryDescriptions.Description

FROM            

(SELECT        
SUM(dbo.Fact.Value) AS Value, 
dbo.Fact.Year, 
dbo.Fact.Indicator, 
dbo.dimGeography.[Standardised Province], 
dbo.Fact.Source, 
dbo.dimIndustry.[Creative Sector], 
dbo.Fact.PNAICS, 
dbo.dimIndustry.PNAICS AS NIPNAICS, 
dbo.dimIndustry.NAICS6, 
dbo.dimIndustry.NAICS5, 
dbo.dimIndustry.NAICS4, 
dbo.dimIndustry.NAICS3, 
dbo.dimIndustry.NAICS2

FROM            
dbo.dimGeography RIGHT OUTER JOIN
dbo.Fact ON dbo.dimGeography.geoName_PK = dbo.Fact.GeoName RIGHT OUTER JOIN
dbo.dimIndustry ON dbo.Fact.PNAICS = dbo.dimIndustry.PNAICS

GROUP BY 
dbo.dimIndustry.[Creative Sector], 
dbo.Fact.Source, 
dbo.dimGeography.[Standardised Province], 
dbo.Fact.Indicator, 
dbo.Fact.GeoName, 
dbo.Fact.Year, 
dbo.Fact.PNAICS, 
dbo.dimIndustry.PNAICS, 
dbo.dimIndustry.NAICS6, 
dbo.dimIndustry.NAICS5, 
dbo.dimIndustry.NAICS4, 
dbo.dimIndustry.NAICS3, 
dbo.dimIndustry.NAICS2, 
dbo.Fact.Value) AS Industries LEFT OUTER JOIN
dbo.industryDescriptions ON Industries.NAICS4 = dbo.industryDescriptions.NAICS6
GO



DROP VIEW IF EXISTS [dbo].[Industries]
GO

CREATE VIEW [dbo].[Industries]
AS
SELECT        SUM(dbo.Fact.Value) AS Value, dbo.Fact.Year, dbo.Fact.Indicator, dbo.dimGeography.[Standardised Province], dbo.Fact.Source, dbo.dimIndustry.[Creative Sector], dbo.Fact.PNAICS, dbo.dimIndustry.PNAICS AS NIPNAICS,
                          dbo.dimIndustry.NAICS6, dbo.dimIndustry.NAICS5, dbo.dimIndustry.NAICS4, dbo.dimIndustry.NAICS3, dbo.dimIndustry.NAICS2
FROM            dbo.dimGeography RIGHT OUTER JOIN
                         dbo.Fact ON dbo.dimGeography.geoName_PK = dbo.Fact.GeoName RIGHT OUTER JOIN
                         dbo.dimIndustry ON dbo.Fact.PNAICS = dbo.dimIndustry.PNAICS
GROUP BY dbo.dimIndustry.[Creative Sector], dbo.Fact.Source, dbo.dimGeography.[Standardised Province], dbo.Fact.Indicator, dbo.Fact.GeoName, dbo.Fact.Year, dbo.Fact.PNAICS, dbo.dimIndustry.PNAICS, 
                         dbo.dimIndustry.NAICS6, dbo.dimIndustry.NAICS5, dbo.dimIndustry.NAICS4, dbo.dimIndustry.NAICS3, dbo.dimIndustry.NAICS2, dbo.Fact.Value
GO


DROP VIEW IF EXISTS [dbo].[IOICC Flat to Fact converter]
GO

-- This view converts a small number of IOICC codes that are not reported at the 4 digit level,
-- to 4-digit codes. At this time, the only splits applied are those required for the Creative Industries
-- using the NESTA definition.
-- Further split factor definitions are possible.

CREATE VIEW [dbo].[IOICC Flat to Fact converter]
AS
SELECT        
dbo.[IOICC flat].PNAICS, 
dbo.[IOICC SPLITTER].[PNAICS TARGET], 
dbo.[IOICC flat].Source, 
dbo.[IOICC flat].Indicator, 
dbo.[IOICC flat].geoName, 
dbo.[IOICC flat].Year, 
dbo.[IOICC flat].Value * dbo.[IOICC SPLITTER].Coefficient AS SplitValue, 
dbo.[IOICC SPLITTER].Coefficient, 
dbo.[IOICC flat].Value
FROM            dbo.[IOICC flat] RIGHT OUTER JOIN
                         dbo.[IOICC SPLITTER] ON dbo.[IOICC flat].PNAICS = dbo.[IOICC SPLITTER].[PNAICS SOURCE]
GO
