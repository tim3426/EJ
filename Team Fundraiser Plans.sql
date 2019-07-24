select  distinct 	P.[NAME] as [Prospect]
	,[V_QUERY_PROSPECT\Prospect Manager].[NAME] as [Prospect manager]
    ,[V_QUERY_PROSPECT\Prospect Plans].[NAME] as [Plan name]
    ,O.EXPECTEDASKAMOUNT as [Amount]
    ,C.AGE as [Age]
    ,SUM()
	,[V_QUERY_PROSPECT\Constituent].[KEYNAME] as [Sort name]
	,[V_QUERY_PROSPECT\Constituent\Spouse].[NAME] as [Spouse]
	,[TEAM].DESCRIPTION as [Team]
	,[V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[Last Step Stage] as [Stage]
	,[V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[Last Step Date] as [Last move date]
	,[V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[Last Step] as [Last move]
	,[V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[Next Step Date] as [Next move date]
	,[V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[Next Step] as [Next move]
	,[V_QUERY_PROSPECT\Constituent\Address (Primary)].[ADDRESSBLOCK] as [Address]
	,[V_QUERY_PROSPECT\Constituent\Address (Primary)].[CITY] as [City]
	,[V_QUERY_PROSPECT\Constituent\Address (Primary)].[STATEID_ABBREVIATION] as [State]
	,[V_QUERY_PROSPECT\Constituent\Address (Primary)].[POSTCODE] as [Zip]
	,[V_QUERY_PROSPECT\Constituent\Email (Primary)].[Email Address] as [Email]
	,(case when [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [PG]
	,P.[ID] as [PROSPECTID],
	,[V_QUERY_PROSPECT\Prospect Manager\Constituent\Fundraiser].[ID] as [FUNDRAISERID]
	,[V_QUERY_PROSPECT\Constituent].[LOOKUPID] as [LOOKUPID]
	,[V_QUERY_PROSPECT\Constituent].[ID] as [CONSTITEUNTID]
	,P.[NAME] as [Volunteer?]
	,[V_QUERY_PROSPECT\Prospect Manager].[ISACTIVE] as [PROSPECTMANAGERISACTIVE]
	,[V_QUERY_PROSPECT\Prospect Plans].[ID] as [PLANID]
	,[V_QUERY_PROSPECT\Prospect Manager].[ID] as [PROSPECTMGRID]
	,[V_QUERY_PROSPECT\Prospect Plans\Primary Manager].[NAME] as [Plan manager]
	,[V_QUERY_PROSPECT\Prospect Plans\Primary Manager].[ID] as [PRIMARYMGRID]
    ,P.[ID] as [QUERYRECID]

from [dbo].P as P
left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_PROSPECT\Constituent] on P.[ID] = [V_QUERY_PROSPECT\Constituent].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_PROSPECT\Constituent\Spouse] on [V_QUERY_PROSPECT\Constituent].[SPOUSE_ID] = [V_QUERY_PROSPECT\Constituent\Spouse].[ID]
inner join [dbo].[V_QUERY_PROSPECTPLAN] as PP on P.[ID] = PP.[PROSPECTID]
left outer join [dbo].[V_QUERY_CONSTITUENTAPPEAL] as [V_QUERY_PROSPECT\Constituent\Appeal Mailing] on [V_QUERY_PROSPECT\Constituent].[ID] = [V_QUERY_PROSPECT\Constituent\Appeal Mailing].[CONSTITUENTID]
left outer join [dbo].[V_QUERY_APPEAL] as [V_QUERY_PROSPECT\Constituent\Appeal Mailing\Appeals] on [V_QUERY_PROSPECT\Constituent\Appeal Mailing].[APPEALID] = [V_QUERY_PROSPECT\Constituent\Appeal Mailing\Appeals].[ID]
left outer join [dbo].[V_QUERY_APPEALBUSINESSUNIT] as [V_QUERY_PROSPECT\Constituent\Appeal Mailing\Appeals\Business units] on [V_QUERY_PROSPECT\Constituent\Appeal Mailing\Appeals].[ID] = [V_QUERY_PROSPECT\Constituent\Appeal Mailing\Appeals\Business units].[APPEALID]
left outer join [dbo].[USR_V_QUERY_PROSPECTPLANSTEPS] as [V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps] on PP.[ID] = [V_QUERY_PROSPECT\Prospect Plans\Next/Last Steps].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENTPRIMARYADDRESS] as [V_QUERY_PROSPECT\Constituent\Address (Primary)] on [V_QUERY_PROSPECT\Constituent].[ID] = [V_QUERY_PROSPECT\Constituent\Address (Primary)].[CONSTITUENTID]
left outer join [dbo].[USR_V_QUERY_PRIMARYEMAIL] as [V_QUERY_PROSPECT\Constituent\Email (Primary)] on [V_QUERY_PROSPECT\Constituent].[ID] = [V_QUERY_PROSPECT\Constituent\Email (Primary)].[CONSTITUENT ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [V_QUERY_PROSPECT\Prospect Manager] on P.[PROSPECTMANAGERFUNDRAISERID] = [V_QUERY_PROSPECT\Prospect Manager].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_PROSPECT\Prospect Manager\Constituent] on [V_QUERY_PROSPECT\Prospect Manager].[ID] = [V_QUERY_PROSPECT\Prospect Manager\Constituent].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [V_QUERY_PROSPECT\Prospect Manager\Constituent\Fundraiser] on [V_QUERY_PROSPECT\Prospect Manager\Constituent].[ID] = [V_QUERY_PROSPECT\Prospect Manager\Constituent\Fundraiser].[ID]
left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_PROSPECT\Prospect Plans\Primary Manager] on PP.[PRIMARYMANAGERFUNDRAISERID] = [V_QUERY_PROSPECT\Prospect Plans\Primary Manager].[ID]
left join dbo.[UFN_ADHOCQUERYIDSET_F9007C17_434A_42AA_A4FD_5691B5FA0CF4]() as [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1] on P.[ID] = [Exists in "PG: PG constituency (active) (Ad-hoc Query)"_IDSET1].ID
left outer join (
                           select
                           B.DESCRIPTION,
						   OPH.CONSTITUENTID						   						   
							
						   from [dbo].[ORGANIZATIONHIERARCHY] O
						   left outer join dbo.ORGANIZATIONPOSITION P on P.ID= o.ID
                           left outer join dbo.ORGANIZATIONPOSITIONHOLDER OPH on OPH.POSITIONID = O.ID
						   left outer join dbo.BUSINESSUNITCODE B on B.ID = P.BUSINESSUNITCODEID
						   where OPH.DATETO is null
						   and OPH.CONSTITUENTID is not null 
						   
                           ) [TEAM] on PP.[PRIMARYMANAGERFUNDRAISERID] = [TEAM].[CONSTITUENTID]  
left join V_QUERY_OPPORTUNITY as O on O.PROSPECTPLANID = PP.ID
 
where P.[PROSPECTSTATUSCODEID] in 
(N'49899170-d5be-448f-9fbb-45965ec0696f', --Accepted
N'3FBC0A51-43AF-4C07-9390-40F80D5BD897',--Connecting
N'D85B82BB-3638-4453-A82A-57FF4873B0EC',--Qualification
N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9')--Identified
 and PP.[HISTORICAL] = 0
)


select top(@MAXROWS) [Prospect],
	[Sort name],
	[Spouse],
	[Plan name],
	[Team],
	[Stage],
	[Last move date],
	[Last move],
	[Next move date],
	[Next move],
	[Address],
	[City],
	[State],
	[Zip],
	[Email],
	[PG],
	[PROSPECTID],
	[FUNDRAISERID],
	[LOOKUPID],
	[CONSTITEUNTID],
	[Volunteer?],
	[PROSPECTMANAGERISACTIVE],
	[PLANID],
	[PROSPECTMGRID],
	[Plan manager],
	[Prospect manager],
	[PRIMARYMGRID]
from [ROOT_CTE] as QUERYRESULTS
where ((@TEAM is null or @TEAM = '') or QUERYRESULTS.[Team] = (select distinct DESCRIPTION from dbo.[BUSINESSUNITCODE] where ID = @TEAM and Description in ('Major Gifts', 'Leadership', 'Foundations','Planned Gifts')))
	and ((@STAGE is null or @STAGE = '') or QUERYRESULTS.[Stage] LIKE  '%' + @STAGE + '%')
	and ((@PLANMANAGER is null or @PLANMANAGER = '') or QUERYRESULTS.[Plan manager] LIKE  '%' + @PLANMANAGER + '%')
	and ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')


