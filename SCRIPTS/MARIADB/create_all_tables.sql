
-- the Geography dimension. Creates a standard geography that is valid throughout the time period covered
-- Mostly the same as today's province names with a couple of quirks, notably, all the
-- Northern provinces are amalgamated, because they don't exist throughout the whole period covered.
-- the Geo Names table. Gets converted to the ROLAP DimGeo table. Probably redundant

DROP TABLE IF EXISTS dim_geography
;

CREATE TABLE dim_geography(
	geo_name_pk varchar(255) NOT NULL,
	standardised_province varchar(255) NULL
) 
;


-- Creative Industry naics codes.

DROP TABLE IF EXISTS dim_industry
;

CREATE TABLE dim_industry(
	pnaics varchar(7) NOT NULL,
	naics6 varchar(7) NULL,
	naics5 varchar(7) NULL,
	naics4 varchar(7) NULL,
	naics3 varchar(7) NULL,
	naics2 varchar(7) NULL,
	creative_sector varchar (255) NULL,
	main_industry varchar (255) NULL
) 
;


DROP TABLE IF EXISTS dim_occupations
;

CREATE TABLE dim_occupations(
	anocs4 varchar(5) NULL,	
	o_nesta varchar(5) NULL,	
	o_higgs varchar(5) NULL,	
	o_freeman varchar(8) NULL,
	occupation_description varchar (255) NULL,	
	creative_occupation varchar(12) NULL
) 
;

DROP TABLE IF EXISTS industry_descriptions
;

CREATE TABLE industry_descriptions(
	naics6 varchar(6) NULL,	
	description varchar(255) NULL	
) 
;


-- This table eventually contains all the industry data.
-- It has to combine data from four different sources that are each coded differently.
-- and it contains a variety of indicators (jobs, real GDP, GDP, hours, possibly more as the project expands).
-- This is the reason for the complexity.Each source has to be pre-processed before it is
-- finally moved into here.

DROP TABLE IF EXISTS fact 
;
CREATE TABLE fact (
	 factpk int NOT NULL,
	 source varchar (255) NULL, /*the name of the source of the data eg 'cansim-0930333', 'census', etc*/
	 indicator varchar (256) NULL, /* what the numeric field measures, eg 'jobs', 'real GDP', etc */
	 pnaics varchar (7) NULL, /* The standardised pnaics industry code */
	 pnaics_description varchar (255) NULL,
	 geo_name varchar (255) NULL,
	 year varchar (10) NULL, /* EG '2010 M01' or '2018' or '2018 Q01'*/
	 value float NULL)
;

-- Table for the census results

DROP TABLE IF EXISTS census 
;

CREATE TABLE census (
	geo_name	 varchar (255) NULL,
	anaics4	 varchar (5) NULL,
	anocs4	 varchar (5)NULL,
	occupation_description varchar (255)NULL,	
	industry_description varchar (255)NULL,
Value float 
) 
;
