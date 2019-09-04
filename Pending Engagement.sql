USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_1E0AA3DE_98C4_4DF0_9328_1742BBBB026A]    Script Date: 12-Jul-19 4:00:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_1E0AA3DE_98C4_4DF0_9328_1742BBBB026A](
@TEAM nvarchar(154) = null,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
set @TEAM = dbo.UFN_SEARCHCRITERIA_GETLIKEPARAMETERVALUE2(@TEAM, 0, null, 0);
with
[ROOT_CTE] as (

select 
LOOKUPID as [Lookup ID],
C.Name,
City,
State,
PRIMARY_CONSTITUENCY as [Primary Constituency],
C.ANNUAL_SUMMARY_CASH_YEAR_0 [Current Year Giving],
C.ANNUAL_SUMMARY_CASH_YEAR_1 [Prior Year Giving],
C.ANNUAL_SUMMARY_CASH_YEAR_2 [Two Years Prior Giving],
PRIOR_EVENT.STARTDATE as [Last Event Date],
PRIOR_EVENT.Name as [Last Event],
C.[LASTGIFT_DATE] as [Latest Gift Date],
C.[LASTGIFT_AMOUNT] as [Latest Gift Amount],
LASTGIFTINFO.EFFECTIVEDATE as [Latest One-Time Gift Date],
LASTGIFTINFO.AMOUNT as [Latest One-Time Gift Amount],
C.[LargestGift_Date] as [Largest Gift Date],
C.[LargestGift_Amount] as [Largest Gift Amount],
--MRR.STARTDATE as [Most Recent Research],
EJ_FIVE_YEAR_CAPACITY as [Five Year Gift Capacity],
EJ_EST_WEALTH as [Estimated Wealth],
cast(MAJORGIVINGCAPACITYVALUE as money) as [Major Giving Capacity],
Moves.ActualDATE as [Last Move Date],
Moves.Objective as [Last Move Objective],
NonMoveInteractions.ActualDATE as [Last Interaction Date],
NonMoveInteractions.OBjective as [Last Interaction Objective],
F.NAME as [Last Manager Name],
ProspectHistory.Dateto as [Manager End Date],
Team.Businessunit as [Team],
[ProspectAssessment].[AssessmentDate] as [Last Prospect Assessment],
[ProspectAssessment].[AssessmentSummary] as [Summary],
[ProspectAssessment].[AssessmentComment] as [Comment],
P.ID,
[LARGESTGIFT_REVENUEID] as [FY2016 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
[LARGESTGIFT_REVENUEID] as [FY2015 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
[LARGESTGIFT_REVENUEID] as [FY2014 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
[LARGESTGIFT_REVENUEID] as [Latest Gift Amount - Countable Recognition Credits Smart Field\Currency ID],
[LARGESTGIFT_REVENUEID] as [Latest Recurring Gift Amount Smart Field\Currency ID],
[LARGESTGIFT_REVENUEID] as [Largest Gift Amount - Countable Recognition Credits Smart Field\Currency ID]
from PROSPECT as P
left outer join EJ_CONSTITUENT_HISTORY as C on C.CONSTITUENTID = P.ID
--left outer join [dbo].[V_QUERY_SMARTFIELDEDBD0A975F3B424DB03334DD393DD70B] as [Largest Gift Date] on P.ID = [Largest Gift Date].[ID]
--left outer join [dbo].[V_QUERY_SMARTFIELDF15250E3C7724E91ADD2526A8735F1D2] as [Largest Gift Amount] on P.ID = [Largest Gift Amount].[ID]
--left outer join [dbo].[V_QUERY_SMARTFIELDDDA1E5EFF1EA421C9026250DE0B188F8] as [Latest Gift Date] on P.ID = [Latest Gift Date].[ID]
--left outer join [dbo].[V_QUERY_SMARTFIELD7FFF88280FA64054A1D681356924335D] as [Latest Gift Amount] on P.ID = [Latest Gift Amount].[ID]
--left outer join [dbo].[V_QUERY_MODELINGANDPROPENSITY_SIMPLE] as Modeling on P.ID = Modeling.ID
--left outer join [dbo].[V_QUERY_ATTRIBUTEDCEFF2E9FDAB4674901120B7D8F75872] as FiveYear on P.ID = FiveYear.ID
--left outer join [dbo].[V_QUERY_ATTRIBUTED6169246286E4F48936E75C15FFCF562] as EW on P.ID = EW.ID
--left outer join [dbo].[V_QUERY_ATTRIBUTE6920A0A601734A38A098EE001E5D02F0] as MRR on P.ID = MRR.ID
left outer join [dbo].[V_QUERY_WEALTHCAPACITY] as W on P.ID = W.ID
left outer join (
                            
                            select distinct
                            
                                    PREVIOUS_EVENTDATE.CONSTITUENTID,
                                    PREVIOUS_EVENTDATE.STARTDATE STARTDATE,
                                    PREVIOUS_EVENTDATE.NAME NAME,
                                    PREVIOUS_EVENTDATE.ID EVENTID
                                from      
                                 (
                                        select distinct
                                            REGISTRANT.CONSTITUENTID CONSTITUENTID,
                                            EVENT.STARTDATE STARTDATE,
                                            EVENT.NAME,
                                            EVENT.ID,
                                            ROW_NUMBER() OVER (PARTITION BY REGISTRANT.CONSTITUENTID
                                                             ORDER BY EVENT.STARTDATE desc) AS ROWNUMBER

                                        from  [dbo].[V_QUERY_CONSTITUENTREGISTRANT] as REGISTRANT
                                        left outer join [dbo].[V_QUERY_EVENT] as EVENT on REGISTRANT.[EVENTID] = EVENT.ID and REGISTRANT.ATTENDED = 1
                                        where EVENT.STARTDATE < getDate()
                                    ) PREVIOUS_EVENTDATE
                                where PREVIOUS_EVENTDATE.ROWNUMBER = 1                    
                ) PRIOR_EVENT on PRIOR_EVENT.CONSTITUENTID = P.ID
left outer join (
                            
                            select distinct
											PMH.PROSPECTID,
                                            PMH.DATEFROM,
											PMH.DATETO,
                                            PMH.FUNDRAISERID
                                from      
                                 (
                                        select distinct
                                            PM.PROSPECTID,
                                            PM.DATEFROM,
											PM.DATETO,
                                            PM.FUNDRAISERID,
                                            ROW_NUMBER() OVER (PARTITION BY PM.PROSPECTID
                                                             ORDER BY PM.DATETO desc) AS ROWNUMBER

                                        from  prospectmanagerhistory as PM
                                        where PM.DATETO < getDate()
                                  ) PMH
                                where PMH.ROWNUMBER = 1                    
                ) ProspectHistory on ProspectHistory.PROSPECTID = P.ID
--left outer join [dbo].[V_QUERY_PROSPECTPLAN] as [PP] on [PP].ProspectID = P.ID and PP.historical = 0
left outer join (
                            select distinct
                                            Plans.ID,
											Plans.StartDate,
											Plans.ProspectID
                                from      
                                 (
                                        select distinct
											PP.ID,
											PP.StartDate,
											PP.ProspectID,
                                            ROW_NUMBER() OVER (PARTITION BY PP.ProspectID
                                                             ORDER BY PP.StartDate desc) AS ROWNUMBER

                                        from  V_QUERY_PROSPECTPLAN as PP
                                  ) Plans
                                where Plans.ROWNUMBER = 1                    
                ) ProspectPlan on Prospectplan.ProspectID = P.ID
				
left outer join (
                            select distinct
                                            MoveInteractions.PROSPECTPLANID,
											MoveInteractions.EXPECTEDDATE,
											MoveInteractions.ACTUALDATE,
											MoveInteractions.OBJECTIVE,
											MoveInteractions.Comment,
											MoveInteractions.ConstituentID
											
                                from      
                                 (
                                        select distinct
											MI.PROSPECTPLANID,
                                            MI.EXPECTEDDATE,
											MI.ACTUALDATE,
											MI.OBJECTIVE,
											MI.Comment,
											MI.ConstituentID,
                                            ROW_NUMBER() OVER (PARTITION BY MI.ConstituentID
                                                             ORDER BY MI.actualdate desc) AS ROWNUMBER

                                        from  INTERACTION as MI
                                        where MI.ACTUALDATE < getdate()
										and MI.PROSPECTPLANID is not null
                                  ) MoveInteractions
                                where MoveInteractions.ROWNUMBER = 1         
                ) Moves on Moves.ConstituentID = P.ID

left outer join (
                            select distinct
                                            Interactions.PROSPECTPLANID,
											Interactions.EXPECTEDDATE,
											Interactions.ACTUALDATE,
											Interactions.OBJECTIVE,
											Interactions.Comment,
											Interactions.ConstituentID
											
                                from      
                                 (
                                        select distinct
											I.PROSPECTPLANID,
                                            I.EXPECTEDDATE,
											I.ACTUALDATE,
											I.OBJECTIVE,
											I.Comment,
											I.ConstituentID,
                                            ROW_NUMBER() OVER (PARTITION BY I.ConstituentID
                                                             ORDER BY I.actualdate desc) AS ROWNUMBER

                                        from  INTERACTION as I
                                        where I.ACTUALDATE < getdate()
										and I.PROSPECTPLANID is null
                                  ) Interactions
                                where Interactions.ROWNUMBER = 1         
                ) NonMoveInteractions on NonMoveInteractions.ConstituentID = P.ID
				
left outer join [dbo].[V_QUERY_FUNDRAISER] as F on ProspectHistory.FundraiserID = F.ID
left outer join (
		select OrgPositions.CONSTITUENTID as [CONSTITUENTID],
		--[ORGANIZATIONHIERARCHY].[ID] [HIERARCHYID],
		--[ORGANIZATIONHIERARCHY].[SEQUENCE] [SEQUENCE],
		--	case 
		--	when [ORGANIZATIONPOSITIONHOLDER].[ID] is null then 1 else 0 
		--	end [ISVACANT],
		--[ORGANIZATIONPOSITION].[NAME] [POSITION],
		--[CONSTITUENT].[NAME] [POSITIONHOLDER],
		[dbo].[UFN_BUSINESSUNITCODE_GETDESCRIPTION](ORGANIZATIONPOSITION.BUSINESSUNITCODEID) [BUSINESSUNIT]
		--[ORGANIZATIONPOSITIONHOLDER].[DATEFROM],
		--[ORGANIZATIONPOSITIONHOLDER].[DATETO]
		from ORGANIZATIONHIERARCHY
		inner join ORGANIZATIONPOSITION on ORGANIZATIONPOSITION.ID = ORGANIZATIONHIERARCHY.ID
		left outer join (
			select ORGANIZATIONPOSITIONHOLDER.POSITIONID,
			ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID,
			ROW_NUMBER() OVER (PARTITION BY ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID ORDER BY DATETO desc) AS ROWNUM
			from ORGANIZATIONPOSITIONHOLDER
			) as OrgPositions on OrgPositions.POSITIONID = ORGANIZATIONPOSITION.ID 
			where ROWNUM = 1
		--left outer join EJ_CONSTITUENT on EJ_CONSTITUENT.CONSTITUENTID = ORGANIZATIONPOSITIONHOLDER.CONSTITUENTID
	) as [TEAM] on [TEAM].[CONSTITUENTID] = F.ID
left outer join ( 
	select distinct
		LASTGIFT.CONSTITUENTID,
		LASTGIFT.EFFECTIVEDATE,
		LASTGIFT.AMOUNT
			from
			(
				select distinct
					EJR.CONSTITUENTID,
					EJR.EFFECTIVEDATE,
					EJR.AMOUNT,
					ROW_NUMBER() OVER (PARTITION BY EJR.CONSTITUENTID
						ORDER BY EJR.EFFECTIVEDATE desc) AS ROWNUMBER
				from  EJ_REVENUE_RECOGNITION as EJR
				inner join PROSPECT as P on P.ID = EJR.CONSTITUENTID
				where EJR.APPLICATION <> 'Recurring gift'
			) LASTGIFT
	where LASTGIFT.ROWNUMBER = 1                    
) LASTGIFTINFO on LASTGIFTINFO.CONSTITUENTID = P.ID
LEFT OUTER JOIN (
	SELECT * 
	FROM (SELECT  
			[I].CONSTITUENTID [CONSTITUENTID],
			[I].ACTUALDATE [AssessmentDate],
			[I].Objective [AssessmentSummary],
			[I].Comment [AssessmentComment],
			ROW_NUMBER() OVER (PARTITION BY I.CONSTITUENTID ORDER BY I.CONSTITUENTID,I.DATE desc) AS ROWNUMBER
			FROM INTERACTION I 
			WHERE [I].INTERACTIONSUBCATEGORYID = 'b1a4a661-42b6-4947-9ca7-0bee2b62d8ab' --Prospect Assessment
				AND [I].STATUS = 'Completed'
			) Y
	WHERE Y.ROWNUMBER = 1 
	) [ProspectAssessment] ON [ProspectAssessment].CONSTITUENTID = C.CONSTITUENTID


where P.PROSPECTSTATUSCODEID = 'b18c5050-0f21-464d-be41-a1c97c25f698' --Pending Engagement
and ([ProspectAssessment].[AssessmentDate] < dateadd(year,-1,getdate())
or [ProspectAssessment].[AssessmentDate] is null)

)


select top(@MAXROWS) [Lookup ID],
	[Name],
	[City],
	[State],
	[Primary Constituency],
	[Current Year Giving],
	[Prior Year Giving],
	[Two Years Prior Giving],
	[Last Event Date],
	[Last Event],
	[Latest Gift Date],
	[Latest Gift Amount],
	[Latest One-Time Gift Date],
	[Latest One-Time Gift Amount],
	[Largest Gift Date],
	[Largest Gift Amount],
	--[Most Recent Research],
	[Five Year Gift Capacity],
	[Estimated Wealth],
	--[Major Giving Capacity],
	[Last Move Date],
	[Last Move Objective],
	[Last Interaction Date],
	[Last Interaction Objective],
	[Last Manager Name],
	[Manager End Date],
	[Team],
	[Last Prospect Assessment],
	[Summary],
	[Comment],
	[ID],
	[FY2016 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
	[FY2015 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
	[FY2014 Giving - Recognition Credits Countable Revenue No PG Smart Field\Currency ID],
	[Latest Gift Amount - Countable Recognition Credits Smart Field\Currency ID],
	[Latest Recurring Gift Amount Smart Field\Currency ID],
	[Largest Gift Amount - Countable Recognition Credits Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where ((@TEAM is null or @TEAM = '') or QUERYRESULTS.[Team] LIKE  '%' + @TEAM + '%')


