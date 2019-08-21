USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_A0D1B673_F4A5_497B_8113_9DAEB025E8B2]    Script Date: 21-Aug-19 12:20:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_A0D1B673_F4A5_497B_8113_9DAEB025E8B2](
@PROSPECTMANAGER nvarchar(154) = null,
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

select distinct C.CONSTITUENTID as [PROSPECTID]
	,C.LOOKUPID [Lookup ID]
	,C.[SORT_NAME] as [Sort]
	,C.[NAME] [Name]
	,C.PRIMARY_CONSTITUENCY as [Constituency]
	,C.PROSPECT_MANAGER AS [Prospect Manager]
	,[PRIMARY].[NAME] [Primary Manager]
	,[PLAN].[NAME] as [Plan]
	,C.PROSPECTSTATUS as [Status]
	,[PLAN].[NARRATIVE] as [Narrative]
	,PLEDGE.[AMOUNT] as [Open Pledge]
	,PLEDGE.PLEDGESUBTYPE as [Bookable]
	,BUDGET.ACCRUAL_BUDGET as [Original Accrual Budget]
	,BUDGET.CASH_BUDGET as [Original Cash Budget]
	,O.[EXPECTEDASKDATE] as [Expected Budget Date]
	,O.EXPECTEDASKAMOUNT as [Accrual Budget]
	,BUDGET.[ACCRUAL_REFORECAST] as [Reforecast Accrual Budget]
	,BUDGET.[CASH_REFORECAST] as [Reforecast Cash Budget]
	,BUDGET.[ASKAMOUNT] as [Ask Amount]
	,BUDGET.ASKDATE as [Ask Date]
	,O.[ASKAMOUNT] as [Ask Amount actual]
	,O.[ASKDATE] as [Ask Date actual]
	,PLANS_RESTRICTION.RESTRICTIONS [Restrictions]
	,C.ANNUAL_SUMMARY_CASH_YEAR_0_NO_PG AS [Current Fiscal Giving]
	,C.ANNUAL_SUMMARY_CASH_YEAR_1_NO_PG AS [Prior Fiscal Giving]
	,C.ANNUAL_SUMMARY_CASH_YEAR_2_NO_PG AS [Two Years Prior Fiscal Giving]
	,C.LIFETIME_CASH_GIVING AS [Total Giving]
	,[PLAN].[ID] as [PLANID]
	,O.[ID] as [OPPORTUNITYID]
	,C.[CITY] as [City]
	,C.[STATE] as [State]
	,C.EJ_FIVE_YEAR_CAPACITY as [5 Year Capacity]
	,C.EJ_AFFINITY as [Affinity]
	,C.EJ_EST_WEALTH as [Estimated Wealth]
	,C.EJ_INCLINATION as [Inclination]
	--,RECENTRESEARCH.VALUE as [Last Research Type]
	--,RECENTRESEARCH.STARTDATE as [Last Research Date]
	,LASTMOVE.[Objective] as [Last Move]
	,LASTMOVE.[ACTUALDATE] as [Last Move Date]
	,LASTMOVE.[OWNERID] as [Last Move Owner]
	,NEXTMOVE.[Objective] as [Next Move]
	,NEXTMOVE.[EXPECTEDDATE] as [Next Move Date]
	,NEXTMOVE.[OWNERID] as [Next Move Owner]
	,C.[ADDRESS] as [Address]
	,C.[ZIP] as [Zip]
	,ADSAL.[PRIMARYADDRESSEE] as [Addressee]
	,ADSAL.[PRIMARYSALUTATION] as [Salutation]
	,C.EMAIL as [Email]
	,C.PROSPECT_MANAGER_TEAM [Team]
	,[Primary].CONSTITUENTID as [PRIMARYID]
	,O.[BASECURRENCYID] as [Revenue\Base currency ID]
	,O.[BASECURRENCYID] as [Revenue\Base currency ID 1]
	,O.[BASECURRENCYID] as [Revenue\Base currency ID 2]
	,O.[BASECURRENCYID] as [Revenue\Base currency ID 3]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 1]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 2]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 3]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 4]
	,O.[BASECURRENCYID] as [Prospect\Prospect Plans\Opportunities\BASECURRENCYID 5]
	,C.[CONSTITUENTID] as [QUERYRECID]
from EJ_CONSTITUENT_HISTORY as C
	inner join PROSPECTPLAN [PLAN] on [PLAN].PROSPECTID = C.CONSTITUENTID 
		and [PLAN].ISACTIVE = 1 
		and [PLAN].PROSPECTPLANTYPECODEID <> '98F61944-2900-46E5-8C95-C1EE8BDA4593'--'Earthjustice Action c(4)'
	left join opportunity O  on O.PROSPECTPLANID = [PLAN].ID
	left outer join EJ_BUDGET_AUDIT BUDGET on BUDGET.PLANID = [PLAN].ID and BUDGET.FISCAL_YEAR = @FISCALYEAR
	left join EJ_CONSTITUENT_HISTORY as [Primary] on [Primary].CONSTITUENTID = [PLAN].PRIMARYMANAGERFUNDRAISERID
	--left outer join [dbo].[USR_V_QUERY_PROSPECTPLANSTEPS] as LASTMOVE on [PLAN].[ID] = [LASTMOVE].[ID]
	left outer join V_QUERY_ADDRESSEE_SALUTATION ADSAL on ADSAL.ID = C.CONSTITUENTID
	/** this table is fundamentally broken
	--left outer join [dbo].[V_QUERY_ATTRIBUTE6920A0A601734A38A098EE001E5D02F0] as [RECENTRESEARCH] on C.CONSTITUENTID = [RECENTRESEARCH].ID 
	**/
	
	left join 
			(select *
			from
			(SELECT OBJECTIVE
			,OWNERID
			,EXPECTEDDATE
			,CONSTITUENTID
			,ROW_NUMBER() OVER (PARTITION BY CONSTITUENTID ORDER BY EXPECTEDDATE ASC) as ROWNUMBER
			FROM V_QUERY_INTERACTIONALL
			WHERE EXPECTEDDATE > getdate()
				AND PROSPECTPLANID is not null
			) as NEXTMOVES 
			where ROWNUMBER = 1
			) as NEXTMOVE on NEXTMOVE.CONSTITUENTID = C.CONSTITUENTID

	left join 
			(select *
			from
			(SELECT OBJECTIVE
			,OWNERID
			,ACTUALDATE
			,CONSTITUENTID
			,ROW_NUMBER() OVER (PARTITION BY CONSTITUENTID ORDER BY ACTUALDATE DESC) as ROWNUMBER
			FROM V_QUERY_INTERACTIONALL
			WHERE ACTUALDATE < getdate()
				AND PROSPECTPLANID is not null
			) as LASTMOVES 
			where ROWNUMBER = 1
			) as LASTMOVE on LASTMOVE.CONSTITUENTID = C.CONSTITUENTID


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

where C.PROSPECTSTATUS in (	
			'Identified',
			'Accepted',
			'Qualification',
			'Connecting'
			)
and  (C.PROSPECT_MANAGER_TEAM = 'Major Gifts'
	OR PRIMARYTEAM.BUSINESSUNIT = 'Major Gifts')


)


select top(@MAXROWS) [PROSPECTID],
	[Lookup ID],
	[Sort],
	[Name],
	[Constituency],
	[Prospect Manager],
	[PRIMARYID],
	[Primary Manager],
	[Plan],
	[Status],
	[Narrative],
	[Open Pledge],
	[Bookable],
	[Original accrual budget],
	[Original cash budget],
	[Reforecast Accrual Budget],
	[Reforecast cash budget],
	[Ask amount],
	[Ask Date],
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
	--[Last Research Type],
	--[Last Research Date],
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


