USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_AE3B2A5D_C12D_4719_9DBE_A52C88864FB9]    Script Date: 20-Aug-19 1:42:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_AE3B2A5D_C12D_4719_9DBE_A52C88864FB9](
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select  distinct 
case when [Anonymous].ID is null then ''
    else 'Anonymous' 
    end as [Anonymous]
,case when [Amicus].ID is null then ''
    else 'Amicus'
    end as [Amicus]
,C.[NAME] as [Name]
,C.[LOOKUPID] as [Lookup ID]
,case when N.[FORMATTED] = '' then N.CUSTOMNAME
	else N.[FORMATTED] 
	end as [Listing]
,[Recognition].[RECOGNITIONLEVEL] as [Recognition level]
--,[PM].[NAME] as [Prospect manager]
,C.[NICKNAME] as [Nickname]
--,SpouseC.[NICKNAME] as [Spouse nickname]
,[AddSal].[PRIMARYADDRESSEE] as [Primary Addressee]
,case when [Recognition].STATUS = 'Lapsed' then 'Reviewed'
    else 'Pending'
    end as [Status]
--,[FY2019].VALUE as [Countable giving]
,R.[Countable giving]
,[Recognition].ID as [Recognition ID]
,C.ID as [Constituent Record ID]
,N.[ID] as [Name Format Record ID]
,C.ID as [FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
,C.ID as [QUERYRECID]
from V_QUERY_CONSTITUENT as C
inner join V_QUERY_CONSTITUENCY as CONSTITUENCY on C.ID = CONSTITUENCY.CONSTITUENTID and CONSTITUENCY = 'PG Estate'
inner join 
	(select sum(EJ_REVENUE_RECOGNITION.AMOUNT) as [Countable giving]
	,EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
	where EFFECTIVEDATE between '2018-07-01' and '2019-06-30'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	) as R on R.CONSTITUENTID = C.ID
--left join [dbo].[V_QUERY_SMARTFIELD5DB8BA57106643289698C68A6037979C] as [FY2019] on C.[ID] = [FY2019].[ID]
left join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [Recognition] on C.ID = [Recognition].[CONSTITUENTID]
left join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [N] on C.ID = [N].[CONSTITUENTID]
	AND [N].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
--left join [dbo].[V_QUERY_PROSPECT] as P on C.ID = P.[ID] and P.[PROSPECTSTATUSCODEID] in (N'49899170-d5be-448f-9fbb-45965ec0696f', N'3fbc0a51-43af-4c07-9390-40f80d5bd897', N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9', N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
--left join [dbo].[V_QUERY_FUNDRAISER] as PM on P.[PROSPECTMANAGERFUNDRAISERID] = [PM].[ID]
left join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [AddSal] on C.ID = [AddSal].[ID]
--left join [dbo].[V_QUERY_CONSTITUENT] as SpouseC on SpouseC.ID = C.SPOUSE_ID
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Amicus] on C.ID = [Amicus].ID
left join dbo.[UFN_ADHOCQUERYIDSET_5568D293_8A31_4905_9D3C_8DB227E20B9C]() as [Anonymous] on C.ID = [Anonymous].ID
)


select top(@MAXROWS) [Anonymous],
	[Amicus],
	[Name],
	[Lookup ID],
	[Listing],
	[Recognition level],
	[Nickname],
	[Primary addressee],
	[Status],
	[Countable giving],
	[Recognition ID],
	[Constituent Record ID],
	[Name Format Record ID],
	[FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS


