USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_A0D1B673_F4A5_497B_8113_9DAEB025E8B2]    Script Date: 08-Jul-19 2:09:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_A0D1B673_F4A5_497B_8113_9DAEB025E8B2](
@PROSPECTMANAGER nvarchar(154) = null,
	@TEAM nvarchar(100) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @PROSPECTMANAGER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@PROSPECTMANAGER, 0, null, 0);
declare @FISCALYEAR nvarchar(25) = convert(nvarchar(25),case when month(getDate()) > 6 then year(getDate())+1 else year(getDate())end);
declare @ENDDATE date = cast(@FISCALYEAR + '-' + '06' + '-' + '30' as date)
declare @STARTDATE date = cast(cast(convert(int,@FISCALYEAR) - 1 as nvarchar) + '-'+ '07' + '-' + '01' as date);

with
[ROOT_CTE] as (
select distinct P.id [PROSPECTID], 
	C.LOOKUPID [Lookup ID],
	C.[KEYNAME] as [Sort],
	P.[NAME] [Name],
	case when BOARD.[CONSTITUENCY] is not null then BOARD.CONSTITUENCY
	else CONSTITUENCY.CONSTITUENCY
	end as [Constituency],
	[MANAGER].[NAME] [Prospect Manager], 
	Manager.ID [PROSPECTMANAGERID],
	[PLAN].PRIMARYMANAGERFUNDRAISERID [PRIMARYID],
	[PRIMARY].[NAME] [Primary Manager],
	[PLAN].[NAME] as [Plan],
	P.[PROSPECTSTATUSCODE] as [Status],
	[PLAN].[NARRATIVE] as [Narrative],
	PLEDGE.[AMOUNT] as [Open Pledge],
	PLEDGE.PLEDGESUBTYPE as [Bookable],
	BUDGET.ACCRUAL_BUDGET as [Original Accrual Budget],
	BUDGET.CASH_BUDGET as [Original Cash Budget],
	O.[EXPECTEDASKDATE] as [Expected Budget Date],
	O.EXPECTEDASKAMOUNT as [Accrual Budget],
	BUDGET.[ACCRUAL_REFORECAST] as [Reforecast Accrual Budget],
	BUDGET.[CASH_REFORECAST] as [Reforecast Cash Budget],
	BUDGET.[ASKAMOUNT] as [Ask Amount static],
	BUDGET.ASKDATE as [Ask Date static],
	O.[ASKAMOUNT] as [Ask Amount actual],
	O.[ASKDATE] as [Ask Date actual],
	PLANS_RESTRICTION.RESTRICTIONS [Restrictions],
	ZEROYEAR_GIVING.AMOUNT [Current Fiscal Giving],
	FIRSTYEAR_GIVING.AMOUNT [Prior Fiscal Giving],
	SECONDYEAR_GIVING.AMOUNT [Two Years Prior Fiscal Giving],
	TOTAL_GIVING.AMOUNT [Total Giving],
	[PLAN].[ID] as [PLANID],
	O.[ID] as [OPPORTUNITYID],
	ADDRESS.[CITY] as [City],
	ADDRESS.[STATEID_ABBREVIATION] as [State],
	[5YEAR].[VALUE] as [5 Year Capacity],
	AFFINITY.[VALUE] as [Affinity],
	WEALTH.[VALUE] as [Estimated Wealth],
	INCLINATION.[VALUE] as [Inclination],
	RECENTRESEARCH.VALUE [Last Research Type],
	RECENTRESEARCH.STARTDATE [Last Research Date],
	LASTMOVE.[Last Step] as [Last Move],
	LASTMOVE.[Last Step Date] as [Last Move Date],
	LASTMOVE.[Last Step Owner] as [Last Move Owner],
	LASTMOVE.[Next Step] [Next Move],
	LASTMOVE.[Next Step Date] [Next Move Date],
	LASTMOVE.[Next Step Owner] [Next Move Owner],
	ADDRESS.[ADDRESSBLOCK] as [Address],
	ADDRESS.[POSTCODE] as [Zip],
	ADSAL.[PRIMARYADDRESSEE] as [Addressee],
	ADSAL.[PRIMARYSALUTATION] as [Salutation],
	EMAIL.[Email Address] as [Email],
	PROSPECTTEAM.BUSINESSUNIT [Team],
	O.[BASECURRENCYID] as [Revenue\Base currency ID],
	O.[BASECURRENCYID] as [Revenue\Base currency ID 1],
	O.[BASECURRENCYID] as [Revenue\Base currency ID 2],
	O.[BASECURRENCYID] as [Revenue\Base currency ID 3],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 1],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 2],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 3],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 4],
	O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 5],
C.[ID] as [QUERYRECID]
from V_QUERY_constituent C
	inner join V_query_prospect P on P.id = C.ID 
		and p.prospectstatuscode in (
			'Identified',
			'Accepted',
			'Qualification',
			'Connecting'
			)
	left outer join constituent MANAGER on MANAGER.id = P.PROSPECTMANAGERFUNDRAISERID
	left outer join (
			select CON.CONSTITUENCY, CON.CONSTITUENTID 
			from V_QUERY_constituency CON
			where CON.CONSTITUENCY in ('MG', 'IG', 'PS', 'FN') 
				and CON.DATETO is null 
			)CONSTITUENCY on CONSTITUENCY.CONSTITUENTID = C.ID
	left outer join (
			select CON.CONSTITUENCY, CON.CONSTITUENTID 
			from V_QUERY_constituency CON
			where CON.CONSTITUENCY in ('Board', 'Council') 
				and CON.DATETO is null 
			)BOARD on BOARD.CONSTITUENTID = C.ID
	left outer join V_QUERY_CONSTITUENTPRIMARYADDRESS [ADDRESS] on [ADDRESS].CONSTITUENTID = C.ID
	left outer join USR_V_QUERY_PRIMARYEMAIL EMAIL on EMAIL.[Constituent ID] = C.ID
	left outer join V_QUERY_ADDRESSEE_SALUTATION ADSAL on ADSAL.ID = C.ID
	inner join PROSPECTPLAN [PLAN] on [PLAN].PROSPECTID = P.ID and [PLAN].ISACTIVE = 1 and [PLAN].PROSPECTPLANTYPECODEID <> '98F61944-2900-46E5-8C95-C1EE8BDA4593'--'Earthjustice Action c(4)'
	left outer join opportunity O  on O.PROSPECTPLANID = [PLAN].ID
	left outer join EJ_BUDGET_AUDIT BUDGET on BUDGET.PLANID = [PLAN].ID and BUDGET.FISCAL_YEAR = @FISCALYEAR
	left outer join constituent [PRIMARY] on [PRIMARY].id = [PLAN].PRIMARYMANAGERFUNDRAISERID
	left outer join [dbo].[USR_V_QUERY_PROSPECTPLANSTEPS] as LASTMOVE on [PLAN].[ID] = [LASTMOVE].[ID]
	left outer join [dbo].[V_QUERY_MODELINGANDPROPENSITY_SIMPLE] as RESEARCH on C.[ID] = RESEARCH.[ID]
	left outer join [dbo].[V_QUERY_ATTRIBUTEDCEFF2E9FDAB4674901120B7D8F75872] as [5YEAR] on [RESEARCH].[ID] = [5YEAR].[ID]
	left outer join [dbo].[V_QUERY_ATTRIBUTE5357D4F4D90B4705B1E72D4FDD379F11] as [AFFINITY] on [RESEARCH].[ID] = [AFFINITY].[ID]
	left outer join [dbo].[V_QUERY_ATTRIBUTED6169246286E4F48936E75C15FFCF562] as [WEALTH] on [RESEARCH].[ID] = [WEALTH].[ID]
	left outer join [dbo].[V_QUERY_ATTRIBUTEC85D77A0E0C54C08AD316C31FCDB5B02] as [INCLINATION] on [RESEARCH].[ID] = [INCLINATION].[ID]
	left outer join [dbo].[V_QUERY_ATTRIBUTE6920A0A601734A38A098EE001E5D02F0] as [RECENTRESEARCH] on [RESEARCH].ID = [RECENTRESEARCH].ID
	left outer join ( --select total year giving
				select 
					R.CONSTITUENTID CONSTITUENTID,
					sum(R.AMOUNT) AMOUNT
				from EJ_REVENUE_RECOGNITION R
				where R.CATEGORY <> 'Planned Giving'
				group by R.CONSTITUENTID
				) TOTAL_GIVING on P.ID = TOTAL_GIVING.CONSTITUENTID
	left outer join ( --select current year giving
				select 
					R.CONSTITUENTID CONSTITUENTID,
					sum(R.AMOUNT) AMOUNT
				from EJ_REVENUE_RECOGNITION R
				where R.EFFECTIVEDATE between @STARTDATE and @ENDDATE
						and R.CATEGORY <> 'Planned Giving'
				group by R.CONSTITUENTID
				) ZEROYEAR_GIVING on P.ID = ZEROYEAR_GIVING.CONSTITUENTID
		left outer join ( --select past year giving
				select 
					R.CONSTITUENTID CONSTITUENTID,
					sum(R.AMOUNT) AMOUNT
				from EJ_REVENUE_RECOGNITION R
				where R.EFFECTIVEDATE between (dateadd(year,-1, @STARTDATE)) and (dateadd(year,-1, @ENDDATE))
					and R.CATEGORY <> 'Planned Giving'
				group by R.CONSTITUENTID
				) FIRSTYEAR_GIVING on P.ID = FIRSTYEAR_GIVING.CONSTITUENTID
	left outer join ( --select two years prior giving
				select 
					R.CONSTITUENTID CONSTITUENTID,
					sum(R.AMOUNT) AMOUNT
				from EJ_REVENUE_RECOGNITION R
				where R.EFFECTIVEDATE between (dateadd(year,-2, @STARTDATE)) and (dateadd(year,-2, @ENDDATE))
					and R.CATEGORY <> 'Planned Giving'
				group by R.CONSTITUENTID
				) SECONDYEAR_GIVING on P.ID = SECONDYEAR_GIVING.CONSTITUENTID
					left outer join (
                           select
                                  [CONSTITUENT].[ID] [CONSTITUENTID],
                                  [ORGANIZATIONHIERARCHY].[ID] [HIERARCHYID],
                                  [ORGANIZATIONHIERARCHY].[SEQUENCE] [SEQUENCE],
                                  case when [ORGANIZATIONPOSITIONHOLDER].[ID] is null then 1 else 0 end [ISVACANT],
                                  [ORGANIZATIONPOSITION].[NAME] [POSITION],
                                  [CONSTITUENT].[NAME] [POSITIONHOLDER],
                                  [dbo].[UFN_BUSINESSUNITCODE_GETDESCRIPTION](ORGANIZATIONPOSITION.BUSINESSUNITCODEID) [BUSINESSUNIT],
                                  [ORGANIZATIONPOSITIONHOLDER].[DATEFROM],
                                  [ORGANIZATIONPOSITIONHOLDER].[DATETO]
                           from [dbo].[ORGANIZATIONHIERARCHY]
                           inner join dbo.ORGANIZATIONPOSITION on ORGANIZATIONPOSITION.ID = ORGANIZATIONHIERARCHY.ID
                           left outer join dbo.ORGANIZATIONPOSITIONHOLDER on ORGANIZATIONPOSITIONHOLDER.POSITIONID = ORGANIZATIONPOSITION.ID
                           left outer join dbo.CONSTITUENT on CONSTITUENT.ID = ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID
                           where ORGANIZATIONPOSITIONHOLDER.DATETO is null
                           ) [PRIMARYTEAM] on [PLAN].[PRIMARYMANAGERFUNDRAISERID] = [PRIMARYTEAM].[CONSTITUENTID]

	left outer join (
                           select
                                  [CONSTITUENT].[ID] [CONSTITUENTID],
                                  [ORGANIZATIONHIERARCHY].[ID] [HIERARCHYID],
                                  [ORGANIZATIONHIERARCHY].[SEQUENCE] [SEQUENCE],
                                  case when [ORGANIZATIONPOSITIONHOLDER].[ID] is null then 1 else 0 end [ISVACANT],
                                  [ORGANIZATIONPOSITION].[NAME] [POSITION],
                                  [CONSTITUENT].[NAME] [POSITIONHOLDER],
                                  [dbo].[UFN_BUSINESSUNITCODE_GETDESCRIPTION](ORGANIZATIONPOSITION.BUSINESSUNITCODEID) [BUSINESSUNIT],
                                  [ORGANIZATIONPOSITIONHOLDER].[DATEFROM],
                                  [ORGANIZATIONPOSITIONHOLDER].[DATETO]
                           from [dbo].[ORGANIZATIONHIERARCHY]
                           inner join dbo.ORGANIZATIONPOSITION on ORGANIZATIONPOSITION.ID = ORGANIZATIONHIERARCHY.ID
                           left outer join dbo.ORGANIZATIONPOSITIONHOLDER on ORGANIZATIONPOSITIONHOLDER.POSITIONID = ORGANIZATIONPOSITION.ID
                           left outer join dbo.CONSTITUENT on CONSTITUENT.ID = ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID
                           where ORGANIZATIONPOSITIONHOLDER.DATETO is null
                           ) [PROSPECTTEAM] on [P].PROSPECTMANAGERFUNDRAISERID = [PROSPECTTEAM].[CONSTITUENTID]

	left outer join (
				select O.ID, R.AMOUNT, O.PROSPECTPLANID, R.PLEDGESUBTYPE
				from opportunity o 
				inner join V_QUERY_REVENUEOPPORTUNITY as LINK on O.ID = LINK.OPPORTUNITYID
				inner join V_QUERY_REVENUESPLIT as PLEDGE on LINK.ID = PLEDGE.ID
				inner join V_QUERY_REVENUE R on R.ID = PLEDGE.REVENUEID
				where R.TRANSACTIONTYPE = 'Pledge'
				and R.PLEDGEBALANCE > 0 
				) PLEDGE on PLEDGE.PROSPECTPLANID = [PLAN].ID

left outer join (
				select
				P.ID PLANID,
				RESTRICTIONS = replace(STUFF(
						(
						 select distinct '; ' + case when D.DESIGNATIONNAME like 'UN%' then 'Unrestricted' else D.DESIGNATIONNAME end
						 from V_QUERY_OPPORTUNITY O2 
						left outer join [V_QUERY_OPPORTUNITYDESIGNATION] as D on D.OPPORTUNITYID = O2.ID
						 where O2.ID = O.ID
						 for XML PATH ('')),1,2,''), '&amp;', '&')
				from V_QUERY_PROSPECTPLAN P
				left outer join V_QUERY_OPPORTUNITY O on P.ID = O.PROSPECTPLANID
				left outer join [V_QUERY_OPPORTUNITYDESIGNATION] as D on D.OPPORTUNITYID = O.ID
				) PLANS_RESTRICTION on [PLAN].ID = PLANS_RESTRICTION.PLANID
left outer join [dbo].[V_QUERY_OPPORTUNITYDESIGNATION] as [V_QUERY_CONSTITUENT\Prospect\Prospect Plans\Opportunities\Opportunity Designations] on O.[ID] = [V_QUERY_CONSTITUENT\Prospect\Prospect Plans\Opportunities\Opportunity Designations].[OPPORTUNITYID]
where PROSPECTTEAM.BUSINESSUNIT = 'Major Gifts'
	OR PRIMARYTEAM.BUSINESSUNIT = 'Major Gifts'
)	
	
	
	
select top(@MAXROWS) [PROSPECTID],
	[Lookup ID],
	[Sort],
	[Name],
	[Constituency],
	[Prospect Manager],
	[PROSPECTMANAGERID],
	[PRIMARYID],
	[Primary Manager],
	[Plan],
	[Status],
	[Narrative],
	[Open Pledge],
	[Bookable],
	[Original Accrual Budget],
	[Original Cash Budget],
	[Expected Budget Date],
	[Reforecast Accrual Budget],
	[Reforecast Cash Budget],
	[Ask Amount static],
	[Ask Date static],
	[Ask Amount actual],
	[Ask Date actual],
	[Restrictions],
	[Current Fiscal Giving],
	[Prior Fiscal Giving],
	[Two Years Prior Fiscal Giving],
	[Total Giving],
	[PLANID],
	[OPPORTUNITYID],
	[City],
	[State],
	[5 Year Capacity],
	[Affinity],
	[Estimated Wealth],
	[Inclination],
	[Last Research Type],
	[Last Research Date],
	[Last Move],
	[Last Move Date],
	[Last Move Owner],
	[Next Move],
	[Next Move Date],
	[Next Move Owner],
	[Address],
	[Zip],
	[Addressee],
	[Salutation],
	[Email],
	[Team],
	[Revenue\Base currency ID],
	[Prospect\Prospect Plans\Opportunities\BASECURRENCYID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect Manager] LIKE  '%' + @PROSPECTMANAGER + '%')
	and ((@TEAM is null or @TEAM = '') or QUERYRESULTS.[Team] = (select top(1) DESCRIPTION from dbo.[BUSINESSUNITCODE] where ID = @TEAM))


