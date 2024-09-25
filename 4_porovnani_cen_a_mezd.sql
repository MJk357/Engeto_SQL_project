# 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
SELECT ceny.period
	,ceny.name
	,ceny.difference_percent AS price_perc_difference
	,mzdy.difference_percent AS payroll_perc_difference
	,ceny.difference_percent - mzdy.difference_percent AS perc_difference
FROM (
	SELECT concat(ceny.act_year, ' - ', ceny.next_year) AS period 
		,cpc.name 
		,ceny.act_avg_price
		,ceny.next_avg_price
		,ceny.next_avg_price - ceny.act_avg_price AS price_difference
		,round((ceny.next_avg_price - ceny.act_avg_price)/ceny.act_avg_price*100,2) AS difference_percent
	FROM (
		SELECT value_type_code
			,v_year AS act_year
			,value AS act_avg_price
			,lead(v_year,1) OVER (ORDER BY value_type_code, v_year) AS next_year
			,lead(avg(value),1) OVER (ORDER BY value_type_code, v_year) AS next_avg_price
		FROM t_michal_jelinek_project_sql_primary_final tmjpspf 
		WHERE value_type_code != 5958
			AND industry_and_region_code IS NULL
		GROUP BY value_type_code, v_year 
		ORDER BY value_type_code, v_year
	) ceny
	LEFT JOIN czechia_price_category cpc 
		ON ceny.value_type_code = cpc.code 
	WHERE next_year - act_year = 1
	ORDER BY round((ceny.next_avg_price - ceny.act_avg_price)/ceny.act_avg_price*100,2) ASC
) ceny
LEFT JOIN (
	SELECT concat(mzdy.v_year, ' - ', mzdy.next_year) AS period 
		,mzdy.value AS payroll_start
		,mzdy.value_next_year AS payroll_end
		,mzdy.value_next_year - mzdy.value AS payroll_difference
		,round((mzdy.value_next_year - mzdy.value)/mzdy.value*100,2) AS difference_percent
	FROM (
		SELECT value
			,industry_and_region_code
			,v_year
			,LEAD(value,1) OVER (ORDER BY industry_and_region_code,v_year) AS value_next_year
			,LEAD(v_year,1) OVER (ORDER BY industry_and_region_code,v_year) AS next_year		
		FROM t_michal_jelinek_project_sql_primary_final
		WHERE value_type_code = 5958
		AND industry_and_region_code IS NULL
	) mzdy
	WHERE (mzdy.next_year - mzdy.v_year) = 1
	ORDER BY mzdy.v_year, mzdy.industry_and_region_code 
) mzdy
ON ceny.period = mzdy.period
ORDER BY ceny.difference_percent - mzdy.difference_percent DESC 


