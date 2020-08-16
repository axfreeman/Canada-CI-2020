USE canada_ci_oltp 


-- This table eventually contains all the industry data.
-- It has to combine data from four different sources that are each coded differently.
-- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
-- This is the reason for the complexity.Each source has to be pre-processed before it is
-- finally moved into here.

DROP TABLE IF EXISTS fact 
GO
CREATE TABLE fact (
	 factpk int NOT NULL IDENTITY(1,1) ,
	 source nvarchar (255) NULL, /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
	 indicator nvarchar (256) NULL, /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
	 pnaics nvarchar (7) NULL, /* The standardised pnaics industry code */
	 pnaics_description nvarchar (255) NULL,
	 geo_name nvarchar (255) NULL,
	 year nvarchar (10) NULL, /* EG '2010 M01' or '2018' or '2018 Q01'*/
	 value float NULL)
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
	geo_name	 nvarchar (255) NULL,
	anaics4	 nvarchar (5) NULL,
	anocs4	 nvarchar (5)NULL,
	occupation_description nvarchar (255)NULL,	
	industry_description nvarchar (255)NULL,
Value float 
) 
GO

DROP VIEW IF EXISTS creative_industries 
GO

CREATE VIEW creative_industries AS

SELECT 
	industries.value, 
	industries.year, 
	industries.indicator, 
	industries.standardised_province , 
	industries.Source, 
	industries.creative_sector , 
	industries.naics4, 
	industry_descriptions.description

FROM 

(SELECT 
SUM(fact.value) AS value, 
	fact.year, 
	fact.indicator, 
	dim_geography.standardised_province , 
	fact.Source, 
	dim_industry.creative_sector , 
	fact.pnaics, 
	dim_industry.pnaics AS ni_pnaics, 
	dim_industry.naics6, 
	dim_industry.naics5, 
	dim_industry.naics4, 
	dim_industry.naics3, 
	dim_industry.naics2

FROM 
dim_geography 
RIGHT OUTER JOIN
	fact ON dim_geography.geo_name_pk = fact.geo_name 
RIGHT OUTER JOIN
	dim_industry ON fact.pnaics = dim_industry.pnaics
GROUP BY 
	dim_industry.creative_sector , 
	fact.source, 
	dim_geography.standardised_province , 
	fact.indicator, 
	fact.geo_name, 
	fact.year, 
	fact.pnaics, 
	dim_industry.pnaics, 
	dim_industry.naics6, 
	dim_industry.naics5, 
	dim_industry.naics4, 
	dim_industry.naics3, 
	dim_industry.naics2, 
	fact.value) AS industries 
	LEFT OUTER JOIN
industry_descriptions ON industries.naics4 = industry_descriptions.naics6
GO

DROP VIEW IF EXISTS industries 
GO

CREATE VIEW industries 
AS
SELECT 
SUM(fact.value) AS value, 
	fact.year, 
	fact.indicator, 
	dim_geography.standardised_province , 
	fact.source, 
	dim_industry.creative_sector , 
	fact.pnaics, 
	dim_industry.pnaics AS ni_pnaics,
	dim_industry.naics6, 
	dim_industry.naics5, 
	dim_industry.naics4, 
	dim_industry.naics3, 
	dim_industry.naics2
FROM
	dim_geography 
RIGHT OUTER JOIN
fact ON dim_geography.geo_name_pk = fact.geo_name 
RIGHT OUTER JOIN
dim_industry ON fact.pnaics = dim_industry.pnaics
GROUP BY 
	dim_industry.creative_sector , 
	fact.Source, 
	dim_geography.standardised_province , 
	fact.indicator, 
	fact.geo_name, 
	fact.year, 
	fact.pnaics, 
	dim_industry.pnaics, 
	dim_industry.naics6, 
	dim_industry.naics5, 
	dim_industry.naics4, 
	dim_industry.naics3, 
	dim_industry.naics2, 
	fact.value
GO


DROP VIEW IF EXISTS ioicc_flat_to_fact_converter 
GO

-- This view converts a small number of IOICC codes that are not reported at the 4 digit level,
-- to 4-digit codes.At this time, the only splits applied are those required for the Creative Industries
-- using the NESTA definition.
-- Further split factor definitions are possible.

CREATE VIEW ioicc_flat_to_fact_converter 
AS
SELECT 
	ioicc_flat .pnaics, 
	ioicc_splitter .pnaics_target , 
	ioicc_flat .source, 
	ioicc_flat .indicator, 
	ioicc_flat .naics_description,
	ioicc_flat .geo_name, 
	ioicc_flat .year, 
	ioicc_flat .value * ioicc_splitter .coefficient AS split_value, 
	ioicc_splitter .coefficient, 
	ioicc_flat .value
FROM ioicc_flat 
RIGHT OUTER JOIN
	ioicc_splitter ON ioicc_flat .pnaics = ioicc_splitter .pnaics_source 
GO

