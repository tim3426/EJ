USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_C046A69E_4F89_4B98_860D_144A626FBBC1]    Script Date: 02-Jul-19 1:21:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_C046A69E_4F89_4B98_860D_144A626FBBC1](
@INTERACTIONCATEGORY nvarchar(100) = null,
	@INTERACTIONSUBCATEGORY nvarchar(100) = null,
	@METHOD nvarchar(100) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;

declare @SDL_CBBA7545_B66F_44AC_AA24_D9C2F8CBC4EC table ([VALUE] uniqueidentifier,
	[LABEL] nvarchar(100));

insert into @SDL_CBBA7545_B66F_44AC_AA24_D9C2F8CBC4EC exec [dbo].[USP_SIMPLEDATALIST_INTERACTIONCATEGORY];
if (@INTERACTIONCATEGORY = '')
set @INTERACTIONCATEGORY = null;


declare @SDL_0EACC39B_07D1_4641_8774_E319559535A7 table ([VALUE] uniqueidentifier,
	[LABEL] nvarchar(100));

insert into @SDL_0EACC39B_07D1_4641_8774_E319559535A7 exec [dbo].[USP_SIMPLEDATALIST_INTERACTIONSUBCATEGORY];
if (@INTERACTIONSUBCATEGORY = '')
set @INTERACTIONSUBCATEGORY = null;

with
[ROOT_CTE] as (
select 	[V_QUERY_CONSTITUENT].[NAME] as [Name],
	[V_QUERY_CONSTITUENT].[LOOKUPID] as [Lookup],
	[V_QUERY_CONSTITUENT\Interactions].[STATUS] as [Status],
	[V_QUERY_CONSTITUENT].[ID] as [System record ID],
	[V_QUERY_CONSTITUENT\Interactions].[CATEGORY_TRANSLATION] as [Interaction Category],
	[V_QUERY_CONSTITUENT\Interactions].[SUBCATEGORY_TRANSLATION] as [Interaction Subcategory],
	[V_QUERY_CONSTITUENT\Prospect].[ID] as [Prospect\System record ID],
	[V_QUERY_CONSTITUENT\Interactions].[ID] as [Interactions\System record ID],
	[V_QUERY_CONSTITUENT\Interactions].[OBJECTIVE] as [Interaction Summary],
	[V_QUERY_CONSTITUENT\Interactions].[CONTACTMETHOD] as [Method],
	[V_QUERY_CONSTITUENT\Interactions].[EXPECTEDDATE] as [Expected Date],
	(case when [Exists in "PG: PG Prospect Constituency (Active) (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [PG Prospect],
	(case when [Exists in "PG: PG suspect constituency (active) (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [PG Suspect],
	(case when [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [PG],
	(case when [Exists in "OP: Sustainers All Active/ Held Status (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [Sustainer],
	[V_QUERY_CONSTITUENT\Prospect\Prospect Manager].[NAME] as [PM],
	[V_QUERY_CONSTITUENT\Prospect].[PROSPECTSTATUSCODE] as [Prospect\Prospect status],
[V_QUERY_CONSTITUENT].[ID] as [QUERYRECID]
from [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_CONSTITUENT]
inner join [dbo].[V_QUERY_INTERACTION] as [V_QUERY_CONSTITUENT\Interactions] on [V_QUERY_CONSTITUENT].[ID] = [V_QUERY_CONSTITUENT\Interactions].[CONSTITUENTID]
left outer join [dbo].[V_QUERY_PROSPECT] as [V_QUERY_CONSTITUENT\Prospect] on [V_QUERY_CONSTITUENT].[ID] = [V_QUERY_CONSTITUENT\Prospect].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [V_QUERY_CONSTITUENT\Prospect\Prospect Manager] on [V_QUERY_CONSTITUENT\Prospect].[PROSPECTMANAGERFUNDRAISERID] = [V_QUERY_CONSTITUENT\Prospect\Prospect Manager].[ID]
left join dbo.[UFN_ADHOCQUERYIDSET_5196D198_333C_4878_9B7E_087688164726]() as [Exists in "PG: PG Prospect Constituency (Active) (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "PG: PG Prospect Constituency (Active) (Ad-hoc Query)"_IDSET1].ID
left join dbo.[UFN_ADHOCQUERYIDSET_1D858B60_9094_41CB_A3BC_B9D036C9AEE3]() as [Exists in "PG: PG suspect constituency (active) (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "PG: PG suspect constituency (active) (Ad-hoc Query)"_IDSET1].ID
left join dbo.[UFN_ADHOCQUERYIDSET_F9007C17_434A_42AA_A4FD_5691B5FA0CF4]() as [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1].ID
left join dbo.[UFN_ADHOCQUERYIDSET_28C9BC0B_97A0_4585_8F9C_2EE435A03D40]() as [Exists in "OP: Sustainers All Active/ Held Status (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "OP: Sustainers All Active/ Held Status (Ad-hoc Query)"_IDSET1].ID
where [V_QUERY_CONSTITUENT\Interactions].[INTERACTIONCATEGORYID] in (N'6e257363-36d7-4299-9f71-ef556204de67', N'3516cccf-4877-4d4b-bd0b-a46c725cd969', N'75290e29-ec4d-400a-aa9e-8d76784e8fe1')
 and [V_QUERY_CONSTITUENT\Interactions].[INTERACTIONSUBCATEGORYID] in (N'2a57c0ba-4ba6-470e-95e4-c42e056ba628', N'38750c18-c07a-4887-a938-65c87f42cf79', N'38b6fd2f-6757-460e-bdfa-dc6d093ec888', N'dfca76e1-da3b-4d0b-967f-4a6587d0f911')
 and [V_QUERY_CONSTITUENT\Interactions].[STATUS] = N'Pending'
)


select top(@MAXROWS) [Name],
	[Lookup],
	[Status],
	[System record ID],
	[Interaction Category],
	[Interaction Subcategory],
	[Prospect\System record ID],
	[Interactions\System record ID],
	[Interaction Summary],
	[Method],
	[Expected Date],
	[PG Prospect],
	[PG Suspect],
	[PG],
	[Sustainer],
	[PM],
	[Prospect\Prospect status]
from [ROOT_CTE] as QUERYRESULTS
where ((@INTERACTIONCATEGORY is null or @INTERACTIONCATEGORY = '') or QUERYRESULTS.[Interaction Category] = (select top(1) [LABEL] from @SDL_CBBA7545_B66F_44AC_AA24_D9C2F8CBC4EC where [VALUE] = @INTERACTIONCATEGORY))
	and ((@INTERACTIONSUBCATEGORY is null or @INTERACTIONSUBCATEGORY = '') or QUERYRESULTS.[Interaction Subcategory] = (select top(1) [LABEL] from @SDL_0EACC39B_07D1_4641_8774_E319559535A7 where [VALUE] = @INTERACTIONSUBCATEGORY))
	and ((@METHOD is null or @METHOD = '') or QUERYRESULTS.[Method] = (select top(1) DESCRIPTION from dbo.[INTERACTIONTYPECODE] where ID = @METHOD))


