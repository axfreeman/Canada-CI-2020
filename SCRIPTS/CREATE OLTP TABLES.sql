USE [CANADA_CI_OLTP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Yhis table eventually contains all the industry data.
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
	[ANAICS4] [nvarchar](5)  NULL, /* The basic four-digit industry code */
	[NAICS description] [nvarchar] (255) NULL,
	[IOICC6] [nvarchar] (6) NULL,
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
-- Data coded with Canada's IOICC system are unpivoted and placed here.
-- Then, the eight-character IOICC codes are converted to ANAICS and in certain cases, the data are transformed with a coefficient
-- using the [IOICC to NAICS] view because the IOICC code is insufficiently granular.

DROP TABLE IF EXISTS [dbo].[IOICC flat]
GO
CREATE TABLE [dbo].[IOICC flat](
	[Source] [nvarchar](255) NOT NULL,
	[Indicator][nvarchar] (256) NOT NULL,
	[NAICS description] [nvarchar] (255)  NOT NULL,
	[IOICC6] [nvarchar] (8) NOT NULL,
	[geoName] [nvarchar](255) NOT NULL,
	[Year] [nvarchar](255) NOT NULL,
	[Value] [float] NULL
) ON [PRIMARY]
GO

-- Concordance mapping IOICC to NAICS. 
-- Covers both ANAICS4 and ANAICS2 mappings, which are mapped from different codes
-- ie we don't map the same IOICC code to both ANAICS2 and ANAICS4.

DROP TABLE IF EXISTS [dbo].[IOICC to ANAICS]
GO

CREATE TABLE [dbo].[IOICC to ANAICS](
	[IOICC6] [nvarchar] (8) NOT NULL,
	[IOICC coefficient] float NULL,
	[ANAICS4][nvarchar] (255) NULL,
	[ANAICS2][nvarchar] (3) NULL,
	[IOICC descriptor] [nvarchar](255) NULL,
) ON [PRIMARY]
GO

-- Creative Industry NAICS codes.

DROP TABLE IF EXISTS [dbo].[dimIndustry]
GO

CREATE TABLE [dbo].[dimIndustry](
	[ANAICS4] [nvarchar](5) NULL,
	[iNESTA] [nvarchar] (5) NULL,
	[iHiggs] [nvarchar] (5) NULL,
	[iFreeman] [nvarchar] (8) NULL,
	[NAICS description] [nvarchar](255) NULL,
	[CI sector] [nvarchar] (255)NULL,
	[MI sector] [nvarchar] (255)NULL,
	[Creative Industry Type] [nvarchar] (255) NULL
) ON [PRIMARY]
GO

-- Main Industry NAICS codes.
-- The Main industries are identified by 2-digit NAICS codes
-- Some of these are 'pseudo-codes' because Statscan amalgamates 2 or more 2-digit codes
-- For example, A31 (in this application) represents sectors A31-33, which statscan
-- lumps together and calls 'manufacturing'

DROP TABLE IF EXISTS [dbo].[dimMainIndustries]
GO

CREATE TABLE [dbo].[dimMainIndustries](
	[ANAICS2] [nvarchar](3) NULL,
	[ANAICS4] [nvarchar] (5)NULL,
	[NAICS description] [nvarchar](255) NULL,
	[MI sector] [nvarchar] (255)NULL
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


