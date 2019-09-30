select  distinct 
case when Address.AddressLine1 is not null
    and Email.EmailAddress is not null
        then 'Both'
   when Address.AddressLine1 is not null
    and Email.EmailAddress is null
        then 'Mail'
	when Address.AddressLine1 is null
    and Email.EmailAddress is not null
        then 'Email'
	when PersonalSends.ID is not NULL
		then 'Personal Send'
	else 'None'
    end as Delivery
,C.LOOKUPID as [Lookup ID]
,C.NAME as Name
,PM.NAME as [Prospect manager]
,AddSal.PRIMARYADDRESSEE as Addressee
,Address.AddressLine1 as [Address line 1]
,Address.AddressLine2 as [Address line 2]
,Address.City as City
,Address.StateID_Abbreviation as State
,Address.Postcode as ZIP
,ADDRESSTYPECODE.Description as Type
,Email.EmailAddress as Email
,case when PG.ID is null then 0
    else 1
    end as PG
,case when BoardCouncilHLT.CONSTITUENTID is null then 0
    else 1
    end as [Board, Council, HLT]
,case when Estates.CONSTITUENTID is null then 0
    else 1
    end as [PG Estate]
,case when IG.ID is null then 0
    else 1
    end as IG
,case when PM.NAME is null then 0
	else 1
	end as Managed
,C.CONSTITUENTID as [Constituent ID]
,Address.ID as [Address ID]
,Email.ID as [Email ID]
,C.CONSTITUENTID as QUERYRECID
from V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19 as Recognition
left join EJ_CONSTITUENT_HISTORY as C on Recognition.CONSTITUENTID = C.CONSTITUENTID
left join V_QUERY_ADDRESSEE_SALUTATION as AddSal on C.CONSTITUENTID = AddSal.ID
left join 
	(select EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
	where EFFECTIVEDATE between '2018-07-01' and '2019-06-30'
		and CATEGORY <> 'Planned Giving'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	having sum(EJ_REVENUE_RECOGNITION.AMOUNT) >= 1000
	) as NonPGGiving on C.CONSTITUENTID = NonPGGiving.CONSTITUENTID
left join 
	(select EJ_REVENUE_RECOGNITION.CONSTITUENTID
	from EJ_REVENUE_RECOGNITION
    inner join V_QUERY_CONSTITUENCY as Estates on EJ_REVENUE_RECOGNITION.CONSTITUENTID = Estates.CONSTITUENTID and CONSTITUENCY = 'PG Estate'
	where EFFECTIVEDATE between '2018-07-01' and '2019-06-30'
	group by EJ_REVENUE_RECOGNITION.CONSTITUENTID
	) as Estates on C.CONSTITUENTID = Estates.CONSTITUENTID
--left join V_QUERY_RECOGNITION_816AA4D32F8F4F77BE995E6B27B5FD19 as Recognition on R.CONSTITUENTID = Recognition.CONSTITUENTID
left join UFN_ADHOCQUERYIDSET_F5DBD77C_9616_4A79_A245_647B511CADC5() as PG on C.CONSTITUENTID = PG.ID
left join
	(select CONSTITUENTID
	from
		(select distinct CONSTITUENTID 
		from V_QUERY_CONSTITUENCY 
		where CONSTITUENCYDEFINITIONID in (N'b998248e-820c-411a-bc86-68ef5b626258'
			, N'3f3eee49-0e88-4d02-ac4b-939b87729de9'
			, N'a1aeeb55-97ac-4430-9b9a-f2044e9f0a4c')
		and (V_QUERY_CONSTITUENCY.DATEFROM <= '2019-06-30')
		and ((V_QUERY_CONSTITUENCY.DATETO between '2018-07-01' and '2019-06-30')
		or (V_QUERY_CONSTITUENCY.DATETO is null))
		) as Constituents
	) as BoardCouncilHLT on C.CONSTITUENTID = BoardCouncilHLT.CONSTITUENTID
left join CONSTITUENTSOLICITCODE as DoNotMail on C.CONSTITUENTID = DoNotMail.ID and DoNotMail.SOLICITCODEID = 'CAC04837-7FAC-43FA-9784-72A9EA4889F6'
left join CONSTITUENTSOLICITCODE as DoNotEmail on C.CONSTITUENTID = DoNotEmail.ID and DoNotEmail.SOLICITCODEID = '5A5BA60D-C61D-4D89-B0EE-370940EFB59C'
left join CONSTITUENTSOLICITCODE as DoNotContact on C.CONSTITUENTID = DoNotContact.ID and DoNotContact.SOLICITCODEID = 'CE0A0E25-FAF9-4A7E-BB4A-BEA5053D488D'
left join CONSTITUENTSOLICITCODE as AnnualMail on C.CONSTITUENTID = AnnualMail.ID and AnnualMail.SOLICITCODEID = '25313635-764D-4F65-9710-A290F0056441'
left join CONSTITUENTSOLICITCODE as AnnualEmail on C.CONSTITUENTID = AnnualEmail.ID and AnnualEmail.SOLICITCODEID = '1153C71C-9183-42C1-BB59-DFCE22D629C3'
left join V_QUERY_CONSTITUENTPRIMARYADDRESS as Address on C.CONSTITUENTID = Address.ConstituentID 
    and Address.DONOTMAIL = 0
    and DoNotMail.ID is null
    and AnnualMail.ID is null
    and DoNotContact.ID is null
left join ADDRESSTYPECODE on ADDRESSTYPECODE.ID = Address.AddressTypeCodeID
left join V_QUERY_CONSTITUENTEMAILADDRESS as Email on C.CONSTITUENTID = Email.ConstituentID 
    and Email.DONOTEMAIL = 0
    and ISPRIMARY = 1
    and DoNotEmail.ID is NULL
    and AnnualEmail.ID is null
    and DoNotContact.ID is null
left join V_QUERY_PROSPECT as P on C.CONSTITUENTID = P.ID and P.PROSPECTSTATUSCODEID in 
	(N'49899170-d5be-448f-9fbb-45965ec0696f'
	, N'3fbc0a51-43af-4c07-9390-40f80d5bd897'
	, N'd41eed7a-4b69-4c3d-ae90-b6c012a876e9'
	, N'd85b82bb-3638-4453-a82a-57ff4873b0ec')
left join V_QUERY_FUNDRAISER as PM on P.PROSPECTMANAGERFUNDRAISERID = PM.ID
left join UFN_ADHOCQUERYIDSET_40D3DB72_42CF_410D_8FC6_1FC89936810B() as IG on C.CONSTITUENTID = IG.ID
left join dbo.[UFN_ADHOCQUERYIDSET_B3EEDF3A_EAF9_4B99_9B45_6B451538CC8F]() as PersonalSends on C.CONSTITUENTID = PersonalSends.ID


where NonPGGiving.CONSTITUENTID is not null
or PG.ID is not null
or Estates.CONSTITUENTID is not null
or BoardCouncilHLT.CONSTITUENTID is not null
