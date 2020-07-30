USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- This table eventually contains all the industry data.
-- It has to combine data from four different sources that are each coded differently.
-- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
-- This is the reason for the complexity. Each source has to be pre-processed before it is
-- finally moved into here.

DROP TABLE IF EXISTS [dbo].[Fact]
GO
CREATE TABLE [dbo].[Fact](
	[FactPK] [int] NOT NULL IDENTITY(1,1) ,
	[Source] [nvarchar](255) NULL, /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
	[Indicator][nvarchar] (256) NULL, /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
	[PNAICS] [nvarchar](7)  NULL, /* The standardised PNAICS industry code */
	[PNAICS description] [nvarchar] (255) NULL,
	[GeoName] [nvarchar](255) NULL,
	[Year] [nvarchar](10) NULL, /* EG '2010 M01' or '2018' or '2018 Q01'*/
	[Value] [float] NULL,
	CONSTRAINT [PK_CI_Fact] PRIMARY KEY CLUSTERED 
(
	[FactPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
 ON [PRIMARY]
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

-- Waystation file.
-- Data coded with Canada's IOICC system are placed here, unpivoted if necessary.
-- These data are preprocessed to create a Universal PNAICS code, described in DOCUMENTS/Uniform Coding.docx.
-- From here, these data are passed into the Fact table, using a view to convert the seven-character PNAICS codes 
-- These are either passed through or transformed with a coefficient (split factor) 
-- to yield the creative industry 4-digit NAICS codes underneath

DROP TABLE IF EXISTS [dbo].[IOICC flat]
GO
CREATE TABLE [dbo].[IOICC flat](
	[Source] [nvarchar](255) NOT NULL,
	[Indicator][nvarchar] (256) NOT NULL,
	[NAICS description] [nvarchar] (255)  NOT NULL,
	[PNAICS] [nvarchar] (8) NOT NULL,
	[geoName] [nvarchar](255) NOT NULL,
	[Year] [nvarchar](255) NOT NULL,
	[Value] [float] NULL
) ON [PRIMARY]
GO

-- Concordance mapping IOICC to NAICS. 
-- Covers both ANAICS4 and ANAICS2 mappings, which are mapped from different codes
-- ie we don't map the same IOICC code to both ANAICS2 and ANAICS4.

DROP TABLE IF EXISTS [dbo].[IOICC SPLITTER]
GO

CREATE TABLE [dbo].[IOICC SPLITTER](
	[PNAICS SOURCE] [nvarchar] (7) NOT NULL,
	[Coefficient] float NULL,
	[PNAICS TARGET][nvarchar] (7) NULL,
	[SOURCE DESCRIPTION][nvarchar] (255) NULL,
	[TARGET DESCRIPTION] [nvarchar](255) NULL,
) ON [PRIMARY]
GO

-- Creative Industry NAICS codes.

DROP TABLE IF EXISTS [dbo].[dimNewIndustry]
GO

CREATE TABLE [dbo].[dimNewIndustry](
	[PNAICS][nvarchar](7) NOT NULL,
	[NAICS6][nvarchar](7) NULL,
	[NAICS5][nvarchar](7) NULL,
	[NAICS4][nvarchar](7) NULL,
	[NAICS3][nvarchar](7) NULL,
	[NAICS2][nvarchar](7) NULL,
	[Creative Sector] [nvarchar] (255) NULL,
) ON [PRIMARY]
GO

-- Table for the census results

DROP TABLE IF EXISTS [dbo].[Census]
GO

CREATE TABLE [dbo].[Census](
geoName	 [nvarchar](255) NULL,
ANAICS4	 [nvarchar](5) NULL,
ANOCS4	 [nvarchar](5)NULL,
[Occupation Description] [nvarchar](255)NULL,	
[Industry Description] [nvarchar](255)NULL,
Value [float] 
) on [PRIMARY]
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


