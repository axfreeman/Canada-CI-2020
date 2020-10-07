USE canada_ci_oltp -- the Geography dimension. Creates a standard geography that is valid throughout the time period covered
-- Mostly the same as today's province names with a couple of quirks, notably, all the
-- Northern provinces are amalgamated, because they don't exist throughout the whole period covered.
-- the Geo Names table. Gets converted to the ROLAP DimGeo table. Probably redundant
DROP TABLE IF EXISTS dim_geography
GO
  CREATE TABLE dim_geography(
    geo_name_pk nvarchar(255) NOT NULL,
    standardised_province nvarchar(255) NULL
  )
GO
  -- Creative Industry naics codes.
  -- see ../DOCUMENTS/Uniform Coding System/ for details
  DROP TABLE IF EXISTS dim_industry
GO
  CREATE TABLE dim_industry(
    pnaics nvarchar(7) NOT NULL,
    naics6 nvarchar(7) NULL,
    naics5 nvarchar(7) NULL,
    naics4 nvarchar(7) NULL,
    naics3 nvarchar(7) NULL,
    naics2 nvarchar(7) NULL,
    creative_sector nvarchar (255) NULL,
    main_industry nvarchar(255) NULL
  )
GO
  DROP TABLE IF EXISTS dim_occupations
GO
  CREATE TABLE dim_occupations(
    anocs4 nvarchar(5) NULL,
    o_nesta nvarchar(5) NULL,
    o_higgs nvarchar(5) NULL,
    o_freeman nvarchar(8) NULL,
    occupation_description nvarchar (255) NULL,
    creative_occupation nvarchar(12) NULL
  )
GO
  DROP TABLE IF EXISTS industry_descriptions
GO
  CREATE TABLE industry_descriptions(
    naics6 nvarchar(6) NULL,
    description nvarchar(255) NULL
  )
GO
  -- This table eventually contains all the industry data.
  -- It has to combine data from four different sources that are each coded differently.
  -- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
  -- This is the reason for the complexity.Each source has to be pre-processed before it is
  -- finally moved into here.
  DROP TABLE IF EXISTS fact
GO
  CREATE TABLE fact (
    factpk int NOT NULL IDENTITY(1, 1),
    source nvarchar (255) NULL,
    /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
    indicator nvarchar (256) NULL,
    /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
    pnaics nvarchar (7) NULL,
    /* The standardised pnaics industry code */
    pnaics_description nvarchar (255) NULL,
    geo_name nvarchar (255) NULL,
    year nvarchar (10) NULL,
    /* EG '2010 M01' or '2018' or '2018 Q01'*/
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
    pnaics nvarchar (8) NOT NULL,
    geo_name nvarchar (255) NOT NULL,
    year nvarchar (255) NOT NULL,
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
    geo_name nvarchar (255) NULL,
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
  ioicc_flat.pnaics,
  ioicc_splitter.pnaics_target,
  ioicc_flat.source,
  ioicc_flat.indicator,
  ioicc_flat.naics_description,
  ioicc_flat.geo_name,
  ioicc_flat.year,
  ioicc_flat.value * ioicc_splitter.coefficient AS split_value,
  ioicc_splitter.coefficient,
  ioicc_flat.value
FROM
  ioicc_flat
  RIGHT OUTER JOIN ioicc_splitter ON ioicc_flat.pnaics = ioicc_splitter.pnaics_source
GO
  DROP VIEW IF EXISTS [dbo].[dim_industry_with_descriptions]
GO
  CREATE VIEW [dbo].[dim_industry_with_descriptions] AS
SELECT
  dim_industry.pnaics,
  dim_industry.main_industry,
  dim_industry.creative_sector,
  industry_descriptions.description
FROM
  dim_industry
  LEFT OUTER JOIN industry_descriptions ON dim_industry.naics4 = industry_descriptions.naics6
GO
  -- This is the most detailed view, listing every record in the fact file beside its province,
  -- year, industry, creative sector and main industry.
  -- See the 'industries_summary' view, which groups by creative sector and main industry
  CREATE
  OR ALTER VIEW [dbo].[industries_full] AS
SELECT
  fact.value,
  fact.year,
  fact.indicator,
  dim_geography.standardised_province,
  fact.source,
  fact.pnaics,
  dim_industry_with_descriptions.main_industry,
  dim_industry_with_descriptions.creative_sector,
  dim_industry_with_descriptions.description
FROM
  dim_industry_with_descriptions
  INNER JOIN fact ON dim_industry_with_descriptions.pnaics = fact.pnaics
  LEFT OUTER JOIN dim_geography ON fact.geo_name = dim_geography.geo_name_pk
GO
  -- This summary view groups by all dimension fields, leaving out the
  -- detail provided by pnaics and description fields.
  -- it is thus more suited to quick visualizations since there are relatively
  -- fewer records, but cannot provide for drill-down
  CREATE
  OR ALTER VIEW [dbo].[industries_summary] AS
SELECT
  SUM(value) AS value,
  year,
  indicator,
  standardised_province AS province,
  source,
  main_industry,
  creative_sector
FROM
  industries_full
GROUP BY
  year,
  indicator,
  standardised_province,
  source,
  main_industry,
  creative_sector
GO
