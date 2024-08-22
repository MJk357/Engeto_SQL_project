# 2. Kolik je možné si koupit litrů mléka (114201) a kilogramů chleba (111301) za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH milk_bread AS (
	SELECT round(avg(value),2) AS price
		,value_type_code 
		,v_year 
	FROM t_michal_jelinek_project_sql_primary_final tmjpspf
	WHERE value_type_code IN (114201, 111301) #AND v_year IN (2006, 2007, 2008)
	GROUP BY value_type_code, v_year 
)
SELECT 
	cpc.name 
	,m.v_year AS 'year'
	,m.price
	,p.payroll
	,floor(p.payroll/m.price) AS pcs_per_payroll
FROM (
	SELECT *
	FROM milk_bread
	WHERE (value_type_code, v_year) IN
	    (SELECT value_type_code, MIN(v_year) 
	     FROM milk_bread 
	     GROUP BY value_type_code
	     UNION ALL
	     SELECT value_type_code, MAX(v_year) 
	     FROM milk_bread 
	     GROUP BY value_type_code)
) m	     
LEFT JOIN
	(
	SELECT round(avg(value),2) AS payroll
		,v_year AS p_year
	FROM t_michal_jelinek_project_sql_primary_final tmjpspf 
	WHERE value_type_code = 5958
	GROUP BY v_year
	) p
ON p.p_year = m.v_year
LEFT JOIN
	czechia_price_category cpc 
ON cpc.code = m.value_type_code

