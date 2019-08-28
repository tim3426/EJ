USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_0B62BF71_70E1_43BF_9BB1_AE7690A582F6]    Script Date: 28-Aug-19 12:41:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_0B62BF71_70E1_43BF_9BB1_AE7690A582F6](
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select R.[NAME] as [Name],
	R.[AMOUNT] as [Amount],
	R.[CATEGORY] as [Revenue Category],
	R.[TYPE] as [Type],
	R.[APPLICATION] as [Application],
	R.[REVENUEID] as [System record ID],
	R.[CONSTITUENTID] as [Constituent\System record ID],
	R.[SPLITID] as [APPID],
	R.[SPLITID] as [Split ID],
	R.[EFFECTIVEDATE] as [DATE],
	[CONSTITUENCY].[DATEFROM] as [Constituent\Constituencies\Date from],
	[CONSTITUENCY].[DATETO] as [Constituent\Constituencies\Date to],
	C.[LOOKUPID] as [Lookup ID],
	case when CONSTITUENCY.CONSTITUENCY = 'Board' then 'Board' 
	when CONSTITUENCY.CONSTITUENCY = 'MG' then 'Major Giving'
	when CONSTITUENCY.CONSTITUENCY = 'IG' then 'Intermediate Giving'
	when CONSTITUENCY.CONSTITUENCY = 'PS' then 'Public Support'
	when CONSTITUENCY.CONSTITUENCY = 'FN' then 'Foundations'
	else null
	end as CONSTITUENCY,
	R.[REVENUEID] as [Base currency ID]
from [dbo].[EJ_REVENUE_RECOGNITION] as R
inner join [EJ_CONSTITUENT_HISTORY] as C on R.[CONSTITUENTID] = C.[CONSTITUENTID]
inner join (
				select CON.DATEFROM, CON.DATETO, CON.CONSTITUENTID, CON.CONSTITUENCY,
				ROW_NUMBER() OVER (PARTITION BY CON.CONSTITUENTID ORDER BY CON.CONSTITUENTID, CON.DATEFROM desc) AS ROWNUMBER
				from [dbo].[V_QUERY_CONSTITUENCY] as [CON]
				where CON.CONSTITUENCY in ('IG','PS','MG','FN','Board')
				and CON.DATETO is null
				)CONSTITUENCY on R.[CONSTITUENTID] = [CONSTITUENCY].[CONSTITUENTID]

where 
	
R.CATEGORY <> 
	(case when CONSTITUENCY.CONSTITUENCY = 'Board' then 'Board' 
	when CONSTITUENCY.CONSTITUENCY = 'MG' then 'Major Giving'
	when CONSTITUENCY.CONSTITUENCY = 'IG' then 'Intermediate Giving'
	when CONSTITUENCY.CONSTITUENCY = 'PS' then 'Public Support'
	when CONSTITUENCY.CONSTITUENCY = 'FN' then 'Foundations'
	else null
	end)
and R.APPLICATION <> 'Planned gift'
and R.[EFFECTIVEDATE] > [CONSTITUENCY].[DATEFROM]
and R.[EFFECTIVEDATE] > dateadd(M,-3,getdate()) 
)


select top(@MAXROWS)
	[Lookup ID],
	[Name],
	[Amount],
	[Date],
	[Revenue Category],
	[Type],
	[Application],
	[CONSTITUENCY],
	[Constituent\Constituencies\Date from],
	[Constituent\Constituencies\Date to],
	[System record ID],
	[Constituent\System record ID],
	[Base currency ID],
	[Split ID],
	[APPID]
from [ROOT_CTE] as QUERYRESULTS


