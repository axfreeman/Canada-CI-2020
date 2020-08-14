USE [canada_ci_oltp]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- the Geography dimension. Creates a standard geography that is valid throughout the time period covered
-- Mostly the same as today's province names with a couple of quirks, notably, all the
-- Northern provinces are amalgamated, because they don't exist throughout the whole period covered.
-- the Geo Names table. Gets converted to the ROLAP DimGeo table. Probably redundant

DROP TABLE IF EXISTS [dbo].[dim_geography]
GO

CREATE TABLE [dbo].[dim_geography](
	[geo_name_pk] [nvarchar](255) NOT NULL,
	[standardised_province] [nvarchar](255) NULL
) ON [PRIMARY]
GO


-- Creative Industry naics codes.

DROP TABLE IF EXISTS [dbo].[dim_industry]
GO

CREATE TABLE [dbo].[dim_industry](
	[pnaics][nvarchar](7) NOT NULL,
	[naics6][nvarchar](7) NULL,
	[naics5][nvarchar](7) NULL,
	[naics4][nvarchar](7) NULL,
	[naics3][nvarchar](7) NULL,
	[naics2][nvarchar](7) NULL,
	[creative_sector] [nvarchar] (255) NULL,
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS dim_occupations
GO

CREATE TABLE [dbo].[dim_occupations](
anocs4 [nvarchar](5) NULL,	
o_nesta [nvarchar](5) NULL,	
o_higgs [nvarchar](5) NULL,	
o_freeman[nvarchar](8) NULL,
[occupation_description] [nvarchar] (255) NULL,	
[creative_occupation Type] [nvarchar](12) NULL,
) on [PRIMARY]
GO

DROP TABLE IF EXISTS industry_descriptions
GO

CREATE TABLE [dbo].[industry_descriptions](
naics6[nvarchar](6) NULL,	
description[nvarchar](255) NULL,	
) on [PRIMARY]
GO


