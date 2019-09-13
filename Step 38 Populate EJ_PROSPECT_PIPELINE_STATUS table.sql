use EJDEVO;

SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
delete from EJ_PROSPECT_PIPELINE_STATUS;

insert into EJ_PROSPECT_PIPELINE_STATUS (
PROSPECTID
, PLANID
, NARRATIVE
, OPPORTUNITYID
, SORT
, PROSPECTSTATUS
, NAME
, PROSPECTMANAGER
, BUDGETDATE
, BUDGETAMOUNT
, ASKDATE
, ASKAMOUNT
,FIVEYEAR
,Lastinteractionsubcategory
,Lastinteractiondate
,Lastinteractionobjective
,LAST_VISIT_DATE

)
select 
	PROSPECTID,
	[PLANID],
	NARRATIVE,
	[OPPORTUNITYID],
 	[SORT],
	[STATUS],
	NAME,
	PROSPECTMANAGER,
	BUDGETDATE,
	BUDGETAMOUNT,
	ASKDATE,
	ASKAMOUNT,
	FIVEYEAR,
	Lastinteractionsubcategory,
	Lastinteractiondate,
	Lastinteractionobjective,
	LAST_VISIT_DATE

FROM 
(

select
	*
from
(
select  distinct
	CONSTITUENT.CONSTITUENTID as PROSPECTID,
	PROSPECTPLAN.ID [PLANID],
	PROSPECTPLAN.NARRATIVE [NARRATIVE],
	OPPORTUNITIES.ID [OPPORTUNITYID],
 	CONSTITUENT.SORT_NAME [SORT],
	CONSTITUENT.PROSPECTSTATUS [STATUS],
	CONSTITUENT.[NAME] as NAME,
	CONSTITUENT.PROSPECT_MANAGER as PROSPECTMANAGER,
	OPPORTUNITIES.[EXPECTEDASKDATE] as BUDGETDATE,
	OPPORTUNITIES.[EXPECTEDASKAMOUNT] as BUDGETAMOUNT,
	OPPORTUNITIES.[ASKDATE] as ASKDATE,
	OPPORTUNITIES.[ASKAMOUNT] as ASKAMOUNT,
	[5YEAR].[VALUE] as [FIVEYEAR],
	LAST_INTERACTION.SUBCATEGORY as [Lastinteractionsubcategory],
	LAST_INTERACTION.DATE as [Lastinteractiondate],
	LAST_INTERACTION.OBJECTIVE as [Lastinteractionobjective],
	LAST_VISIT.DATE as LAST_VISIT_DATE
from EJ_CONSTITUENT_HISTORY CONSTITUENT
inner join [dbo].[V_QUERY_PROSPECTPLAN] as PROSPECTPLAN on CONSTITUENT.[CONSTITUENTID] = PROSPECTPLAN.[PROSPECTID]
inner join [dbo].[V_QUERY_CONSTITUENT] as PRIMARY_MANAGER on PROSPECTPLAN.[PRIMARYMANAGERFUNDRAISERID] = PRIMARY_MANAGER.[ID]
left join [dbo].[V_QUERY_OPPORTUNITY] as OPPORTUNITIES on PROSPECTPLAN.[ID] = OPPORTUNITIES.[PROSPECTPLANID]
left join [dbo].[V_QUERY_ATTRIBUTEDCEFF2E9FDAB4674901120B7D8F75872] as [5YEAR] on CONSTITUENT.[CONSTITUENTID] = [5YEAR].[ID]
left join (
	select
		LastInteractions.CONSTITUENTID,
		LastInteractions.SUBCATEGORY,
		LastInteractions.DATE,
		LastInteractions.OBJECTIVE
		from (
			select
				INTERACTION.CONSTITUENTID,
				INTERACTION.DATE,
				INTERACTIONSUBCATEGORY.NAME SUBCATEGORY,
				INTERACTION.OBJECTIVE,
				ROW_NUMBER() OVER (PARTITION BY INTERACTION.CONSTITUENTID
												ORDER BY INTERACTION.CONSTITUENTID,
											INTERACTION.DATE desc) AS ROWNUMBER
			from V_QUERY_INTERACTIONALL INTERACTION
			inner join INTERACTIONSUBCATEGORY on INTERACTION.INTERACTIONSUBCATEGORYID = INTERACTIONSUBCATEGORY.ID
			inner join INTERACTIONTYPECODE on INTERACTION.INTERACTIONTYPECODEID = INTERACTIONTYPECODE.ID
			where INTERACTION.DATE < getDate()
				and INTERACTION.COMPLETED = 1
			) LastInteractions
			where LastInteractions.ROWNUMBER = 1
	) LAST_INTERACTION on CONSTITUENT.CONSTITUENTID = LAST_INTERACTION.CONSTITUENTID
left join (
	select
		CONSTITUENTID,
		DATE
		from
			(
			select
				INTERACTION.CONSTITUENTID,
				convert(char(10), INTERACTION.DATE, 101) DATE,
				ROW_NUMBER() OVER (PARTITION BY INTERACTION.CONSTITUENTID
									ORDER BY INTERACTION.CONSTITUENTID,
											INTERACTION.DATE desc) AS ROWNUMBER
			from V_QUERY_INTERACTIONALL INTERACTION
			inner join INTERACTIONSUBCATEGORY on INTERACTION.INTERACTIONSUBCATEGORYID = INTERACTIONSUBCATEGORY.ID
			inner join INTERACTIONTYPECODE on INTERACTION.INTERACTIONTYPECODEID = INTERACTIONTYPECODE.ID
			where INTERACTION.DATE < getDate()
				and INTERACTION.SUBCATEGORY_TRANSLATION = 'Visit'
				and INTERACTION.COMPLETED = 1
			) LastVisits
		where LastVisits.ROWNUMBER = 1
	) LAST_VISIT on CONSTITUENT.CONSTITUENTID = LAST_VISIT.CONSTITUENTID
	


where PROSPECTPLAN.HISTORICAL = 0
	 and CONSTITUENT.DECEASED = 0
	 and CONSTITUENT.INACTIVE = 0
) SUB

) SUB2

ORDER BY NAME, SORT
	
OPTION (OPTIMIZE FOR UNKNOWN)