CREATE VIEW [dbo].[CODED MI NEW]
AS
SELECT dbo.[Standardised MI Fact].Source, dbo.[Standardised MI Fact].Indicator, dbo.GeoNames.GeoName, dbo.MINAICS.[MI sector], dbo.[Standardised MI Fact].Value, dbo.[Standardised MI Fact].Year
FROM     dbo.[Standardised MI Fact] INNER JOIN
                  dbo.GeoNames ON dbo.[Standardised MI Fact].GeoCode = dbo.GeoNames.GeoCode INNER JOIN
                  dbo.MINAICS ON dbo.[Standardised MI Fact].ANAICS2 = dbo.MINAICS.ANAICS2
GO