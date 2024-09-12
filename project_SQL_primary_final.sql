# project_SQL_primary_final 
# (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)
CREATE OR REPLACE VIEW t_michal_jelinek_project_SQL_primary_final AS
SELECT round(avg(value),2) AS value
	,value_type_code 
	,industry_branch_code AS industry_and_region_code
	,payroll_year AS v_year
FROM czechia_payroll cp
WHERE value_type_code = 5958 AND value > 0
GROUP BY industry_branch_code, payroll_year
UNION
SELECT round(avg(value),2) AS value
	,category_code AS value_type_code
	,region_code AS industry_and_region_code
	,YEAR(date_from) AS v_year
FROM czechia_price
GROUP BY category_code, region_code, YEAR(date_from) 


#DROP VIEW IF EXISTS t_michal_jelinek_project_SQL_primary_final