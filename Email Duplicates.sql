USE [ejdevo]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_F612800C_A42C_4268_85BA_A94504444B16]    Script Date: 27-Sep-19 1:27:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_F612800C_A42C_4268_85BA_A94504444B16](
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select [EMAIL].Emailaddress as [Email], 
[EMAIL].DONOTEMAIL as [Do Not Email],
C.name as [Name], 
C.LOOKUPID as [Lookup ID],
[ADDRESS].AddressBlock as [Address], 
[PHONE].Number as [Phone], 
[EMAIL].INFOSOURCECOMMENTS as [Comments],
[EMAIL].ADDEDBY_USERNAME as [Added by],
[EMAIL].DATECHANGED as [Date Changed],
--[RELS].RECIPROCALCONSTITUENTNAME as [Spouse],
[C].ID as [Constituent Record ID], 
[EMAIL].ID as [Email Record ID]
from [UFN_ADHOCQUERYIDSET_06E6A3B6_2750_4BAA_8FC0_7CC126A74599]() as [NON] 
inner join V_QUERY_CONSTITUENTEMAILADDRESS as [EMAIL]
	on [EMAIL].CONSTITUENTID = [NON].ID 
inner join V_QUERY_CONSTITUENT as [C]
	on [C].ID = [NON].ID
	and [C].CONSTITUENTTYPECODEID IN ( 'AEFFA312-BE88-4446-9FD1-7E2B07CDB973', '053731F1-CE72-441E-B0D2-C90BEE6E691C' ) 
	and DECEASED = 0
	and ISINACTIVE = 0
inner join 
	(
		select [SELFEMAIL].Emailaddress, [SELFEMAIL].CONSTITUENTID, [SELFEMAIL].DONOTEMAIL, [SELFEMAIL].INFOSOURCECOMMENTS, [SELFEMAIL].ADDEDBY_USERNAME, [SELFEMAIL].DATECHANGED
		from  [UFN_ADHOCQUERYIDSET_06E6A3B6_2750_4BAA_8FC0_7CC126A74599]() as [SELFNON] 
		inner join V_QUERY_CONSTITUENTEMAILADDRESS as [SELFEMAIL]
			on [SELFEMAIL].CONSTITUENTID = [SELFNON].ID 
		inner join V_QUERY_CONSTITUENT as [SELFC]
			on [SELFC].ID = [SELFNON].ID
			and [SELFC].CONSTITUENTTYPECODEID IN ( 'AEFFA312-BE88-4446-9FD1-7E2B07CDB973', '053731F1-CE72-441E-B0D2-C90BEE6E691C' ) 
			and DECEASED = 0
			and ISINACTIVE = 0
	)
	as [SELF] 
		on [SELF].Emailaddress = [EMAIL].Emailaddress 
		and [SELF].CONSTITUENTID <> [EMAIL].CONSTITUENTID 
		and [SELF].EmailAddress is not null
		and [SELF].EmailAddress <> ''
		and [SELF].Emailaddress like '[a-h]%'
left outer join V_QUERY_CONSTITUENTADDRESS AS [ADDRESS] ON [C].ID  = [ADDRESS].CONSTITUENTID and [ADDRESS].ISPRIMARY = 1
left outer join V_QUERY_CONSTITUENTPHONE AS [PHONE] ON [C].ID  = [PHONE].CONSTITUENTID and Phone.ISPRIMARY = 1
--left outer join V_QUERY_RELATIONSHIPS as [RELS] on [RELS].RELATIONSHIPCONSTITUENTID = [C].ID and ISSPOUSE = 1

where [EMAIL].EmailAddress is not null
and [EMAIL].EmailAddress <> ''

)


select [Email], 
[Do Not Email],
[Name], 
[Lookup ID],
[Address], 
[Phone], 
[Comments],
[Added by],
[Date Changed],
[Constituent Record ID], 
[Email Record ID]

from [ROOT_CTE] as QUERYRESULTS

order by [Email] asc