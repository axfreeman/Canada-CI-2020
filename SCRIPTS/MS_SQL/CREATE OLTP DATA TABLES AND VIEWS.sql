USE [canada_ci_oltp]
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

DROP TABLE IF EXISTS [dbo].[fact]
GO
CREATE TABLE [dbo].[fact](
	[factpk] [int] NOT NULL IDENTITY(1,1) ,
	[source] [nvarchar](255) NULL, /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
	[indicator][nvarchar] (256) NULL, /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
	[pnaics] [nvarchar](7)  NULL, /* The standardised pnaics industry code */
	[pnaics_description] [nvarchar] (255) NULL,
	[geo_name] [nvarchar](255) NULL,
	[year] [nvarchar](10) NULL, /* EG '2010 M01' or '2018' or '2018 Q01'*/
	[value] [float] NULL,
	CONSTRAINT [pk_CI_fact] PRIMARY KEY CLUSTERED 
(
	[factpk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])
 ON [PRIMARY]
GO

-- Waystation file.
-- Data coded with Canada's IOICC system are placed here, unpivoted if necessary.
-- These data are preprocessed to create a Universal pnaics code, described in DOCUMENTS/Uniform Coding.docx.
-- From here, these data are passed into the fact table, using a view to convert the seven-character pnaics codes 
-- These are either passed through or transformed with a coefficient (split factor) 
-- to yield the creative industry 4-digit naics codes underneath

DROP TABLE IF EXISTS [dbo].[ioicc_flat]
GO
CREATE TABLE [dbo].[ioicc_flat](
	[source] [nvarchar](255) NOT NULL,
	[indicator][nvarchar] (256) NOT NULL,
	[naics_description] [nvarchar] (255)  NOT NULL,
	[pnaics] [nvarchar] (8) NOT NULL,
	[geo_name] [nvarchar](255) NOT NULL,
	[year] [nvarchar](255) NOT NULL,
	[value] [float] NULL
) ON [PRIMARY]
GO

-- Concordance mapping IOICC to naics. 
-- Covers both Anaics4 and Anaics2 mappings, which are mapped from different codes
-- ie we don't map the same IOICC code to both Anaics2 and Anaics4.

DROP TABLE IF EXISTS [dbo].[ioicc_splitter]
GO

CREATE TABLE [dbo].[ioicc_splitter](
	[pnaics_source] [nvarchar] (7) NOT NULL,
	[coefficient] float NULL,
	[pnaics_target][nvarchar] (7) NULL,
	[source_description][nvarchar] (255) NULL,
	[target_description] [nvarchar](255) NULL,
) ON [PRIMARY]
GO


-- Table for the census results

DROP TABLE IF EXISTS [dbo].[census]
GO

CREATE TABLE [dbo].[Census](
geo_name	 [nvarchar](255) NULL,
anaics4	 [nvarchar](5) NULL,
anocs4	 [nvarchar](5)NULL,
[occupation_description] [nvarchar](255)NULL,	
[industry_description] [nvarchar](255)NULL,
Value [float] 
) on [PRIMARY]
GO

DROP VIEW IF EXISTS [dbo].[creative_industries]
GO

CREATE VIEW [dbo].[creative_industries] AS

SELECT        
industries.value, 
industries.year, 
industries.indicator, 
industries.[standardised_province], 
industries.Source, 
industries.[creative_sector], 
industries.naics4, 
dbo.industry_descriptions.description

FROM            

(SELECT        
SUM(dbo.fact.value) AS value, 
dbo.fact.year, 
dbo.fact.indicator, 
dbo.dim_geography.[standardised_province], 
dbo.fact.Source, 
dbo.dim_industry.[creative_sector], 
dbo.fact.pnaics, 
dbo.dim_industry.pnaics AS ni_pnaics, 
dbo.dim_industry.naics6, 
dbo.dim_industry.naics5, 
dbo.dim_industry.naics4, 
dbo.dim_industry.naics3, 
dbo.dim_industry.naics2

FROM            
dbo.dim_geography RIGHT OUTER JOIN
dbo.fact ON dbo.dim_geography.geo_name_pk = dbo.fact.geo_name RIGHT OUTER JOIN
dbo.dim_industry ON dbo.fact.pnaics = dbo.dim_industry.pnaics

GROUP BY 
dbo.dim_industry.[creative_sector], 
dbo.fact.source, 
dbo.dim_geography.[standardised_province], 
dbo.fact.indicator, 
dbo.fact.geo_name, 
dbo.fact.year, 
dbo.fact.pnaics, 
dbo.dim_industry.pnaics, 
dbo.dim_industry.naics6, 
dbo.dim_industry.naics5, 
dbo.dim_industry.naics4, 
dbo.dim_industry.naics3, 
dbo.dim_industry.naics2, 
dbo.fact.value) AS industries LEFT OUTER JOIN
dbo.industry_descriptions ON industries.naics4 = dbo.industry_descriptions.naics6
GO



DROP VIEW IF EXISTS [dbo].[industries]
GO

CREATE VIEW [dbo].[industries]
AS
SELECT        
SUM(dbo.fact.value) AS value, 
dbo.fact.year, 
dbo.fact.indicator, 
dbo.dim_geography.[standardised_province], 
dbo.fact.source, 
dbo.dim_industry.[creative_sector], 
dbo.fact.pnaics, 
dbo.dim_industry.pnaics AS ni_pnaics,
dbo.dim_industry.naics6, 
dbo.dim_industry.naics5, 
dbo.dim_industry.naics4, 
dbo.dim_industry.naics3, 
dbo.dim_industry.naics2
FROM
dbo.dim_geography RIGHT OUTER JOIN
dbo.fact ON dbo.dim_geography.geo_name_pk = dbo.fact.geo_name RIGHT OUTER JOIN
dbo.dim_industry ON dbo.fact.pnaics = dbo.dim_industry.pnaics
GROUP BY 
dbo.dim_industry.[creative_sector], 
dbo.fact.Source, 
dbo.dim_geography.[standardised_province], 
dbo.fact.indicator, 
dbo.fact.geo_name, 
dbo.fact.year, 
dbo.fact.pnaics, 
dbo.dim_industry.pnaics, 
dbo.dim_industry.naics6, 
dbo.dim_industry.naics5, 
dbo.dim_industry.naics4, 
dbo.dim_industry.naics3, 
dbo.dim_industry.naics2, 
dbo.fact.value
GO


DROP VIEW IF EXISTS [dbo].[ioicc_flat_to_fact_converter]
GO

-- This view converts a small number of IOICC codes that are not reported at the 4 digit level,
-- to 4-digit codes. At this time, the only splits applied are those required for the Creative Industries
-- using the NESTA definition.
-- Further split factor definitions are possible.

CREATE VIEW [dbo].[ioicc_flat_to_fact_converter]
AS
SELECT        
dbo.[ioicc_flat].pnaics, 
dbo.[ioicc_splitter].[pnaics_target], 
dbo.[ioicc_flat].source, 
dbo.[ioicc_flat].indicator, 
dbo.[ioicc_flat].naics_description,
dbo.[ioicc_flat].geo_name, 
dbo.[ioicc_flat].year, 
dbo.[ioicc_flat].value * dbo.[ioicc_splitter].coefficient AS split_value, 
dbo.[ioicc_splitter].coefficient, 
dbo.[ioicc_flat].value
FROM dbo.[ioicc_flat] RIGHT OUTER JOIN
dbo.[ioicc_splitter] ON dbo.[ioicc_flat].pnaics = dbo.[ioicc_splitter].[pnaics_source]
GO

