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
SELECT        
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
dbo.Fact.Value
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

