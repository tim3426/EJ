SELECT
C.NAME
,C.LookupID as [Lookup ID]
,PP.Name as [Plan]
,I.CONTACTMETHOD as [Contact Method]
,I.OBJECTIVE as [Summary]
,I.CATEGORY_TRANSLATION as [Category]
,I.EXPECTEDDATE as [Expected Date]
,O.Name as [Owner]
,I.Comment as [Comment]
,O.ID as [Owner Record ID]
,C.CONSTITUENTID as [Constituent Record ID]
,OTEAM.BUSINESSUNIT as [Team]
,case when [I].[PROSPECTPLANID] is not null then 'True'
else 'False' end as [Ismove]
,I.ID as [Interaction Record ID]
,PP.ID as [Plan ID]
FROM V_QUERY_INTERACTIONALL I 
LEFT JOIN V_QUERY_PROSPECTPLAN as PP on I.PROSPECTPLANID = PP.ID
LEFT OUTER JOIN V_QUERY_CONSTITUENT [O] ON [O].ID = I.OWNERID
LEFT OUTER JOIN (
	SELECT
		[CONSTITUENT].[ID] [CONSTITUENTID],
		[DBO].[UFN_BUSINESSUNITCODE_GETDESCRIPTION](ORGANIZATIONPOSITION.BUSINESSUNITCODEID) [BUSINESSUNIT]
	FROM [DBO].[ORGANIZATIONHIERARCHY]
	INNER JOIN DBO.ORGANIZATIONPOSITION ON ORGANIZATIONPOSITION.ID = ORGANIZATIONHIERARCHY.ID
	LEFT OUTER JOIN DBO.ORGANIZATIONPOSITIONHOLDER ON ORGANIZATIONPOSITIONHOLDER.POSITIONID = ORGANIZATIONPOSITION.ID
	LEFT OUTER JOIN DBO.CONSTITUENT ON CONSTITUENT.ID = ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID
	WHERE ORGANIZATIONPOSITIONHOLDER.DATETO IS NULL
	) [OTEAM] ON O.[ID] = OTEAM.[CONSTITUENTID]

LEFT OUTER JOIN EJ_CONSTITUENT_HISTORY as C on [C].[CONSTITUENTID] = I.CONSTITUENTID
LEFT OUTER JOIN V_QUERY_ADDRESSEE_SALUTATION as [ADDSAL] on [C].[CONSTITUENTID] = [ADDSAL].[ID]
LEFT OUTER JOIN dbo.[UFN_ADHOCQUERYIDSET_F524CA2C_5E71_47ED_9049_71C79D1226F7]() as [Do Not Contact] on [C].[CONSTITUENTID] = [Do Not Contact].ID
LEFT OUTER JOIN dbo.[UFN_ADHOCQUERYIDSET_71B9837E_32F7_4D66_BBAC_53A36F3731F9]() as [Do Not Call] on [C].[CONSTITUENTID] = [Do Not Call].ID
LEFT OUTER JOIN dbo.[UFN_ADHOCQUERYIDSET_8367E7CC_AEA4_4C6A_B9D0_3CC48D753C9D]() as [Do Not Email] on [C].[CONSTITUENTID] = [Do Not Email].ID

WHERE I.STATUS = 'Pending'
AND CONTACTMETHOD in ('Report', 'Proposal')
AND C.DECEASED = 0 and C.INACTIVE = 0 
AND [Do Not Contact].ID is null
AND OTEAM.BUSINESSUNIT = 'Foundations'
AND I.EXPECTEDDATE < DATEADD(MONTH,6,GETDATE())