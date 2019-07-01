
select  distinct 	[C].[NAME] as [Prospect name],
	[PLAN].[NAME] as [Plan name],
	[I].[EXPECTEDDATE] as [Expected date],
	[I].[ACTUALDATE] as [Actual date],
	[I].[PROSPECTPLANSTEPSTAGE] as [Stage],
	[I].[OBJECTIVE] as [Objective],
	[I].[CATEGORY_TRANSLATION] as [Category],
	[I].[SUBCATEGORY_TRANSLATION] as [Subcategory],
	[I].[CONTACTMETHOD] as [Contact method],
	[I].[STATUS] as [Status],
	[I].[COMMENT] as [Comment],
	case when [PLAN].[PROSPECTID] is null then 'Activity' else 'Move' end as [Action type],
	[OWNER].[NAME] as [Owner],
	[PROSPECTMANAGER].[NAME] as [Prospect manager],
	case when [PG].[ID] is null then 'No' else 'Yes' end as [PG],
	case when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 1 and 29 then 'Overdue 1+ days' 
	     when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 30 and 59 then 'Overdue 30+ days'
		 when dateDiff(day, [I].[EXPECTEDDATE], getDate()) between 60 and 120 then 'Overdue 60+ days' 
		 when dateDiff(day, [I].[EXPECTEDDATE], getDate()) >=120 then 'Overdue 120+ days'
		 else 'Scheduled'
		 end as [Overdue?],
	[I].[ID] as [INTERACTIONID],
	[C].[ID] as [PROSPECTID],
	[PLAN].[ID] as [PLANID],
	[OWNER].[ID] as [OWNERID],
	[PRIMARYMANAGER].[ID] as [PRIMARYMANAGERID],
	[PROSPECTMANAGER].[ID] as [PROSPECTMANAGERID],
	[C].[KEYNAME] as [SORT],
[I].[ID] as [QUERYRECID]
from [dbo].[V_QUERY_INTERACTIONALL] as [I]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [C] on [I].[CONSTITUENTID] = [C].[ID]
left outer join [dbo].[V_QUERY_PROSPECTPLAN] as [PLAN] on [I].[PROSPECTPLANID] = [PLAN].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [OWNER] on [I].[OWNERID] = [OWNER].[ID]
left outer join [dbo].[V_QUERY_PROSPECT] as [P] on [PLAN].[PROSPECTID] = [P].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [PROSPECTMANAGER] on [P].[PROSPECTMANAGERFUNDRAISERID] = [PROSPECTMANAGER].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [PRIMARYMANAGER] on [PLAN].[PRIMARYMANAGERFUNDRAISERID] = [PRIMARYMANAGER].[ID]
left join dbo.[UFN_ADHOCQUERYIDSET_F9007C17_434A_42AA_A4FD_5691B5FA0CF4]() as [PG] on [C].[ID] = [PG].ID
left outer join (
				select  distinct
				 	min([P].[STARTDATE]) as [DATE],
					[P].[ID] as [PLANID],
					[PROSPECT].[ID] as [PROSPECTID]
				from [dbo].[V_QUERY_PROSPECTPLAN] as [P]
				left outer join [dbo].[V_QUERY_PROSPECT] as [PROSPECT] on [P].[PROSPECTID] = [PROSPECT].[ID]
				where [P].[HISTORICAL] = 0
				group by 
					[P].[ID], 
					[PROSPECT].[ID]
				) [MINPLAN] ON [P].[ID] = [MINPLAN].[PROSPECTID]
where  [I].[STATUS] = N'Completed'
	and [PLAN].[ID] is not null
--	and ([I].[DATE] >= [MINPLAN].[DATE] or [I].[ACTUALDATE] >= [MINPLAN].[DATE] or [I].[EXPECTEDDATE] >= [MINPLAN].[DATE])
-- and [PLAN].[HISTORICAL] = 0 -- to remove
-- and [C].[NAME] = 'Energy Foundation'
