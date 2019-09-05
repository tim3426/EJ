USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_165CDAAB_612F_4CC7_871A_28FED8EB3A8D]    Script Date: 08-Jul-19 2:04:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_165CDAAB_612F_4CC7_871A_28FED8EB3A8D](
@PROSPECTMANAGER nvarchar(154) = null,
	@STATUS nvarchar(16) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @PROSPECTMANAGER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@PROSPECTMANAGER, 0, null, 0);
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
	when N.[FORMATTED] <> '' then N.[FORMATTED]
	else ALIAS.NAME
	end as [Listing]
,[Recognition].[RECOGNITIONLEVEL] as [Recognition level]
,case when [PG].ID is null then ''
    else 'PG'
    end as [PG]
,[PM].[NAME] as [Prospect manager]
,C.[NICKNAME] as [Nickname]
,SpouseC.[NICKNAME] as [Spouse nickname]
,[AddSal].[PRIMARYADDRESSEE] as [Primary Addressee]
,case when [Recognition].STATUS in ('Lapsed', 'Active') then 'Reviewed'
    else 'Pending'
    end as [Status]
,[Countable giving]
,[Recognition].ID as [Recognition ID]
,C.ID as [Constituent Record ID]
,N.[ID] as [Name Format Record ID]
,C.[ISORGANIZATION] as [Is organization]
,C.ID as [FY2019 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID]
,C.ID as [QUERYRECID]
,case when [Prospect manager] is not null then 'Managed'
	else null
	end as [Managed]
,case when IG.ID is null then ''
    else 'IG'
    end as [IG]
,ALIAS.ID as [Alias Record ID]
from V_QUERY_CONSTITUENT as C
inner join 
	(select sum(EJ_REVENUE_RECOGNITION.AMOUNT) as [Countable giving]
	,EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
	where EFFECTIVEDATE between '2018-07-01' and '2019-06-30'
		and CATEGORY <> 'Planned Giving'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	having sum(EJ_REVENUE_RECOGNITION.AMOUNT) >= 1000
	) as R on R.CONSTITUENTID = C.ID
left join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [Recognition] on R.CONSTITUENTID = [Recognition].[CONSTITUENTID]
left join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [N] on C.ID = [N].[CONSTITUENTID]
	AND [N].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
left join [dbo].[ALIAS] on C.ID = ALIAS.CONSTITUENTID 
	AND ALIAS.ALIASTYPECODEID = 'A4CBF120-5223-42E4-BB02-8040C494750F'
left join [dbo].[V_QUERY_PROSPECT] as P on C.ID = P.[ID] and P.[PROSPECTSTATUSCODEID] in 
	(N'49899170-d5be-448f-9fbb-45965ec0696f'
	, N'3fbc0a51-43af-4c07-9390-40f80d5bd897'
	, N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9'
	, N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
left join [dbo].[V_QUERY_FUNDRAISER] as PM on P.[PROSPECTMANAGERFUNDRAISERID] = [PM].[ID]
left join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [AddSal] on C.ID = [AddSal].[ID]
left join [dbo].[V_QUERY_CONSTITUENT] as SpouseC on SpouseC.ID = C.SPOUSE_ID
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Amicus] on C.ID = [Amicus].ID
left join dbo.[UFN_ADHOCQUERYIDSET_2D70B98E_F40D_408E_A7B8_D15A2E5C6548]() as [PG] on C.ID = [PG].ID
left join dbo.[UFN_ADHOCQUERYIDSET_5568D293_8A31_4905_9D3C_8DB227E20B9C]() as [Anonymous] on C.ID = [Anonymous].ID
left join dbo.[UFN_ADHOCQUERYIDSET_40D3DB72_42CF_410D_8FC6_1FC89936810B]() as [IG] on C.ID = IG.ID

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
	[Recognition ID],
	[Constituent Record ID],
	[Name Format Record ID],
	[Is organization],
	[IG],
	[Alias Record ID],
	[FY2019 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')
	and ((@STATUS is null or @STATUS = '') or QUERYRESULTS.[Status] = @STATUS)


