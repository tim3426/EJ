USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_B81E3998_10B9_4D42_B972_A7B8C6C1A270]    Script Date: 10-Jul-19 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_B81E3998_10B9_4D42_B972_A7B8C6C1A270](
	@CONTEXTRECORDID uniqueidentifier,
	@CONTACTMETHOD nvarchar(100) = null,
	@OWNER nvarchar(154) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @OWNER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@OWNER, 0, null, 0);
with
[ROOT_CTE] as (
select  distinct
 	[C].[NAME] as [Prospect name],
	[PP].[NAME] as [Plan name],
	[I].[EXPECTEDDATE] as [Expected date],
	[I].[ACTUALDATE] as [Actual date],
	[I].[PROSPECTPLANSTEPSTAGE] as [Stage],
	[I].[OBJECTIVE] as [Objective],
	[I].[CATEGORY_TRANSLATION] as [Category],
	[I].[SUBCATEGORY_TRANSLATION] as [Subcategory],
	[I].[CONTACTMETHOD] as [Contact method],
	[I].[STATUS] as [Status],
	[I].[COMMENT] as [Comment],
	case when [PP].[PROSPECTID] is null then 'Activity' else 'Move' end as [Action type],
	[O].[NAME] as [Owner],
	[FR].[NAME] as [Prospect manager],
	case when [PG].[ID] is null then 'No' else 'Yes' end as [PG],
	case when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 1 and 29 then 'Overdue 1+ days' 
	     when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 30 and 59 then 'Overdue 30+ days'
		 when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 60 and 120 then 'Overdue 60+ days' 
		 when dateDiff(day, [I].[EXPECTEDDATE], getDate()) >=120 then 'Overdue 120+ days'
		 else 'Scheduled'
		 end as [Overdue?],
    [C].[CITY] as [City],
    [C].[STATE] as [State],
	[C].[CONSTITUENTID] as [CONSTITUENTID],
	[L].[ID] as [DOCUMENTID],
	[I].[ID] as [INTERACTIONID],
	[C].[CONSTITUENTID] as [PROSPECTID],
	[PP].[ID] as [PLANID],
	[O].[ID] as [OWNERID],
	[MANAGER].[ID] as [PRIMARYMANAGERID],
	[FR].[ID] as [PROSPECTMANAGERID],
	[C].[SORT_NAME] as [SORT],
	[I].[ID] as [QUERYRECID]
from [dbo].[V_QUERY_INTERACTIONALL] as [I]
left outer join [dbo].[EJ_CONSTITUENT_HISTORY] as [C] on [I].[CONSTITUENTID] = [C].[CONSTITUENTID]
left outer join [dbo].[V_QUERY_INTERACTION] as [CI] on [I].[ID] = [CI].[ID]
left outer join [dbo].[V_QUERY_INTERACTIONMEDIALINK] as [L] on [CI].[ID] = [L].[INTERACTIONID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [O] on [I].[OWNERID] = [O].[ID]
left outer join [dbo].[V_QUERY_PROSPECTPLAN] as [PP] on [I].[PROSPECTPLANID] = [PP].[ID]
left outer join [dbo].[V_QUERY_PROSPECT] as [PROSPECT] on [PP].[PROSPECTID] = [PROSPECT].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [FR] on [PROSPECT].[PROSPECTMANAGERFUNDRAISERID] = [FR].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [MANAGER] on [PP].[PRIMARYMANAGERFUNDRAISERID] = [MANAGER].[ID]
left join dbo.[UFN_ADHOCQUERYIDSET_F9007C17_434A_42AA_A4FD_5691B5FA0CF4]() as [PG] on [C].[CONSTITUENTID] = [PG].ID
where  [I].[STATUS] not in ('Completed', 'Declined', 'Cancelled', 'Canceled'))


select top(@MAXROWS) [Prospect name],
	[Plan name],
	[Expected date],
	[Actual date],
	[Stage],
	[Objective],
	[Category],
	[Subcategory],
	[Contact method],
	[Status],
	[Comment],
	[Action type],
	[Owner],
	[Prospect manager],
	[PG],
	[Overdue?],
    [City],
    [State],
	[INTERACTIONID],
	[PROSPECTID],
	[PLANID],
	[OWNERID],
	[PRIMARYMANAGERID],
	[PROSPECTMANAGERID],
	[SORT]
from [ROOT_CTE] as QUERYRESULTS
where ((@CONTACTMETHOD is null or @CONTACTMETHOD = '') or QUERYRESULTS.[Contact method] = (select top(1) DESCRIPTION from dbo.[INTERACTIONTYPECODE] where ID = @CONTACTMETHOD))
	and ((@OWNER is null or @OWNER = '') or QUERYRESULTS.[Owner] LIKE  '%' + @OWNER + '%')
	and (QUERYRESULTS.[OWNERID] = @CONTEXTRECORDID 
     or QUERYRESULTS.[PRIMARYMANAGERID] = @CONTEXTRECORDID
	 or QUERYRESULTS.[PROSPECTMANAGERID] = @CONTEXTRECORDID)  
order by [Expected date] desc
