# 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT concat(mzdy.v_year, ' - ', mzdy.next_year) AS period 
	,cpib.name
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
	AND industry_and_region_code IS NOT NULL
) mzdy
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = mzdy.industry_and_region_code
WHERE (mzdy.next_year - mzdy.v_year) = 1
	AND mzdy.value_next_year - mzdy.value < 0
ORDER BY mzdy.v_year, mzdy.industry_and_region_code 
