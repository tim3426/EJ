USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_3A6C4BCB_E9AE_4BC2_BBF5_F2790C93283D]    Script Date: 20-Aug-19 1:40:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_3A6C4BCB_E9AE_4BC2_BBF5_F2790C93283D](
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
	else N.[FORMATTED] 
	end as [Listing]
,[Recognition].[RECOGNITIONLEVEL] as [Recognition level]
,[PM].[NAME] as [Prospect manager]
,C.[NICKNAME] as [Nickname]
,SpouseC.[NICKNAME] as [Spouse nickname]
,[AddSal].[PRIMARYADDRESSEE] as [Primary Addressee]
,case when [Recognition].STATUS = 'Lapsed' then 'Reviewed'
    else 'Pending'
    end as [Status]
,[FY2019].VALUE as [Countable giving]
,[Recognition].ID as [Recognition ID]
,C.ID as [Constituent Record ID]
,N.[ID] as [Name Format Record ID]
,C.ID as [FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
,C.ID as [QUERYRECID]
,case when IG.ID is null then ''
    else 'IG'
    end as [IG]
from V_QUERY_CONSTITUENT as C
inner join dbo.[UFN_ADHOCQUERYIDSET_F5DBD77C_9616_4A79_A245_647B511CADC5]() as PlannedGift on C.[ID] = PlannedGift.[ID]
left join V_QUERY_CONSTITUENCY as CONSTITUENCY on C.ID = CONSTITUENCY.CONSTITUENTID and CONSTITUENCY = 'PG Estate' and DATEFROM between '2018-07-01' and '2019-06-30'
left join [dbo].[V_QUERY_SMARTFIELD5DB8BA57106643289698C68A6037979C] as [FY2019] on C.[ID] = [FY2019].[ID]
left join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [Recognition] on C.ID = [Recognition].[CONSTITUENTID]
left join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [N] on C.ID = [N].[CONSTITUENTID]
	AND [N].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
left join [dbo].[V_QUERY_PROSPECT] as P on C.ID = P.[ID] and P.[PROSPECTSTATUSCODEID] in (N'49899170-d5be-448f-9fbb-45965ec0696f', N'3fbc0a51-43af-4c07-9390-40f80d5bd897', N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9', N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
left join [dbo].[V_QUERY_FUNDRAISER] as PM on P.[PROSPECTMANAGERFUNDRAISERID] = [PM].[ID]
left join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [AddSal] on C.ID = [AddSal].[ID]
left join [dbo].[V_QUERY_CONSTITUENT] as SpouseC on SpouseC.ID = C.SPOUSE_ID
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Amicus] on C.ID = [Amicus].ID
left join dbo.[UFN_ADHOCQUERYIDSET_5568D293_8A31_4905_9D3C_8DB227E20B9C]() as [Anonymous] on C.ID = [Anonymous].ID
left join dbo.[UFN_ADHOCQUERYIDSET_40D3DB72_42CF_410D_8FC6_1FC89936810B]() as [IG] on C.ID = IG.ID
where CONSTITUENCY.ID is null
)


select top(@MAXROWS) [Amicus],
	[Lookup ID],
	[Name],
	[Listing],
	[Anonymous],
	[Recognition level],
	[Prospect manager],
	[Nickname],
	[Spouse nickname],
	[Primary addressee],
	[Status],
	[Countable giving],
	[Recognition ID],
	[Constituent Record ID],
	[Name Format Record ID],
	[IG],
	[FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')
	and ((@STATUS is null or @STATUS = '') or QUERYRESULTS.[Status] = @STATUS)

order by [Name] asc
