USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_24E24C74_32F8_4849_900C_72F5869E331B]    Script Date: 28-Aug-19 12:49:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_24E24C74_32F8_4849_900C_72F5869E331B](
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select distinct
R.Name,
R.Amount,
R.[EffectiveDate] as [Date],
R. Category,
Application,
R.REVENUEID as [Revenue Record ID],
C.CONSTITUENTID as [Constituent Record ID],
R.SplitID as [Split ID],
R.REVENUEID as [Base Currency ID]

from EJ_REVENUE_RECOGNITION as R
inner join EJ_CONSTITUENT_HISTORY as C on R.CONSTITUENTID = C.CONSTITUENTID
inner join [dbo].[V_QUERY_CONSTITUENCY] as CONSTITUENCY on CONSTITUENCY.CONSTITUENTID = R.CONSTITUENTID 
	and CONSTITUENCY.CONSTITUENCYDEFINITIONID = N'c819fceb-684d-4b10-af61-25fe6ce529f3' 
	and CONSTITUENCY.DATETO is null
where (C.FIRSTGIFT_DATE = R.[EffectiveDate] 
	or (CONSTITUENCY.DATEFROM between dateadd(day, -7, R.EFFECTIVEDATE) 
		and dateadd(day, 7, R.EFFECTIVEDATE)))
and R.Category <> 'Public Support'
and R.Application <> 'Recurring gift'
and R.EffectiveDate >= dateadd(year, -1, getdate())
)


select top(@MAXROWS) [Name],
	[Amount],
	[Date],
	[Category],
	[Application],
	[Revenue Record ID],
	[Constituent Record ID],
	[Split ID],
	[Base currency ID]
from [ROOT_CTE] as QUERYRESULTS


