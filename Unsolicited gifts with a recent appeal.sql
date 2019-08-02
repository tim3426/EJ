select  distinct R.[AMOUNT] as [Amount]
	,R.[EFFECTIVEDATE] as [Date]
	,R.[REVENUEID] as [Revenue ID]
	,R.[REVENUEID] as [Base currency ID]
    ,R.[REVENUEID] as [QUERYRECID]
from EJ_REVENUE_RECOGNITION as R
left join EJ_CONSTITUENT_HISTORY as C on R.CONSTITUENTID = C.CONSTITUENTID
inner join [V_QUERY_CONSTITUENTAPPEAL] as A on R.CONSTITUENTID = A.CONSTITUENTID and A.DATEADDED >= dateadd(month,-3,EFFECTIVEDATE)
where EFFECTIVEDATE >= dateadd(month,-3,getdate())
	and APPEALCATEGORY = 'Unsolicited'
	and CATEGORY <> 'Planned Giving'
	and C.PROSPECTSTATUS not in 
    ('Accepted'
    ,'Connecting'
    ,'Identified'
    ,'Qualification')