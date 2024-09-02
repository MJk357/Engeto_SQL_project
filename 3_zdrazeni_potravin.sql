# 3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT t1.name
	,avg(t1.difference_percent) AS avg_difference_percent
FROM (
	SELECT ceny.value_type_code
		,cpc.name 
		,ceny.act_year
		,ceny.act_avg_price
		,ceny.next_year
		,ceny.next_avg_price
		,ceny.next_avg_price - ceny.act_avg_price AS price_difference
		,round((ceny.next_avg_price - ceny.act_avg_price)/ceny.act_avg_price*100,2) AS difference_percent
	FROM (
		SELECT value_type_code
			,v_year AS act_year
			,avg(value) AS act_avg_price
			,lead(v_year,1) OVER (ORDER BY value_type_code, v_year) AS next_year
			,lead(avg(value),1) OVER (ORDER BY value_type_code, v_year) AS next_avg_price
		FROM t_michal_jelinek_project_sql_primary_final tmjpspf 
		WHERE value_type_code != 5958
		GROUP BY value_type_code, v_year 
		ORDER BY value_type_code, v_year
	) ceny
	LEFT JOIN czechia_price_category cpc 
		ON ceny.value_type_code = cpc.code 
	WHERE next_year - act_year = 1
) t1
GROUP BY t1.name
ORDER BY avg(t1.difference_percent) ASC 