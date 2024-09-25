# 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
# projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

# nebere v úvahu váhy (spotřebjí koš, tzn. množství nakupoaných potravin)
SELECT gdp.period
	,gdp.GDP_difference_percent
	,price.price_difference_percent
	,payroll.payroll_difference_percent
FROM (
	SELECT concat(gdp.`YEAR`, ' - ', gdp.next_year) AS period  
		,round((gdp.next_GDP - gdp.GDP )/gdp.GDP *100,2) AS GDP_difference_percent
	FROM (
		SELECT country
			,`YEAR`
			,GDP
			,population
			,gini
			,lead(`YEAR`,1) OVER (ORDER BY `YEAR`) AS next_year
			,lead(GDP,1) OVER (ORDER BY `YEAR`) AS next_GDP
		FROM engeto_2024_04_01.t_michal_jelinek_project_sql_secondary_final
		WHERE country = 'Czech Republic'
		ORDER BY `YEAR` 
	) gdp
	WHERE gdp.next_GDP IS NOT NULL
) gdp
LEFT JOIN (
	SELECT p.period 
		,round(avg(p.difference_percent),2) AS price_difference_percent
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
		ORDER BY period
	) p
	GROUP BY p.period
) price
ON price.period = gdp.period
LEFT JOIN (
	SELECT concat(mzdy.v_year, ' - ', mzdy.next_year) AS period 
		,round((mzdy.value_next_year - mzdy.value)/mzdy.value*100,2) AS payroll_difference_percent
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
) payroll
ON payroll.period = gdp.period








# Ceny
SELECT p.period 
	,avg(p.difference_percent) AS price_difference_percent
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
	ORDER BY period
) p
GROUP BY p.period

# Mzdy
SELECT concat(mzdy.v_year, ' - ', mzdy.next_year) AS period 
	#,mzdy.value AS payroll_start
	#,mzdy.value_next_year AS payroll_end
	#,mzdy.value_next_year - mzdy.value AS payroll_difference
	,round((mzdy.value_next_year - mzdy.value)/mzdy.value*100,2) AS payroll_difference_percent
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



# Změny v HDP
SELECT concat(gdp.`YEAR`, ' - ', gdp.next_year) AS period  
	,round((gdp.next_GDP - gdp.GDP )/gdp.GDP *100,2) AS GDP_difference_percent
FROM (
	SELECT country
		,`YEAR`
		,GDP
		,population
		,gini
		,lead(`YEAR`,1) OVER (ORDER BY `YEAR`) AS next_year
		,lead(GDP,1) OVER (ORDER BY `YEAR`) AS next_GDP
	FROM engeto_2024_04_01.t_michal_jelinek_project_sql_secondary_final
	WHERE country = 'Czech Republic'
	ORDER BY `YEAR` 
) gdp
WHERE gdp.next_GDP IS NOT NULL

