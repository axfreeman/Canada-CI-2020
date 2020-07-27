USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP VIEW IF EXISTS [IOICC to ANAICS converter]
GO

CREATE VIEW [dbo].[IOICC to ANAICS converter]
AS
SELECT dbo.[IOICC flat].IOICC6, 
dbo.[IOICC flat].Source, 
dbo.[IOICC flat].Indicator, 
dbo.[IOICC flat].[NAICS description], 
dbo.[IOICC flat].GeoName, 
dbo.[IOICC flat].Year, 
dbo.[IOICC flat].Value, 
dbo.[IOICC flat].Value * dbo.[IOICC to ANAICS].[IOICC coefficient] AS TransformedValue, 
dbo.[IOICC to ANAICS].ANAICS4,
dbo.[IOICC to ANAICS].ANAICS2
FROM dbo.[IOICC flat] LEFT OUTER JOIN dbo.[IOICC to ANAICS] ON dbo.[IOICC flat].IOICC6 = dbo.[IOICC to ANAICS].IOICC6
GO


-- used to select the rows of the IOICC table that will be added to the fact table
-- Since the IOICC table contains items that don't correspond to 4-digit NAICS codes, we only import those rows 
-- which do correspond to 4-digit NAICS codes

DROP VIEW IF EXISTS [dbo].[IOICC CI Row Selector]
GO
CREATE VIEW [dbo].[IOICC CI Row Selector]
AS
SELECT TOP (100) PERCENT IOICC6, Source, Indicator, [NAICS description], GeoName, Year, Value, TransformedValue, ANAICS4
FROM dbo.[IOICC to ANAICS converter]
WHERE(ANAICS4 IS NOT NULL)
ORDER BY Source, Indicator, GeoName, Year
GO


-- used to select the rows of the IOICC table that will be added to the fact table
-- these consist of the rows that identify main industries, ie those which have 2-digit NAICS codes
-- in some cases, such as manufacturing, the 2-digit code actually stands in for more than one2-digit NAICS code 
-- See DimMainIndustries mapping worksheet in the excel source file 'MAPPINGS' for specifics

DROP VIEW IF EXISTS [dbo].[IOICC MI Row Selector]
GO

CREATE VIEW [dbo].[IOICC MI Row Selector]
AS
SELECT TOP (100) PERCENT IOICC6, Source, Indicator, [NAICS description], GeoName, Year, Value, ANAICS2
FROM dbo.[IOICC to ANAICS converter]
WHERE(ANAICS2 IS NOT NULL)
ORDER BY Source, Indicator, GeoName, Year
GO

-- Used when the coding system does not provide a complete set of 4-digit NAICS covering all industries
-- (for example, the IOICC coding used for Cansim's GDP series and for its 'Productivity and hours' series.
-- Calculates total creative of the given indicator, so that we can then subtract this from the total
-- in the economy, and create a pseudo-sector called 'non-creative'
-- use

DROP VIEW IF EXISTS [dbo].[Creative Industries]
GO

CREATE VIEW [dbo].[Creative Industries]
AS
SELECT SUM(dbo.[Fact].Value) AS Value, dbo.[Fact].Year,  dbo.[Fact].Indicator, 
dbo.dimGeography.[Standardised Province], dbo.[Fact].Source, dbo.dimIndustry.[CI sector],dbo.[Fact].ANAICS4
FROM     dbo.dimIndustry RIGHT OUTER JOIN
                  dbo.[Fact] ON dbo.dimIndustry.ANAICS4 = dbo.[Fact].ANAICS4 LEFT OUTER JOIN
                  dbo.dimGeography ON dbo.[Fact].GeoName = dbo.dimGeography.geoName_PK
GROUP BY dbo.dimIndustry.[CI sector], dbo.[Fact].Source, dbo.dimGeography.[Standardised Province], 
dbo.[Fact].Indicator, dbo.[Fact].GeoName, dbo.[Fact].Year,dbo.[Fact].ANAICS4
HAVING ([CI sector] <> N'Total all industries')
GO

DROP VIEW IF EXISTS [dbo].[Total]
GO

CREATE VIEW [dbo].[Total]
AS

SELECT
Year, 
GeoName, 
Value
FROM
(SELECT
	dbo.dimIndustry.[CI sector], 
	dbo.[Fact].Value, 
	dbo.[Fact].Year, 
	dbo.[Fact].GeoName, 
	dbo.[Fact].ANAICS4, 
	dbo.[Fact].Indicator
	FROM dbo.dimIndustry RIGHT OUTER JOIN dbo.[Fact] ON dbo.dimIndustry.ANAICS4 = dbo.[Fact].ANAICS4) AS CIMappedFact2
	WHERE ([CI sector] = N'Total all industries')
GO

-- used as the data source for external applications for the main industries

DROP VIEW IF EXISTS [dbo].[Main Industries]
GO
CREATE VIEW [dbo].[Main Industries]
AS
SELECT SUM(dbo.[Fact].Value) AS Value, dbo.[Fact].Year, dbo.[Fact].GeoName, dbo.[Fact].Indicator, dbo.dimGeography.[Standardised Province], dbo.[Fact].Source, dbo.dimIndustry.[MI sector]
FROM     dbo.dimIndustry RIGHT OUTER JOIN
                  dbo.[Fact] ON dbo.dimIndustry.ANAICS4 = dbo.[Fact].ANAICS4 LEFT OUTER JOIN
                  dbo.dimGeography ON dbo.[Fact].GeoName = dbo.dimGeography.geoName_PK
GROUP BY dbo.dimIndustry.[MI sector], dbo.[Fact].Source, dbo.dimGeography.[Standardised Province], dbo.[Fact].Indicator, dbo.[Fact].GeoName, dbo.[Fact].Year
GO


DROP VIEW IF EXISTS [dbo].[Census Fact]
GO


CREATE VIEW [dbo].[Census Fact]
AS
SELECT
dbo.Census.GeoName, 
dbo.Census.[Occupation Description], 
dbo.Census.[Industry Description], dbo.Census.Value, 
dbo.dimOccupations.[Creative Occupation Type], dbo.dimIndustry.[CI sector], 
dbo.[dimIndustry].[Creative Industry Type],
dbo.Census.ANAICS4, 
dbo.Census.ANOCS4
FROM 
 dbo.Census 
 LEFT OUTER JOIN dbo.dimOccupations ON dbo.Census.ANOCS4 = dbo.dimOccupations.ANOCS4 
 LEFT OUTER JOIN dbo.dimIndustry ON dbo.Census.ANAICS4 = dbo.dimIndustry.ANAICS4
GO

