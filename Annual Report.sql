select  distinct 	[V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions].[ISANONYMOUS] as [Anonymous],
,case when [Exists in "DR: Amicus Society (Ad-hoc Query)"_IDSET1].ID is null then ''
    else 'Amicus'
    end as [Amicus]
,C.[NAME] as [Name]
,C.[LOOKUPID] as [Lookup ID]
,C.[ID] as [Constituent Record ID],
,N.[ID] as [Name Format Record ID],
,N.[FORMATTED] as [Listing],
	[V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions].[RECOGNITIONLEVEL] as [Recognition level],
	(case when [Exists in "PG Constituency (Ad-hoc Query)"_IDSET1].ID is null then convert(bit, 0)
 else convert(bit, 1)
end) as [PG],
	[V_QUERY_CONSTITUENT\Prospect\Prospect Manager].[NAME] as [Prospect\Prospect Manager\Name],
	[V_QUERY_CONSTITUENT].[NICKNAME] as [Nickname],
	[V_QUERY_CONSTITUENT\Addressee and Salutation].[PRIMARYADDRESSEE] as [Addressee and Salutation\Primary addressee],
[V_QUERY_CONSTITUENT].[ID] as [QUERYRECID]
from EJ_CONSTITUENT_HISTORY as C
inner join EJ_REVENUE_RECOGNITION as R on R.CONSTITUENTID = [V_QUERY_CONSTITUENT].ID and R.EFFECTIVEDATE >= '2018-07-01'
inner join [dbo].[V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19] as [V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions] on R.CONSTITUENTID = [V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions].[CONSTITUENTID]
left outer join [dbo].[V_QUERY_CONSTITUENTNAMEFORMAT] as [V_QUERY_CONSTITUENT\Name Formats] on [V_QUERY_CONSTITUENT].[ID] = [V_QUERY_CONSTITUENT\Name Formats].[CONSTITUENTID]
	AND [V_QUERY_CONSTITUENT\Name Formats].NAMEFORMATTYPECODEID_TRANSLATION = 'Annual Report Listing'
left outer join [dbo].[V_QUERY_PROSPECT] as [V_QUERY_CONSTITUENT\Prospect] on [V_QUERY_CONSTITUENT].[ID] = [V_QUERY_CONSTITUENT\Prospect].[ID]
left outer join [dbo].[V_QUERY_FUNDRAISER] as [V_QUERY_CONSTITUENT\Prospect\Prospect Manager] on [V_QUERY_CONSTITUENT\Prospect].[PROSPECTMANAGERFUNDRAISERID] = [V_QUERY_CONSTITUENT\Prospect\Prospect Manager].[ID]
left outer join [dbo].[V_QUERY_ADDRESSEE_SALUTATION] as [V_QUERY_CONSTITUENT\Addressee and Salutation] on [V_QUERY_CONSTITUENT].[ID] = [V_QUERY_CONSTITUENT\Addressee and Salutation].[ID]
left join dbo.[UFN_ADHOCQUERYIDSET_C1B59FBE_5DE6_45CA_B2F0_1878701BC290]() as [Exists in "DR: Amicus Society (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "DR: Amicus Society (Ad-hoc Query)"_IDSET1].ID
left join dbo.[UFN_ADHOCQUERYIDSET_2D70B98E_F40D_408E_A7B8_D15A2E5C6548]() as [Exists in "PG Constituency (Ad-hoc Query)"_IDSET1] on [V_QUERY_CONSTITUENT].[ID] = [Exists in "PG Constituency (Ad-hoc Query)"_IDSET1].ID
--where ([V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions].[RECOGNITIONLEVEL] is not null and [V_QUERY_CONSTITUENT\Annual Report 2019 Recognitions].[RECOGNITIONLEVEL] <> '')
--order by [V_QUERY_CONSTITUENT].[Recognition level]