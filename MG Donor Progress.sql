USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_041900EC_38E2_4BA3_A9FE_4B6A6EFF66FB]    Script Date: 29-Jul-19 11:57:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_041900EC_38E2_4BA3_A9FE_4B6A6EFF66FB](
@PROSPECTMANAGER nvarchar(154) = null,
	@PRIMARYMANAGER nvarchar(154) = null,
	@PLANTYPE nvarchar(100) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @PROSPECTMANAGER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@PROSPECTMANAGER, 0, null, 0);
set @PRIMARYMANAGER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@PRIMARYMANAGER, 0, null, 0);
with
[ROOT_CTE] as (
select distinct
	[PROSPECTID],
	[PLANID],
	[OPPORTUNITYID],
	[EVENTID],
	PROSPECTMANAGER [Prospect manager],
	PRIMARYMANAGER [Primary manager],
	PROSPECTSTATUS [Prospect status],
	SORT [Sort],
	NAME [Name],
	BUDGETAMOUNT [Budget amount],
	BUDGETDATE [Budget date],
	ASKAMOUNT [Solicitation amount],
	ASKDATE [Solicitation date],
	CURRENT_GIVING [Current fiscal year giving],
	PLANNAME [Plan name],
	NARRATIVE [Narrative],
	UPCOMINGMOVES [Upcoming moves],
	LASTMOVE [Last activity],
	LASTVISIT [Last visit],
	LASTSTRATEGY [Last strategy],
	LASTEVENT [Last event attended],
	CITY [City],
	STATE [State],
	PLANTYPE [Plan type],
	REVENUECOMMITTED [Revenue committed],
	[5 Year Capacity],
	[Affinity],
	[Estimated Wealth],
	[Inclination]
from EJ_PROSPECT_PIPELINE_STATUS
)


select top(@MAXROWS)
	[PROSPECTID],
	[PLANID],
	[OPPORTUNITYID],
	[EVENTID],
	[Prospect manager],
	[Primary manager],
	[Prospect status],
	[Sort],
	[Name],
	[Budget amount],
	[Budget date],
	[Solicitation amount],
	[Solicitation date],
	[Current fiscal year giving],
	[Plan name],
	[Narrative],
	[Upcoming moves],
	[Last activity],
	[Last visit],
	[Last strategy],
	[Last event attended],
	[City],
	[State],
	[Plan type],
	[Revenue committed],
	[5 Year Capacity],
	[Affinity],
	[Estimated Wealth],
	[Inclination],
	null [Prospect Plans\Opportunities\BASECURRENCYID],
	null [Constituent\Calendar Year 2010 Cumulative Gifts Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')
	and ((@PRIMARYMANAGER is null or @PRIMARYMANAGER = '') or QUERYRESULTS.[Primary manager] LIKE  '%' + @PRIMARYMANAGER + '%')
	and ((@PLANTYPE is null or @PLANTYPE = '') or QUERYRESULTS.[Plan type] = (select top(1) DESCRIPTION from dbo.[PROSPECTPLANTYPECODE] where ID = @PLANTYPE))

order by [Sort] asc
