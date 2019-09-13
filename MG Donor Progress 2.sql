USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_041900EC_38E2_4BA3_A9FE_4B6A6EFF66FB]    Script Date: 29-Jul-19 11:57:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_041900EC_38E2_4BA3_A9FE_4B6A6EFF66FB](
@PROSPECTMANAGER nvarchar(154) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @PROSPECTMANAGER = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@PROSPECTMANAGER, 0, null, 0);
with
[ROOT_CTE] as (
select distinct
	[PROSPECTID],
	[PLANID],
	[OPPORTUNITYID],
	PROSPECTMANAGER [Prospect manager],
	PROSPECTSTATUS [Prospect status],
	SORT [Sort],
	NAME [Name],
	BUDGETAMOUNT [Budget amount],
	BUDGETDATE [Budget date],
	ASKAMOUNT [Solicitation amount],
	ASKDATE [Solicitation date],
	NARRATIVE [Narrative],
	UPCOMINGMOVES [Upcoming moves],
	Lastinteractionsubcategory [Last interaction subcategory],
    Lastinteractiondate [Last interaction date],
    Lastinteractionobjective [Last interaction objective],
	LAST_VISIT_DATE [Last visit date],
	LASTSTRATEGY [Last strategy],
	FIVEYEAR [5 Year Capacity]
from EJ_PROSPECT_PIPELINE_STATUS
)


select top(@MAXROWS)
	[PROSPECTID],
	[PLANID],
	[OPPORTUNITYID],
	[Prospect manager],
    [Prospect status],
	[Sort],
	[Name],
	[Budget amount],
	[Budget date],
	[Solicitation amount],
	[Solicitation date],
	[Narrative],
	[Upcoming moves],
	[Last interaction subcategory],
    [Last interaction date],
    [Last interaction objective],
	[Last visit date],
	[Last strategy],
	[5 Year Capacity],
	null [Prospect Plans\Opportunities\BASECURRENCYID],
	null [Constituent\Calendar Year 2010 Cumulative Gifts Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@PROSPECTMANAGER is null or @PROSPECTMANAGER = '') or QUERYRESULTS.[Prospect manager] LIKE  '%' + @PROSPECTMANAGER + '%')

order by [Sort] asc
