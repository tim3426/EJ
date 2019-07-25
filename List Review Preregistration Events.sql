USE [EJDEVO]
GO
/****** Object:  StoredProcedure [dbo].[USP_DATALIST_ADHOCQUERY_125768EB_CF92_45BF_AD32_14EAAFE10D91]    Script Date: 24-Jul-19 4:47:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[USP_DATALIST_ADHOCQUERY_125768EB_CF92_45BF_AD32_14EAAFE10D91](
	@CONTEXTRECORDID uniqueidentifier,
	@CURRENTAPPUSERID uniqueidentifier,
	@SECURITYFEATUREID uniqueidentifier,
	@SECURITYFEATURETYPE tinyint,
	@MAXROWS int = 100000) as
set nocount on;
with
[ROOT_CTE] as (
select E.Name as [Event]
    ,C.NAME as [Name]
	--,R.[TYPE] as [Type]
	--,R.[STATUS] as [Status]
	--,R.[HOSTNAME] as [Host]
	,C.EJ_FIVE_YEAR_CAPACITY as [Capacity]
	,C.LIFETIME_CASH_GIVING as [Cumulative giving]
	,[In-Person].Comment as [In-Person]
    ,[Travel].Comment as [Travel]
    ,[Host].Comment as [Host]
	,C.ADDRESS as Address
	,C.CITY as City
	,C.State as State
	,C.LASTGIFT_DATE as [Latest gift date]
	,C.LASTGIFT_AMOUNT as [Latest gift amount]
	,C.LATEST_INTERACTION as [Latest interaction]
	,F.Name as [Prospect manager]
	,PM.Name as [Primary manager]
	,Steps.[Next Step Date] as [Next interaction date]
	,PRIOR_EVENT.Name as [Last event attended]
	,R.ID as [Registrant ID]
	,C.CONSTITUENTID as [Constituent ID]
	,E.ID as [Event ID]
	,Registration.ID as [Registration ID]
    ,F.ID as [Prospect Manager ID]
	,R.[ID] as [Constituent\Cumulative Giving - Recognition Credits Countable Revenue Smart Field\Currency ID]
	,R.[ID] as [Constituent\Latest Gift Amount - Countable Recognition Credits Smart Field\Currency ID]
    ,R.[ID] as [QUERYRECID]
from V_QUERY_PROSPECT as P 
inner join V_QUERY_FUNDRAISER as F on P.PROSPECTMANAGERFUNDRAISERID = F.ID
inner join EJ_CONSTITUENT_HISTORY as C on P.ID = C.CONSTITUENTID
inner join V_QUERY_REGISTRANT as R on C.CONSTITUENTID = R.CONSTITUENTID
inner join V_QUERY_EVENT as E on R.EVENTID = E.ID
left join (
                            select distinct
                                            ID,
											StartDate,
											ProspectID,
                                            Historical,
                                            PRIMARYMANAGERFUNDRAISERID
                                from      
                                 (
                                        select distinct
											ID,
											StartDate,
											ProspectID,
                                            Historical,
                                            PRIMARYMANAGERFUNDRAISERID,
                                            ROW_NUMBER() OVER (PARTITION BY ProspectID
                                                             ORDER BY StartDate desc) AS ROWNUMBER

                                        from  V_QUERY_PROSPECTPLAN
                                  ) Plans
                                where Plans.ROWNUMBER = 1                    
                ) PP on P.ID = PP.ProspectID
left join V_QUERY_FUNDRAISER as PM on PP.PRIMARYMANAGERFUNDRAISERID = PM.ID
left join [dbo].[V_QUERY_ATTRIBUTE14A7B597D42B4BF3B3A2964CD2E1A6BD] as [In-Person] on C.CONSTITUENTID = [In-Person].[PARENTID] and [In-Person].VALUEID = 'EFAE4213-699E-4E19-B239-2D2AFCFC802A' 
left join [dbo].[V_QUERY_ATTRIBUTE14A7B597D42B4BF3B3A2964CD2E1A6BD] as [Travel] on C.CONSTITUENTID = [Travel].[PARENTID] and [Travel].VALUEID = '0DF29FB3-37D8-48A1-B269-4D22F99BFEDC'
left join [dbo].[V_QUERY_ATTRIBUTE14A7B597D42B4BF3B3A2964CD2E1A6BD] as [Host] on C.CONSTITUENTID = [Host].[PARENTID] and [Host].VALUEID = '7BE1FED8-88F7-419D-BB1C-9F362B2A452B'
left join USR_V_QUERY_PROSPECTPLANSTEPS as Steps on PP.ID = Steps.ID
left join (
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
                ) PRIOR_EVENT on PRIOR_EVENT.CONSTITUENTID = C.CONSTITUENTID

--left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_REGISTRANT\Constituent] on R.[CONSTITUENTID] = [V_QUERY_REGISTRANT\Constituent].[ID]
--left outer join [dbo].[V_QUERY_WEALTHCAPACITY] as [V_QUERY_REGISTRANT\Constituent\Wealth Capacity] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Wealth Capacity].[ID]
--left outer join [dbo].[V_QUERY_SMARTFIELD690985E49E094135A562B7A16B1664A1] as [V_QUERY_REGISTRANT\Constituent\Cumulative Giving - Recognition Credits Countable Revenue Smart Field] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Cumulative Giving - Recognition Credits Countable Revenue Smart Field].[ID]

--left outer join [dbo].[V_QUERY_CONSTITUENTPRIMARYADDRESS] as [V_QUERY_REGISTRANT\Constituent\Address (Primary)] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Address (Primary)].[CONSTITUENTID]
--left outer join [dbo].[V_QUERY_SMARTFIELDDDA1E5EFF1EA421C9026250DE0B188F8] as [V_QUERY_REGISTRANT\Constituent\Latest Gift Date - Countable Recognition Credits Smart Field] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Latest Gift Date - Countable Recognition Credits Smart Field].[ID]
--left outer join [dbo].[V_QUERY_SMARTFIELD7FFF88280FA64054A1D681356924335D] as [V_QUERY_REGISTRANT\Constituent\Latest Gift Amount - Countable Recognition Credits Smart Field] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Latest Gift Amount - Countable Recognition Credits Smart Field].[ID]
--left outer join [dbo].[V_QUERY_PROSPECT] as [V_QUERY_REGISTRANT\Constituent\Prospect] on [V_QUERY_REGISTRANT\Constituent].[ID] = [V_QUERY_REGISTRANT\Constituent\Prospect].[ID]
--left outer join [dbo].[V_QUERY_FUNDRAISER] as [V_QUERY_REGISTRANT\Constituent\Prospect\Prospect Manager] on [V_QUERY_REGISTRANT\Constituent\Prospect].[PROSPECTMANAGERFUNDRAISERID] = [V_QUERY_REGISTRANT\Constituent\Prospect\Prospect Manager].[ID]
--left outer join [dbo].[V_QUERY_CONSTITUENT] as [V_QUERY_REGISTRANT\Constituent\Prospect\Prospect Plans\Primary Manager] on [V_QUERY_REGISTRANT\Constituent\Prospect\Prospect Plans].[PRIMARYMANAGERFUNDRAISERID] = [V_QUERY_REGISTRANT\Constituent\Prospect\Prospect Plans\Primary Manager].[ID]
--left outer join [dbo].[V_QUERY_EVENT] as [V_QUERY_REGISTRANT\Constituent\Registrant\Event] on [V_QUERY_REGISTRANT\Constituent\Registrant].[EVENTID] = [V_QUERY_REGISTRANT\Constituent\Registrant\Event].[ID]
--left outer join [dbo].[V_QUERY_EVENT] as [V_QUERY_REGISTRANT\Event] on R.[EVENTID] = [V_QUERY_REGISTRANT\Event].[ID]
left outer join V_QUERY_REGISTRANTREGISTRATION as Registration on P.ID = Registration.REGISTRANTID
where P.PROSPECTSTATUSCODEID in (N'49899170-d5be-448f-9fbb-45965ec0696f'
    , N'3fbc0a51-43af-4c07-9390-40f80d5bd897'
    , N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9'
    , N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
and PP.HISTORICAL = 0
and ((E.STARTDATE between getdate() and dateadd(month,4,(getdate())))
        or ((E.STARTDATE between getdate() and dateadd(year,1,getdate()))
            and E.[EVENTCATEGORYCODEID] = N'dbf989eb-0417-4539-82bb-b5a7021d1824'))
)


select top(@MAXROWS) [Event],
	[Name],
	[Capacity],
	[Cumulative giving],
	[In-Person],
	[Travel],
	[Host],
	[Address],
	[City],
	[State],
	[Latest gift date],
	[Latest gift amount],
	[Latest interaction],
	[Primary manager],
	[Next interaction date],
	[Last event attended],
	[Registrant ID],
	[Constituent ID],
	[Event ID],
	[Registration ID],
	[Prospect Manager ID],
	[Constituent\Cumulative Giving - Recognition Credits Countable Revenue Smart Field\Currency ID],
	[Constituent\Latest Gift Amount - Countable Recognition Credits Smart Field\Currency ID]
from [ROOT_CTE] as QUERYRESULTS
where QUERYRESULTS.[Prospect Manager ID] = @CONTEXTRECORDID

