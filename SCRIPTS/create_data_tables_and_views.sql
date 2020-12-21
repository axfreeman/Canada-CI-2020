  -- This table ends up containing all the data.
  -- It has to combine data from four different sources that are each coded differently.
  -- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
  -- This is the reason for the complexity. Several sources have to be pre-processed before it is
  -- finally moved into here.
  DROP TABLE IF EXISTS fact
GO
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
GO
  -- Waystation file.
  -- Data coded with Canada's IOICC system are placed here, unpivoted if necessary.
  -- These data are preprocessed to create a Universal pnaics code, described in DOCUMENTS/Uniform Coding.docx.
  -- From here, these data are passed into the fact table, using a view to convert the seven-character pnaics codes
  -- These are either passed through or transformed with a coefficient (split factor)
  -- to yield the creative industry 4-digit naics codes underneath
  DROP TABLE IF EXISTS ioicc_flat
GO
  CREATE TABLE ioicc_flat (
    source nvarchar (255) NOT NULL,
    indicator nvarchar (256) NOT NULL,
    naics_description nvarchar (255) NOT NULL,
    pnaics_id nvarchar (8) NOT NULL,
    geo_name_id nvarchar (255) NOT NULL,
    date Date NOT NULL,
    value float NULL
  )
GO
  -- Concordance mapping IOICC to naics.
  -- Covers both Anaics4 and Anaics2 mappings, which are mapped from different codes
  -- ie we don't map the same IOICC code to both Anaics2 and Anaics4.
  DROP TABLE IF EXISTS ioicc_splitter
GO
  CREATE TABLE ioicc_splitter (
    pnaics_source nvarchar (7) NOT NULL,
    coefficient float NULL,
    pnaics_target nvarchar (7) NULL,
    source_description nvarchar (255) NULL,
    target_description nvarchar (255) NULL
  )
GO
  -- Table for the census results
  DROP TABLE IF EXISTS census
GO
  CREATE TABLE census (
    geo_name_id nvarchar (255) NULL,
    anaics4 nvarchar (5) NULL,
    anocs4 nvarchar (5) NULL,
    occupation_description nvarchar (255) NULL,
    industry_description nvarchar (255) NULL,
    Value float
  )
GO
  DROP VIEW IF EXISTS ioicc_flat_to_fact_converter
GO
  -- This view converts a small number of IOICC codes that are not reported at the 4 digit level,
  -- to 4-digit codes.At this time, the only splits applied are those required for the Creative Industries
  -- using the NESTA definition.
  -- Further split factor definitions are possible.
  CREATE VIEW ioicc_flat_to_fact_converter AS
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


DROP VIEW IF EXISTS [dbo].[dim_industry_with_descriptions]
GO

CREATE VIEW [dbo].[dim_industry_with_descriptions] AS
SELECT
  dim_industry.pnaics_id,
  dim_industry.main_industry,
  dim_industry.creative_sector,
  dim_industry.naics_aggregation_level,
  dim_industry.naics_description,
  industry_descriptions.description
FROM
  dim_industry
  LEFT OUTER JOIN industry_descriptions ON dim_industry.naics4 = industry_descriptions.naics6
GO
  -- This is the most detailed view, listing every record in the fact file beside its province,
  -- date, industry, creative sector and main industry.
  -- See the 'industries_summary' view, which groups by creative sector and main industry
  CREATE
  OR ALTER VIEW [dbo].[industries_full] AS
SELECT
  fact.value,
  fact.date,
  fact.indicator,
  dim_geography.standardised_province,
  fact.source,
  fact.pnaics_id,
  dim_industry_with_descriptions.main_industry,
  dim_industry_with_descriptions.creative_sector,
  dim_industry_with_descriptions.description
FROM
  dim_industry_with_descriptions
  INNER JOIN fact ON dim_industry_with_descriptions.pnaics_id = fact.pnaics_id
  LEFT OUTER JOIN dim_geography ON fact.geo_name_id = dim_geography.geo_name_id
GO
  -- This summary view groups by all dimension fields, leaving out the
  -- detail provided by pnaics and description fields.
  -- it is thus more suited to quick visualizations since there are relatively
  -- fewer records, but cannot provide for drill-down
  CREATE
  OR ALTER VIEW [dbo].[industries_summary] AS
SELECT
  SUM(value) AS value,
  date,
  indicator,
  standardised_province AS province,
  source,
  main_industry,
  creative_sector
FROM
  industries_full
GROUP BY
  date,
  indicator,
  standardised_province,
  source,
  main_industry,
  creative_sector
GO

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
GO

-- This table collects P & H rows that are not used
-- mainly for debugging purposes
-- (But the table has to be present until the data is loaded)

DROP TABLE IF EXISTS temp_P_H_unused
GO

CREATE TABLE [dbo].[temp_P_H_unused](
	[REF_DATE] [nvarchar](50) NULL,
	[GEO] [nvarchar](50) NULL,
	[Labour_productivity_and_related_measures] [nvarchar](50) NULL,
	[Industry] [nvarchar](255) NULL,
	[UOM] [nvarchar](50) NULL,
	[VALUE] float
) ON [PRIMARY]
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




