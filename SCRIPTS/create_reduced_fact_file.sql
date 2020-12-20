USE CANADA_CI_OLTP

DROP TABLE IF EXISTS [dbo].[dimSource]
GO

CREATE TABLE [dbo].[dimSource](
	[source_id] [smallint] IDENTITY(1,1) PRIMARY KEY,
    	[source name] varchar (255) NULL
) ON [PRIMARY]
GO

INSERT INTO dimSource ([source name])
SELECT DISTINCT source
FROM fact
where source is not null

USE CANADA_CI_OLTP

DROP TABLE IF EXISTS [dbo].[dimIndicator]
GO

CREATE TABLE [dbo].[dimIndicator](
	[indicator_id] [smallint] IDENTITY(1,1) PRIMARY KEY,
    	[indicator name] varchar (255) NULL
) ON [PRIMARY]
GO

INSERT INTO dimindicator  ([indicator name])
SELECT DISTINCT indicator
FROM fact
where indicator is not null

GO

CREATE OR ALTER VIEW [dbo].[Reduced_fact]
AS
SELECT dim_geography.geo_id, dbo.dimSource.source_id, dbo.dimIndicator.indicator_id, dbo.fact.factpk, dbo.fact.date, dbo.fact.value, dbo.fact.redacted
FROM  dbo.fact INNER JOIN
         dbo.dimSource ON dbo.fact.source = dbo.dimSource.[source name] INNER JOIN
         dbo.dimIndicator ON dbo.fact.indicator = dbo.dimIndicator.[indicator name] INNER JOIN
         dbo.dim_geography ON dbo.fact.geo_name_id = dbo.dim_geography.geo_name_id
GO

DROP TABLE IF EXISTS ReducedFact

SELECT *
into ReducedFact
  FROM [CANADA_CI_OLTP].[dbo].[Reduced_fact]
 
GO