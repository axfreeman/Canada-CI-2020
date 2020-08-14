USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- the Geography dimension. Creates a standard geography that is valid throughout the time period covered
-- Mostly the same as today's province names with a couple of quirks, notably, all the
-- Northern provinces are amalgamated, because they don't exist throughout the whole period covered.
-- the Geo Names table. Gets converted to the ROLAP DimGeo table. Probably redundant

DROP TABLE IF EXISTS [dbo].[dimGeography]
GO

CREATE TABLE [dbo].[dimGeography](
	[geoName_PK] [nvarchar](255) NOT NULL,
	[Standardised Province] [nvarchar](255) NULL
) ON [PRIMARY]
GO


-- Creative Industry NAICS codes.

DROP TABLE IF EXISTS [dbo].[dimIndustry]
GO

CREATE TABLE [dbo].[dimIndustry](
	[PNAICS][nvarchar](7) NOT NULL,
	[NAICS6][nvarchar](7) NULL,
	[NAICS5][nvarchar](7) NULL,
	[NAICS4][nvarchar](7) NULL,
	[NAICS3][nvarchar](7) NULL,
	[NAICS2][nvarchar](7) NULL,
	[Creative Sector] [nvarchar] (255) NULL,
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS dimOccupations
GO

CREATE TABLE [dbo].[dimOccupations](
ANOCS4 [nvarchar](5) NULL,	
oNESTA [nvarchar](5) NULL,	
oHiggs [nvarchar](5) NULL,	
oFreeman[nvarchar](8) NULL,
[Occupation Description] [nvarchar] (255) NULL,	
[Creative Occupation Type] [nvarchar](12) NULL,
) on [PRIMARY]
GO

DROP TABLE IF EXISTS industryDescriptions
GO

CREATE TABLE [dbo].[industryDescriptions](
NAICS6[nvarchar](6) NULL,	
Description[nvarchar](255) NULL,	
) on [PRIMARY]
GO


