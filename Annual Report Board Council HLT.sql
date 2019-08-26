USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_8D5188DF_4508_431B_9F26_2B738E08B7A4]    Script Date: 26-Aug-19 11:20:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_8D5188DF_4508_431B_9F26_2B738E08B7A4](
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
,case when [PG].ID is null then ''
    else 'PG'
    end as [PG]
,[PM].[NAME] as [Prospect manager]
,C.[NICKNAME] as [Nickname]
,SpouseC.[NICKNAME] as [Spouse nickname]
,[AddSal].[PRIMARYADDRESSEE] as [Primary Addressee]
,case when [Recognition].STATUS = 'Lapsed' then 'Reviewed'
    else 'Pending'
    end as [Status]
,case when Board.ID is null then ''
	else 'Board'
	end as [Board]
,case when Council.ID is null then ''
	else 'Council'
	end as [Council]
,case when HLT.ID is null then ''
	else 'HLT'
	end as [HLT]
,[Countable giving]
,[Recognition].ID as [Recognition ID]
,C.ID as [Constituent Record ID]
,N.[ID] as [Name Format Record ID]
,C.ID as [FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
,C.ID as [QUERYRECID]
from V_QUERY_CONSTITUENT as C
inner join
	(select CONSTITUENTID
	from
		(select distinct CONSTITUENTID 
		from V_QUERY_CONSTITUENCY 
		where CONSTITUENCYDEFINITIONID in (N'b998248e-820c-411a-bc86-68ef5b626258'
			, N'3f3eee49-0e88-4d02-ac4b-939b87729de9'
			, N'a1aeeb55-97ac-4430-9b9a-f2044e9f0a4c')
		and (V_QUERY_CONSTITUENCY.[DATEFROM] <= '2019-06-30')
		and ((V_QUERY_CONSTITUENCY.[DATETO] between '2018-07-01' and '2019-06-30')
		or (V_QUERY_CONSTITUENCY.[DATETO] is null))
		) as Constituents
	) as BoardCouncilHLT on BoardCouncilHLT.CONSTITUENTID = C.ID

left join 
	(select sum(EJ_REVENUE_RECOGNITION.AMOUNT) as [Countable giving]
	,EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
	where EFFECTIVEDATE between '2018-07-01' and '2019-06-30'
		and CATEGORY <> 'Planned Giving'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	) as R on R.CONSTITUENTID = C.ID
left join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [Recognition] on C.ID = [Recognition].[CONSTITUENTID]
left join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [N] on C.ID = [N].[CONSTITUENTID]
	AND [N].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
left join [dbo].[V_QUERY_PROSPECT] as P on C.ID = P.[ID] and P.[PROSPECTSTATUSCODEID] in (N'49899170-d5be-448f-9fbb-45965ec0696f', N'3fbc0a51-43af-4c07-9390-40f80d5bd897', N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9', N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
left join [dbo].[V_QUERY_FUNDRAISER] as PM on P.[PROSPECTMANAGERFUNDRAISERID] = [PM].[ID]
left join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [AddSal] on C.ID = [AddSal].[ID]
left join [dbo].[V_QUERY_CONSTITUENT] as SpouseC on SpouseC.ID = C.SPOUSE_ID
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Amicus] on C.ID = [Amicus].ID
left join dbo.[UFN_ADHOCQUERYIDSET_2D70B98E_F40D_408E_A7B8_D15A2E5C6548]() as [PG] on C.ID = [PG].ID
left join dbo.[UFN_ADHOCQUERYIDSET_5568D293_8A31_4905_9D3C_8DB227E20B9C]() as [Anonymous] on C.ID = [Anonymous].ID
left join dbo.[UFN_ADHOCQUERYIDSET_6D210163_1E62_4232_953D_5B944F911E87]() as [Board] on C.ID = [Board].ID
left join dbo.[UFN_ADHOCQUERYIDSET_437EE871_31B3_4E17_B560_3AE5C3F4DCFA]() as [Council] on C.ID = [Council].ID
left join dbo.[UFN_ADHOCQUERYIDSET_24221E6D_ED9F_4802_B2AA_D3801F6A836D]() as [HLT] on C.ID = [HLT].ID
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
	[Board],
	[Council],
	[HLT],
	[PG],
	[Constituent Record ID],
	[Name Format Record ID],
	[Recognition ID],
	[FY2019 Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')
	and ((@STATUS is null or @STATUS = '') or QUERYRESULTS.[Status] = @STATUS)


