use EJDEVO;

SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
delete from EJ_PROSPECT_PIPELINE_STATUS;

insert into EJ_PROSPECT_PIPELINE_STATUS (
PROSPECTID
, PLANID
, NARRATIVE
, OPPORTUNITYID
, PLANTYPE
, SORT
, PROSPECTSTATUS
, NAME
, PLANNAME
, CITY
, STATE
, PROSPECTMANAGER
, PRIMARYMANAGER
, BUDGETDATE
, BUDGETAMOUNT
, ASKDATE
, ASKAMOUNT
, REVENUECOMMITTED
, CURRENT_GIVING)
select 
PROSPECTID
, PLANID
, NARRATIVE
, OPPORTUNITYID
, PLANTYPE
, SORT
, PROSPECTSTATUS
, NAME
, PLANNAME
, CITY
, STATE
, PROSPECTMANAGER
, PRIMARYMANAGER
, BUDGETDATE
, BUDGETAMOUNT
, ASKDATE
, ASKAMOUNT
, REVENUECOMMITTED
, CURRENT_GIVING
FROM 
(

select
	*
from
(
select  distinct
	CONSTITUENT.CONSTITUENTID [PROSPECTID],
	PROSPECTPLAN.ID [PLANID],
	PROSPECTPLAN.NARRATIVE [NARRATIVE],
	OPPORTUNITIES.ID [OPPORTUNITYID],
	PROSPECTPLAN.TYPE as PLANTYPE,
 	CONSTITUENT.SORT_NAME [SORT],
	CONSTITUENT.PROSPECTSTATUS [PROSPECTSTATUS],
	CONSTITUENT.[NAME] as NAME,
	PROSPECTPLAN.NAME [PLANNAME],
	CONSTITUENT.[CITY] as CITY,
	CONSTITUENT.[STATE] as STATE,
	CONSTITUENT.PROSPECT_MANAGER as PROSPECTMANAGER,
	PRIMARY_MANAGER.[NAME] as PRIMARYMANAGER,
	OPPORTUNITIES.[EXPECTEDASKDATE] as BUDGETDATE,
	OPPORTUNITIES.[EXPECTEDASKAMOUNT] as BUDGETAMOUNT,
	OPPORTUNITIES.[ASKDATE] as ASKDATE,
	OPPORTUNITIES.[ASKAMOUNT] as ASKAMOUNT,
	OPPORTUNITIES.[REVENUECOMMITTED] as REVENUECOMMITTED,
	CONSTITUENT.ANNUAL_SUMMARY_CASH_YEAR_0 CURRENT_GIVING
from EJ_CONSTITUENT_HISTORY CONSTITUENT
inner join [dbo].[V_QUERY_PROSPECTPLAN] as PROSPECTPLAN on CONSTITUENT.[CONSTITUENTID] = PROSPECTPLAN.[PROSPECTID]
inner join [dbo].[V_QUERY_CONSTITUENT] as PRIMARY_MANAGER on PROSPECTPLAN.[PRIMARYMANAGERFUNDRAISERID] = PRIMARY_MANAGER.[ID]
left outer join [dbo].[V_QUERY_OPPORTUNITY] as OPPORTUNITIES on PROSPECTPLAN.[ID] = OPPORTUNITIES.[PROSPECTPLANID]
where PROSPECTPLAN.HISTORICAL = 0
	 and CONSTITUENT.DECEASED = 0
	 and CONSTITUENT.INACTIVE = 0
) SUB

) SUB2

ORDER BY NAME, SORT
	
OPTION (OPTIMIZE FOR UNKNOWN)