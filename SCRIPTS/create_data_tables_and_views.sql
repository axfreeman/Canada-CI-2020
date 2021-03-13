USE canada_ci_oltp 

  -- This table ends up containing all the data.
  -- It has to combine data from four different sources that are each coded differently.
  -- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
  -- This is the reason for the complexity. Several sources have to be pre-processed before it is
  -- finally moved into here.
  DROP TABLE IF EXISTS fact
  CREATE TABLE fact (
    factpk int NOT NULL IDENTITY(1, 1),
    source nvarchar (255) NULL,    /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
    indicator nvarchar (256) NULL, /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
    pnaics_id nvarchar (7) NULL,   /* The standardised pnaics industry code: see 'Uniform Coding.docx' in DOCUMENTS folder */
    pnaics_description nvarchar (255) NULL,
    geo_name_id nvarchar (255) NULL,
	redacted nvarchar (1) NULL,	/* blank if not redacted, "x" if redacted, NULL if unspecified. Normally either "x" or NULL */
    date Date NULL,
    value float NULL
  )
  -- Waystation file.
  -- Data coded with Canada's IOICC system are placed here, unpivoted if necessary.
  -- These data are preprocessed to create a Universal pnaics code, described in DOCUMENTS/Uniform Coding.docx.
  -- From here, these data are passed into the fact table, using a view to convert the seven-character pnaics codes
  -- These are either passed through or transformed with a coefficient (split factor)
  -- to yield the creative industry 4-digit naics codes underneath
  DROP TABLE IF EXISTS ioicc_flat

  CREATE TABLE ioicc_flat (
    source nvarchar (255) NOT NULL,
    indicator nvarchar (256) NOT NULL,
    naics_description nvarchar (255) NOT NULL,
    pnaics_id nvarchar (8) NOT NULL,
    geo_name_id nvarchar (255) NOT NULL,
    date Date NOT NULL,
    value float NULL
  )

 
  -- Table for the census results
  DROP TABLE IF EXISTS census

  CREATE TABLE census (
    geo_name_id nvarchar (255) NULL,
    anaics4 nvarchar (5) NULL,
    anocs4 nvarchar (5) NULL,
    occupation_description nvarchar (255) NULL,
    industry_description nvarchar (255) NULL,
    Value float
  )

-- Temporary table to pre-process humungous P & H CSV file
DROP TABLE IF EXISTS temp_P_H
GO

CREATE TABLE temp_P_H (
REF_DATE Nvarchar(50) COLLATE Latin1_General_100_CI_AI_SC_UTF8,
GEO Nvarchar(50)COLLATE Latin1_General_100_CI_AI_SC_UTF8,
Labour_productivity_and_related_measures Nvarchar(50)COLLATE Latin1_General_100_CI_AI_SC_UTF8,
Industry Nvarchar(255)COLLATE Latin1_General_100_CI_AI_SC_UTF8,
UOM Nvarchar(50)COLLATE Latin1_General_100_CI_AI_SC_UTF8,
VALUE float
)


-- This table collects P & H rows that are not used
-- mainly for debugging purposes
-- (But the table has to be present until the data is loaded)

DROP TABLE IF EXISTS temp_P_H_unused


CREATE TABLE [dbo].[temp_P_H_unused](
	[REF_DATE] [nvarchar](50) NULL,
	[GEO] [nvarchar](50) NULL,
	[Labour_productivity_and_related_measures] [nvarchar](50) NULL,
	[Industry] [nvarchar](255) NULL,
	[UOM] [nvarchar](50) NULL,
	[VALUE] float
) ON [PRIMARY]

GO

  -- This view converts a small number of IOICC codes that are not reported at the 4 digit level,
  -- to 4-digit codes.At this time, the only splits applied are those required for the Creative Industries
  -- using the NESTA definition.
  -- Further split factor definitions are possible.
CREATE OR ALTER VIEW ioicc_flat_to_fact_converter AS
SELECT
  ioicc_flat.pnaics_id,
  ioicc_splitter.pnaics_target,
  ioicc_flat.source,
  ioicc_flat.indicator,
  ioicc_flat.naics_description,
  ioicc_flat.geo_name_id,
  ioicc_flat.date,
  ioicc_flat.value * ioicc_splitter.coefficient AS split_value,
  ioicc_splitter.coefficient,
  ioicc_flat.value
FROM
  ioicc_flat
  RIGHT OUTER JOIN ioicc_splitter ON ioicc_flat.pnaics_id = ioicc_splitter.pnaics_source

GO


-- full descriptions at all levels (NAICS 2,3, 4)
CREATE OR ALTER VIEW [dbo].[Descriptions Full]
AS
SELECT 
 dbo.dim_industry.pnaics_id, 
 dbo.industry_descriptions.description AS [NAICS2 Description], 
 industry_descriptions_1.description AS [NAICS3 Description], 
 industry_descriptions_3.description AS [NAICS4 Description], 
 industry_descriptions_2.description AS [Full Description]
FROM  dbo.dim_industry INNER JOIN
         dbo.industry_descriptions AS industry_descriptions_2 ON dbo.dim_industry.naics6 = industry_descriptions_2.naics6 LEFT OUTER JOIN
         dbo.industry_descriptions AS industry_descriptions_3 ON dbo.dim_industry.naics4 = industry_descriptions_3.naics6 LEFT OUTER JOIN
         dbo.industry_descriptions AS industry_descriptions_1 ON dbo.dim_industry.naics3 = industry_descriptions_1.naics6 LEFT OUTER JOIN
         dbo.industry_descriptions ON dbo.dim_industry.naics2 = dbo.industry_descriptions.naics6
GO

 /* -- This is the most detailed view, listing every record in the fact file beside its province,
  -- date, industry, creative sector and main industry.
  -- See the 'industries_summary' view, which groups by creative sector and main industry
 
CREATE OR ALTER VIEW [dbo].[All]
AS
SELECT 
 dbo.dim_geography.standardised_province, 
 dbo.fact.date,
 dbo.fact.value,
 dbo.fact.redacted,
 dbo.fact.indicator,
 dbo.fact.source,
 dbo.[Descriptions Full].[NAICS2 Description],
 dbo.[Descriptions Full].[NAICS3 Description],
 dbo.[Descriptions Full].[NAICS4 Description],
 dbo.[Descriptions Full].[Full Description]
FROM  dbo.fact LEFT OUTER JOIN
         dbo.[Descriptions Full] ON dbo.fact.pnaics_id = dbo.[Descriptions Full].pnaics_id LEFT OUTER JOIN
         dbo.dim_geography ON dbo.fact.geo_name_id = dbo.dim_geography.geo_name_id
GO
*/

-- Combines the Fact File with the Descriptions Full and dimGeography views, to create a complete flat file with everything in it
CREATE OR ALTER VIEW [dbo].[Fact Full]
AS
SELECT
 dbo.[Descriptions Full].[NAICS2 Description],
 dbo.[Descriptions Full].[NAICS3 Description],
 dbo.[Descriptions Full].[NAICS4 Description],
 dbo.[Descriptions Full].[Full Description],
 dbo.fact.source,
 dbo.fact.indicator,
 dbo.fact.geo_name_id,
 dbo.fact.date,
 dbo.fact.value,
 dbo.fact.redacted,
 dbo.fact.pnaics_id,
 dbo.dim_industry.main_industry,
 dbo.dim_industry.creative_sector, 
 dbo.dim_industry.early_warning_cultural_creative,
 dbo.dim_industry.four_digit_intensity,
 dbo.dim_industry.primary_csa_domain,
 dbo.dim_industry.primary_csa_subdomain,
 dbo.dim_geography.standardised_province
FROM  dbo.dim_industry RIGHT OUTER JOIN
         dbo.fact ON dbo.dim_industry.pnaics_id = dbo.fact.pnaics_id LEFT OUTER JOIN
         dbo.dim_geography ON dbo.fact.geo_name_id = dbo.dim_geography.geo_name_id LEFT OUTER JOIN
         dbo.[Descriptions Full] ON dbo.fact.pnaics_id = dbo.[Descriptions Full].pnaics_id
GO

-- this view separates out the industry codes from the industry descriptions
-- in the temp_P_H table

CREATE OR ALTER VIEW [dbo].[Trimmed_temp_P_H]
AS
SELECT
 REF_DATE,
 GEO,
 Labour_productivity_and_related_measures,
 UOM,
 VALUE,
 Industry,	  
 LEFT
 (
   'G'+
   Trim
   (
    ']BGS' from Substring
    (
      [Industry],
      CHARINDEX
      (
	   '[',
	   [Industry]
	  )+1,
	  CHARINDEX
	   (
	    ']',
	    [Industry]
	   )-CHARINDEX
	   (
		'[',
		[Industry]
	   )
	 )
    )+'000000',
   7
 )
 as Code
FROM  dbo.temp_P_H

GO




