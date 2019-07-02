
select  distinct 	[C].[NAME] as [Name]
	,[C].[LookupID] as [Lookup ID]
	,[OWNER].[NAME] as [Owner]
	,[I].[ACTUALDATE] as [Date completed]
	,CONVERT(varchar, [I].[DATECHANGED], 101) AS [Last modified]
	,[I].[OBJECTIVE] as [Summary]
	,[I].[CONTACTMETHOD] as [Contact method]
	,[I].[CATEGORY_TRANSLATION] as [Category]
	,[I].[SUBCATEGORY_TRANSLATION] as [Subcategory]
	,[PROSPECTMANAGER].[NAME] as [Prospect manager]
	,[PRIMARYMANAGER].[NAME] as [Primary manager]
	,[PLAN].[NAME] as [Plan name]
	,[I].[ID] as [Interaction ID]
	,[C].[ID] as [Prospect ID]
	,[PLAN].[ID] as [Plan ID]
	,[I].[ID] as [QUERYRECID]
from [dbo].[V_QUERY_INTERACTIONALL] as [I]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [C] on [I].[CONSTITUENTID] = [C].[ID]
left outer join [dbo].[V_QUERY_PROSPECTPLAN] as [PLAN] on [I].[PROSPECTPLANID] = [PLAN].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [OWNER] on [I].[OWNERID] = [OWNER].[ID]
left outer join [dbo].[V_QUERY_PROSPECT] as [P] on [PLAN].[PROSPECTID] = [P].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [PROSPECTMANAGER] on [P].[PROSPECTMANAGERFUNDRAISERID] = [PROSPECTMANAGER].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [PRIMARYMANAGER] on [PLAN].[PRIMARYMANAGERFUNDRAISERID] = [PRIMARYMANAGER].[ID]
--left outer join [dbo].[V_QUERY_INTERACTIONPARTICIPANT] as [Participants] on [I].[ID] = [Participants].[INTERACTIONID]
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
left outer join
	( 
	select
    [CONSTITUENT].[ID] [CONSTITUENTID],
    [dbo].[UFN_BUSINESSUNITCODE_GETDESCRIPTION](ORGANIZATIONPOSITION.BUSINESSUNITCODEID) [BUSINESSUNIT]
    from [dbo].[ORGANIZATIONHIERARCHY]
    inner join dbo.ORGANIZATIONPOSITION on ORGANIZATIONPOSITION.ID = ORGANIZATIONHIERARCHY.ID
    left outer join dbo.ORGANIZATIONPOSITIONHOLDER on ORGANIZATIONPOSITIONHOLDER.POSITIONID = ORGANIZATIONPOSITION.ID
    left outer join dbo.CONSTITUENT on CONSTITUENT.ID = ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID
    ) [TEAM] on [TEAM].[CONSTITUENTID] = [OWNER].[ID]
where  [I].[STATUS] = N'Completed'
	and [PLAN].[PROSPECTID] is not null
    and [TEAM].[BUSINESSUNIT] = 'Planned Gifts'
	and [I].[ACTUALDATE] > DATEADD(MONTH,-12,GETDATE())