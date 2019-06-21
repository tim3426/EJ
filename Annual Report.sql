USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_165CDAAB_612F_4CC7_871A_28FED8EB3A8D]    Script Date: 19-Jun-19 2:29:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_165CDAAB_612F_4CC7_871A_28FED8EB3A8D](
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
,[RecognitionProgram].[RECOGNITIONLEVEL] as [Recognition level]
,case when [PG].ID is null then ''
    else 'PG'
    end as [PG]
,[PM].[NAME] as [Prospect manager]
,C.[NICKNAME] as [Nickname]
,SpouseC.[NICKNAME] as [Spouse nickname]
,[AddSal].[PRIMARYADDRESSEE] as [Primary Addressee]
,case when [RecognitionProgram].STATUS = 'Active' then 'Reviewed'
    else 'Pending'
    end as [Status]
,[Countable giving]
,[RecognitionProgram].ID as [Recognition Program Record ID]
,C.ID as [Constituent Record ID]
,N.[ID] as [Name Format Record ID]
,C.ID as [FY2019 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID]
,C.ID as [QUERYRECID]
from V_QUERY_CONSTITUENT as C
inner join 
	(select sum(EJ_REVENUE_RECOGNITION.AMOUNT) as [Countable giving]
	,EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
	where EFFECTIVEDATE >= '2018-07-01'
		and CATEGORY <> 'Planned Giving'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	) as R on R.CONSTITUENTID = C.ID
inner join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [RecognitionProgram] on R.CONSTITUENTID = [RecognitionProgram].[CONSTITUENTID]
left outer join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [N] on C.ID = [N].[CONSTITUENTID]
	AND [N].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
left outer join [dbo].[V_QUERY_PROSPECT] as P on C.ID = P.[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as PM on P.[PROSPECTMANAGERFUNDRAISERID] = [PM].[ID]
left outer join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [AddSal] on C.ID = [AddSal].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as SpouseC on SpouseC.ID = C.SPOUSE_ID
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Amicus] on C.ID = [Amicus].ID
left join dbo.[UFN_ADHOCQUERYIDSET_2D70B98E_F40D_408E_A7B8_D15A2E5C6548]() as [PG] on C.ID = [PG].ID
left join dbo.[UFN_ADHOCQUERYIDSET_5568D293_8A31_4905_9D3C_8DB227E20B9C]() as [Anonymous] on C.ID = [Anonymous].ID

)


select top(@MAXROWS) [Anonymous],
	[Amicus],
	[Name],
	[Lookup ID],
	[Listing],
	[Recognition level],
	[PG],
	[Prospect manager],
	[Nickname],
	[Spouse nickname],
	[Primary addressee],
	[Status],
	[Countable giving],
	[Recognition Program Record ID],
	[Constituent Record ID],
	[Name Format Record ID],
	[FY2019 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS


