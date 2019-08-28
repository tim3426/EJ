USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_67345864_AA2A_4B89_8C46_76B02052E765]    Script Date: 28-Aug-19 1:21:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_67345864_AA2A_4B89_8C46_76B02052E765](
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select 
C.Name
,Amount
,EFFECTIVEDATE as [Date]
,TYPE
,APPLICATION
,C.[LOOKUPID] as [Lookup ID]
,REVENUEID as [Revenue ID]
,HH.MEMBERID as [Primary ID]
,case when C.DECEASED = 1 then 'Deceased'
	else ''
	end as [Deceased]
,C.CONSTITUENTID as [Constituent ID]
,case when C.CONSTITUENTID = HHM.MEMBERID then ''
	else 'Household'
	end as [Household]
,C.CONSTITUENTID as [Base currency ID]
from EJ_REVENUE_RECOGNITION as R
left join EJ_CONSTITUENT_HISTORY as C on C.CONSTITUENTID = R.CONSTITUENTID
left join dbo.[UFN_ADHOCQUERYIDSET_5A0B28FE_DB8F_465A_9222_251FF7B00D1B]() as P on P.ID = R.CONSTITUENTID
left join [V_QUERY_HOUSEHOLDMEMBERSHIP] as HHM on HHM.MEMBERID = R.CONSTITUENTID
left join [V_QUERY_HOUSEHOLDMEMBER] as HH on HH.GROUPID = HHM.GROUPID 
	and HH.ISPRIMARY = 1

where P.ID is null
and R.EFFECTIVEDATE > dateadd(year,-1,getdate())
)


select top(@MAXROWS) [Name],
	[Amount],
	[Date],
	[Type],
	[Application],
	[Lookup ID],
	[Revenue ID],
	[Primary ID],
	[Deceased],
	[Household],
	[Base currency ID]
from [ROOT_CTE] as QUERYRESULTS


