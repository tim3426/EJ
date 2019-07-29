SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

UPDATE EJ_PROSPECT_PIPELINE_STATUS
set LASTMOVE = SUB.LASTMOVE

from
(
select distinct
	PIPELINE.PROSPECTID,
	LAST_MOVE.LASTMOVE [LASTMOVE]
from
EJ_PROSPECT_PIPELINE_STATUS PIPELINE
left outer join (
				select distinct
					TEMP2.CONSTITUENTID,
					LASTMOVE = stuff((
										select 
											'; ' + 
											MOVE 
										from (
												select
													SUB.CONSTITUENTID,
													concat(SUB.SUBCATEGORY, ' - ', SUB.DATE, ' - ', SUB.OBJECTIVE) MOVE
												from (
													select
														INTERACTION.CONSTITUENTID,
														INTERACTION.ID INTERACTION,
														convert(char(10), INTERACTION.DATE, 101) DATE,
														INTERACTION.STATUS,
														INTERACTIONSUBCATEGORY.NAME SUBCATEGORY,
														INTERACTIONTYPECODE.DESCRIPTION CONTACT_METHOD,
														INTERACTION.OBJECTIVE,
														INTERACTION.PROSPECTPLANSTEPSTAGE CATEGORY,
														ROW_NUMBER() OVER (PARTITION BY INTERACTION.CONSTITUENTID
																						ORDER BY INTERACTION.CONSTITUENTID,
																					INTERACTION.DATE desc) AS ROWNUMBER
													from V_QUERY_INTERACTIONALL INTERACTION
													inner join INTERACTIONSUBCATEGORY on INTERACTION.INTERACTIONSUBCATEGORYID = INTERACTIONSUBCATEGORY.ID
													inner join INTERACTIONTYPECODE on INTERACTION.INTERACTIONTYPECODEID = INTERACTIONTYPECODE.ID
													where INTERACTION.DATE < getDate()
														and INTERACTION.COMPLETED = 1
													) SUB
												where SUB.ROWNUMBER = 1
											) TEMP1
											where TEMP1.CONSTITUENTID = TEMP2.CONSTITUENTID
											for xml path ('')), 1, 1, '')
				from (
						select distinct
							SUB.CONSTITUENTID,
							concat(SUB.SUBCATEGORY, ' - ', SUB.DATE, ' - ', SUB.OBJECTIVE) MOVE
						from (
							select
								INTERACTION.CONSTITUENTID,
								INTERACTION.ID INTERACTION,
								convert(char(10), INTERACTION.DATE, 101) DATE,
								INTERACTION.STATUS,
								INTERACTIONSUBCATEGORY.NAME SUBCATEGORY,
								INTERACTIONTYPECODE.DESCRIPTION CONTACT_METHOD,
								INTERACTION.OBJECTIVE,
								INTERACTION.PROSPECTPLANSTEPSTAGE CATEGORY,
								ROW_NUMBER() OVER (PARTITION BY INTERACTION.CONSTITUENTID
															 ORDER BY INTERACTION.CONSTITUENTID,
															INTERACTION.DATE desc) AS ROWNUMBER
							from V_QUERY_INTERACTIONALL INTERACTION
							inner join INTERACTIONSUBCATEGORY on INTERACTION.INTERACTIONSUBCATEGORYID = INTERACTIONSUBCATEGORY.ID
							inner join INTERACTIONTYPECODE on INTERACTION.INTERACTIONTYPECODEID = INTERACTIONTYPECODE.ID
							where INTERACTION.DATE < getDate()
								and INTERACTION.COMPLETED = 1
							) SUB
						where SUB.ROWNUMBER = 1
				) TEMP2
				) LAST_MOVE on PIPELINE.PROSPECTID = LAST_MOVE.CONSTITUENTID
) SUB
where EJ_PROSPECT_PIPELINE_STATUS.PROSPECTID = SUB.PROSPECTID