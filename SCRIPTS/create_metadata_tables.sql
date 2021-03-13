USE canada_ci_oltp 
-- the Geography dimension. Creates a standard geography that is valid throughout the time period covered
-- Mostly the same as today's province names with a couple of quirks, notably, all the
-- Northern provinces are amalgamated, because they don't exist throughout the whole period covered.
-- the Geo Names table. Gets converted to the ROLAP DimGeo table. Probably redundant
DROP TABLE IF EXISTS dim_geography
GO
  CREATE TABLE dim_geography(
	geo_id [smallint] IDENTITY(1,1) PRIMARY KEY,
    geo_name_id nvarchar(255) NOT NULL,
    standardised_province nvarchar(255) NULL
  )
GO
  -- Creative Industry naics codes.
  -- see ../DOCUMENTS/Uniform Coding System/ for details
  DROP TABLE IF EXISTS dim_industry
GO
  CREATE TABLE dim_industry(
    pnaics_id nvarchar(7) NOT NULL,
    naics6 nvarchar(7) NULL,
    naics5 nvarchar(7) NULL,
    naics4 nvarchar(7) NULL,
    naics3 nvarchar(7) NULL,
    naics2 nvarchar(7) NULL,
    creative_sector nvarchar (255) NULL,
	early_warning_cultural_creative nvarchar (255) NULL,
	proximity nvarchar(255) NULL,
	four_digit_intensity float,
	primary_csa_domain nvarchar(255) NULL,
	primary_csa_subdomain nvarchar(255) NULL,
    main_industry nvarchar(255) NULL,
	naics_aggregation_level nvarchar(15) NULL,
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