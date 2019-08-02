select [Lookup ID]
,[Name]
,[Amount]
,[Date]
,[Description]
,[Appeal date]
,[Type]
,[Revenue ID]
,[Appeal ID]
,[Base currency ID]
,[QUERYRECID]
from
(select C.LOOKUPID as [Lookup ID]
    ,C.Name as [Name]
    ,R.[AMOUNT] as [Amount]
	,R.[EFFECTIVEDATE] as [Date]
	,A.Description as [Description]
    ,CA.DATESENT as [Appeal date]
	,R.TYPE as [Revenue category]
    ,ROW_NUMBER() OVER (PARTITION BY CA.CONSTITUENTID  ORDER BY CA.DATESENT desc) AS ROWNUMBER
	,R.[REVENUEID] as [Revenue ID]
    ,A.[ID] as [Appeal ID]
	,R.[REVENUEID] as [Base currency ID]
    ,R.[REVENUEID] as [QUERYRECID]
from EJ_REVENUE_RECOGNITION as R
inner join EJ_CONSTITUENT_HISTORY as C on R.CONSTITUENTID = C.CONSTITUENTID
	and C.PROSPECTSTATUS not in 
	('Accepted'
	,'Connecting'
	,'Identified'
	,'Qualification'
	)
inner join [V_QUERY_CONSTITUENTAPPEAL] as CA on CA.CONSTITUENTID = C.CONSTITUENTID and CA.DATESENT between dateadd(month,-3,R.EFFECTIVEDATE) and dateadd(day,-7,R.EFFECTIVEDATE)
inner join [V_QUERY_APPEAL] as A on A.ID = CA.APPEALID and A.APPEALCATEGORYCODE_DESCRIPTION in 
			('Acquisition'
			,'Appeal'
			,'Reinstate'
			,'Renewal'
			,'Sustainer Invite'
			,'Sustainer Upgrade'
			)
where R.EFFECTIVEDATE >= dateadd(month,-3,getdate())
	and R.APPEALCATEGORY = 'Unsolicited'
	and R.CATEGORY <> 'Planned Giving'
) as SUB
where ROWNUMBER = 1