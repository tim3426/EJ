use EJDEVO

declare @DATE date = case when month(getDate()) > 6 
						  then concat(year(getDate()) + 1, '-06-30') 
						  else concat(year(getDate()), '-06-30')
					 end
declare @ENDDATE datetime = concat(convert(date, @DATE), 'T23:59:59.997')
declare @STARTDATE datetime = dateAdd(year, -1, dateAdd(ms, 3, @ENDDATE))

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET QUOTED_IDENTIFIER ON

---------------Refresh EJ_DONATION_ANNUAL_SUMMARY_REVENUE_RECOGNITION table----------------

TRUNCATE TABLE EJ_DONATION_ANNUAL_SUMMARY_REVENUE_RECOGNITION;

INSERT INTO EJ_DONATION_ANNUAL_SUMMARY_REVENUE_RECOGNITION (CONSTITUENTID, TYPE, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
															YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, 
															YEAR_6_CHANNEL, YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL,
															YEAR_0_COUNT, YEAR_1_COUNT, YEAR_2_COUNT, YEAR_3_COUNT, YEAR_4_COUNT, YEAR_5_COUNT, 
															YEAR_6_COUNT, YEAR_7_COUNT, YEAR_8_COUNT, YEAR_9_COUNT, YEAR_10_COUNT) 
	SELECT CONSTITUENTID, TYPE, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
			YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, 
			YEAR_6_CHANNEL, YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL,
			YEAR_0_COUNT, YEAR_1_COUNT, YEAR_2_COUNT, YEAR_3_COUNT, YEAR_4_COUNT, YEAR_5_COUNT, 
			YEAR_6_COUNT, YEAR_7_COUNT, YEAR_8_COUNT, YEAR_9_COUNT, YEAR_10_COUNT
	FROM 
	
		(
			select 
				[C].[CONSTITUENTID] [CONSTITUENTID],
				'Recognition' as [TYPE],
				sum(case when [R].[EFFECTIVEDATE] between @STARTDATE and @ENDDATE and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_0],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_1],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_2],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_3],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_4],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_5],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_6],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_7],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_8],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_9],
				sum(case when [R].[EFFECTIVEDATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[AMOUNT] else 0 end) [YEAR_10],
				case when
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_0_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_1_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_2_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_3_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_4_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_5_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_6_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_7_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_8_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_9_CHANNEL,
				case when
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) > 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) = 0
					 then 'Online'
					 when 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE = 'Convio' then R.REVENUEID end) = 0
						and 
						count(distinct case when R.EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.REVENUESOURCE <> 'Convio' then R.REVENUEID end) > 0
					 then 'Offline'
				end YEAR_10_CHANNEL,
				count(distinct case when [R].[EFFECTIVEDATE] between @STARTDATE and @ENDDATE and [R].[TRANSACTIONTYPE] = 'Payment' then [R].SPLITID end) [YEAR_0_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_1_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_2_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_3_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_4_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_5_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_6_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_7_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_8_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_9_COUNT],
				count(distinct case when [R].[EFFECTIVEDATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and [R].[TRANSACTIONTYPE] = 'Payment' then [R].[SPLITID] end) [YEAR_10_COUNT]
			from (select distinct ID CONSTITUENTID from V_QUERY_CONSTITUENT) [C]
			left outer join [EJ_REVENUE_RECOGNITION] [R] on [R].[CONSTITUENTID] = [C].[CONSTITUENTID]
			group by
			 [C].[CONSTITUENTID]

			UNION

			select 
				[C].[CONSTITUENTID] [CONSTITUENTID],
				'Revenue' as [TYPE],
				sum(case when [V].[DATE] between @STARTDATE and @ENDDATE and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_0],
				sum(case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_1],
				sum(case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_2],
				sum(case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_3],
				sum(case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_4],
				sum(case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_5],
				sum(case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_6],
				sum(case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_7],
				sum(case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_8],
				sum(case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_9],
				sum(case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then [V].[SPLITAMOUNT] else 0 end) [YEAR_10],
				case when
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_0_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_1_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_2_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_3_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_4_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_5_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_6_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_7_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_8_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_9_CHANNEL,
				case when
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_10_CHANNEL,
				count(distinct case when [V].[DATE] between @STARTDATE and @ENDDATE and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_0_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_1_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_2_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_3_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_4_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_5_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_6_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_7_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_8_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_9_COUNT],
				count(distinct case when [V].[DATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and [V].[TRANSACTIONTYPE] = 'Payment' then V.SPLITID end) [YEAR_10_COUNT]
			from (select distinct ID CONSTITUENTID from V_QUERY_CONSTITUENT) [C]
			left outer join [EJ_REVENUE] [V] on [V].[CONSTITUENTID] = [C].[CONSTITUENTID]
			left outer join [dbo].[V_QUERY_ATTRIBUTEF0F8EDAFDE5D49BBB1BD78C37C72468E] as R on [V].[REVENUEID] = R.[ID]
			group by
			 [C].[CONSTITUENTID]
		) SUB
	
	group by CONSTITUENTID, TYPE, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
			YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, 
			YEAR_6_CHANNEL, YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL,
			YEAR_0_COUNT, YEAR_1_COUNT, YEAR_2_COUNT, YEAR_3_COUNT, YEAR_4_COUNT, YEAR_5_COUNT, 
			YEAR_6_COUNT, YEAR_7_COUNT, YEAR_8_COUNT, YEAR_9_COUNT, YEAR_10_COUNT

---------------Refresh EJ_DONATION_ANNUAL_SUMMARY_RECOGNITION_PAYMENT_AND_PLEDGE table----------------

delete from EJ_DONATION_ANNUAL_SUMMARY_RECOGNITION_PAYMENT_AND_PLEDGE;

INSERT INTO EJ_DONATION_ANNUAL_SUMMARY_RECOGNITION_PAYMENT_AND_PLEDGE (CONSTITUENTID, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
				YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, YEAR_6_CHANNEL, 
				YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL) 
	SELECT CONSTITUENTID, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
				YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, YEAR_6_CHANNEL, 
				YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL
	FROM 
	
		(
			select 
			 [C].[CONSTITUENTID] [CONSTITUENTID],
			 sum(case when V.[EFFECTIVEDATE] between @STARTDATE and @ENDDATE then V.[AMOUNT] else 0 end) [YEAR_0],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_1],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_2],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_3],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_4],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_5],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_6],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_7],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_8],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_9],
			 sum(case when V.[EFFECTIVEDATE] between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) then V.[AMOUNT] else 0 end) [YEAR_10],
			 				case when
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between @STARTDATE and @ENDDATE and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_0_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -1, @STARTDATE) and dateAdd(year, -1, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_1_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -2, @STARTDATE) and dateAdd(year, -2, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_2_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -3, @STARTDATE) and dateAdd(year, -3, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_3_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -4, @STARTDATE) and dateAdd(year, -4, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_4_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -5, @STARTDATE) and dateAdd(year, -5, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_5_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -6, @STARTDATE) and dateAdd(year, -6, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_6_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -7, @STARTDATE) and dateAdd(year, -7, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_7_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -8, @STARTDATE) and dateAdd(year, -8, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_8_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -9, @STARTDATE) and dateAdd(year, -9, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_9_CHANNEL,
				case when
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Multichannel'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) > 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) = 0
					 then 'Online'
					 when 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] = 'Convio' then R.ID end) = 0
						and 
						count(distinct case when [V].EFFECTIVEDATE between dateAdd(year, -10, @STARTDATE) and dateAdd(year, -10, @ENDDATE) and R.[VALUE] <> 'Convio' then R.ID end) > 0
					 then 'Offline'
				end YEAR_10_CHANNEL
			from (select distinct ID CONSTITUENTID from V_QUERY_CONSTITUENT) [C]
			left outer join [EJ_RECOGNITION_PAYMENT_AND_PLEDGE] V on V.[CONSTITUENTID] = [C].[CONSTITUENTID]
			left outer join [dbo].[V_QUERY_ATTRIBUTEF0F8EDAFDE5D49BBB1BD78C37C72468E] as R on V.REVENUEID = R.[ID]
			group by
			 [C].[CONSTITUENTID]
		) SUB
	
	group by CONSTITUENTID, YEAR_0, YEAR_1, YEAR_2, YEAR_3, YEAR_4, YEAR_5, YEAR_6, YEAR_7, YEAR_8, YEAR_9, YEAR_10,
				YEAR_0_CHANNEL, YEAR_1_CHANNEL, YEAR_2_CHANNEL, YEAR_3_CHANNEL, YEAR_4_CHANNEL, YEAR_5_CHANNEL, YEAR_6_CHANNEL, 
				YEAR_7_CHANNEL, YEAR_8_CHANNEL, YEAR_9_CHANNEL, YEAR_10_CHANNEL
	
	OPTION (OPTIMIZE FOR UNKNOWN)