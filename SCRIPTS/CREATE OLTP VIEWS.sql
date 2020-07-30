USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP VIEW IF EXISTS [dbo].[Creative Industries]
GO

CREATE VIEW [dbo].[Creative Industries]
AS
SELECT        SUM(dbo.Fact.Value) AS Value, dbo.Fact.Year, dbo.Fact.Indicator, dbo.dimGeography.[Standardised Province], dbo.Fact.Source, dbo.dimNewIndustry.[Creative Sector], dbo.Fact.PNAICS, dbo.dimNewIndustry.PNAICS AS NIPNAICS,
                          dbo.dimNewIndustry.NAICS6, dbo.dimNewIndustry.NAICS5, dbo.dimNewIndustry.NAICS4, dbo.dimNewIndustry.NAICS3, dbo.dimNewIndustry.NAICS2
FROM            dbo.dimGeography RIGHT OUTER JOIN
                         dbo.Fact ON dbo.dimGeography.geoName_PK = dbo.Fact.GeoName RIGHT OUTER JOIN
                         dbo.dimNewIndustry ON dbo.Fact.PNAICS = dbo.dimNewIndustry.PNAICS
GROUP BY dbo.dimNewIndustry.[Creative Sector], dbo.Fact.Source, dbo.dimGeography.[Standardised Province], dbo.Fact.Indicator, dbo.Fact.GeoName, dbo.Fact.Year, dbo.Fact.PNAICS, dbo.dimNewIndustry.PNAICS, 
                         dbo.dimNewIndustry.NAICS6, dbo.dimNewIndustry.NAICS5, dbo.dimNewIndustry.NAICS4, dbo.dimNewIndustry.NAICS3, dbo.dimNewIndustry.NAICS2, dbo.Fact.Value
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
