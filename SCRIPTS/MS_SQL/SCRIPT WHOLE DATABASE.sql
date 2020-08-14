USE [master]
GO
/****** Object:  Database [CANADA_CI_OLTP]    Script Date: 09/08/2020 15:26:59 ******/
CREATE DATABASE [CANADA_CI_OLTP]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CANADA_CI_OLTP', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\CANADA_CI_OLTP.mdf' , SIZE = 139264KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CANADA_CI_OLTP_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\CANADA_CI_OLTP_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [CANADA_CI_OLTP] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CANADA_CI_OLTP].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ARITHABORT OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET  MULTI_USER 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CANADA_CI_OLTP] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CANADA_CI_OLTP] SET QUERY_STORE = OFF
GO
USE [CANADA_CI_OLTP]
GO
/****** Object:  Table [dbo].[Fact]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fact](
	[FactPK] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](255) NULL,
	[Indicator] [nvarchar](256) NULL,
	[PNAICS] [nvarchar](7) NULL,
	[PNAICS description] [nvarchar](255) NULL,
	[GeoName] [nvarchar](255) NULL,
	[Year] [nvarchar](10) NULL,
	[Value] [float] NULL,
 CONSTRAINT [PK_CI_Fact] PRIMARY KEY CLUSTERED 
(
	[FactPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dimGeography]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimGeography](
	[geoName_PK] [nvarchar](255) NOT NULL,
	[Standardised Province] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dimIndustry]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimIndustry](
	[PNAICS] [nvarchar](7) NOT NULL,
	[NAICS6] [nvarchar](7) NULL,
	[NAICS5] [nvarchar](7) NULL,
	[NAICS4] [nvarchar](7) NULL,
	[NAICS3] [nvarchar](7) NULL,
	[NAICS2] [nvarchar](7) NULL,
	[Creative Sector] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[industryDescriptions]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[industryDescriptions](
	[NAICS6] [nvarchar](6) NULL,
	[Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Creative Industries]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [dbo].[Industries]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Industries]
AS
SELECT        SUM(dbo.Fact.Value) AS Value, dbo.Fact.Year, dbo.Fact.Indicator, dbo.dimGeography.[Standardised Province], dbo.Fact.Source, dbo.dimIndustry.[Creative Sector], dbo.Fact.PNAICS, dbo.dimIndustry.PNAICS AS NIPNAICS,
                          dbo.dimIndustry.NAICS6, dbo.dimIndustry.NAICS5, dbo.dimIndustry.NAICS4, dbo.dimIndustry.NAICS3, dbo.dimIndustry.NAICS2
FROM            dbo.dimGeography RIGHT OUTER JOIN
                         dbo.Fact ON dbo.dimGeography.geoName_PK = dbo.Fact.GeoName RIGHT OUTER JOIN
                         dbo.dimIndustry ON dbo.Fact.PNAICS = dbo.dimIndustry.PNAICS
GROUP BY dbo.dimIndustry.[Creative Sector], dbo.Fact.Source, dbo.dimGeography.[Standardised Province], dbo.Fact.Indicator, dbo.Fact.GeoName, dbo.Fact.Year, dbo.Fact.PNAICS, dbo.dimIndustry.PNAICS, 
                         dbo.dimIndustry.NAICS6, dbo.dimIndustry.NAICS5, dbo.dimIndustry.NAICS4, dbo.dimIndustry.NAICS3, dbo.dimIndustry.NAICS2, dbo.Fact.Value
GO
/****** Object:  Table [dbo].[IOICC flat]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IOICC flat](
	[Source] [nvarchar](255) NOT NULL,
	[Indicator] [nvarchar](256) NOT NULL,
	[NAICS description] [nvarchar](255) NOT NULL,
	[PNAICS] [nvarchar](8) NOT NULL,
	[geoName] [nvarchar](255) NOT NULL,
	[Year] [nvarchar](255) NOT NULL,
	[Value] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IOICC SPLITTER]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IOICC SPLITTER](
	[PNAICS SOURCE] [nvarchar](7) NOT NULL,
	[Coefficient] [float] NULL,
	[PNAICS TARGET] [nvarchar](7) NULL,
	[SOURCE DESCRIPTION] [nvarchar](255) NULL,
	[TARGET DESCRIPTION] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IOICC Flat to Fact converter]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [dbo].[Census]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Census](
	[geoName] [nvarchar](255) NULL,
	[ANAICS4] [nvarchar](5) NULL,
	[ANOCS4] [nvarchar](5) NULL,
	[Occupation Description] [nvarchar](255) NULL,
	[Industry Description] [nvarchar](255) NULL,
	[Value] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dimOccupations]    Script Date: 09/08/2020 15:26:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimOccupations](
	[ANOCS4] [nvarchar](5) NULL,
	[oNESTA] [nvarchar](5) NULL,
	[oHiggs] [nvarchar](5) NULL,
	[oFreeman] [nvarchar](8) NULL,
	[Occupation Description] [nvarchar](255) NULL,
	[Creative Occupation Type] [nvarchar](12) NULL
) ON [PRIMARY]
GO
USE [master]
GO
ALTER DATABASE [CANADA_CI_OLTP] SET  READ_WRITE 
GO
