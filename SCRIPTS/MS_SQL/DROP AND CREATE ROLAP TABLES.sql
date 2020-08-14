
USE [CANADA_CI_ROLAP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE IF EXISTS [dbo].[CreativeFact]
GO

CREATE TABLE [dbo].[CreativeFact](
	[Source] [nvarchar](20) not null,
	[Indicator]	[nvarchar] (20) not null,
	[GeoCode] [nvarchar](3) not NULL,
	[ANAICS4] [nvarchar](5) NULL,
	[ANAICS2] [nvarchar] (3)NULL,
	[ANOC4] [nvarchar](5) NULL,
	[Year] [nvarchar](4) NOT NULL,
	[Value] [float] NULL
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [dbo].[DimGeo]
GO

CREATE TABLE [dbo].[DimGeo](
	[GeoCode] [nvarchar](3) NOT NULL,
	[GeoName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DimGeo] PRIMARY KEY CLUSTERED 
(
	[GeoCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [dbo].[dimCreativeIndustry]
GO

CREATE TABLE [dbo].[dimCreativeIndustry](
	[ANAICS4] [nvarchar](5) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[iNESTA] [nvarchar](10) NULL,
	[iHiggs] [nvarchar](10) NULL,
	[iFreeman] [nvarchar](10) NULL,
	[Sector] [nvarchar](255) NULL,
 CONSTRAINT [PK_dimCreativeIndustry] PRIMARY KEY CLUSTERED 
(
	[ANAICS4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [dbo].[dimCreativeOccupation]
GO

CREATE TABLE [dbo].[dimCreativeOccupation](
	[ANOC4] [nvarchar](5) NOT NULL,
	[md_Occupation] [nvarchar](255) NULL,
	[oNESTA] [nvarchar](10) NULL,
	[oHiggs] [nvarchar](10) NULL,
	[oFreeman] [nvarchar] (10) NULL,
 CONSTRAINT [PK_dimCreativeOccupation] PRIMARY KEY CLUSTERED 
(
	[ANOC4] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [dbo].[dimSource]

-- TABLE contains all possible sources of the designated indicator

CREATE TABLE [dbo].[dimSource](
	[SourceCode] [nvarchar](20) NOT NULL,
	[SourceDescription] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_dimSource] PRIMARY KEY CLUSTERED 
(
	[SourceCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

DROP TABLE IF EXISTS [dbo].[dimIndicator]
GO

CREATE TABLE [dbo].[dimIndicator](
	[IndicatorCode] [nvarchar](20) NOT NULL,
	[IndicatorDescriptionn] [nvarchar](255) NULL,
 CONSTRAINT [PK_dimIndicator] PRIMARY KEY CLUSTERED 
(
	[IndicatorCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



