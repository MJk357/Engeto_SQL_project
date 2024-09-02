# 3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT cpc.name 
	,ceny.act_year
	,ceny.act_avg_price
	,ceny.next_year
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