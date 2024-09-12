# project_SQL_secondary_final 
# (Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR)
CREATE OR REPLACE VIEW t_michal_jelinek_project_SQL_secondary_final AS
SELECT econ.country
	,econ.YEAR
	,econ.GDP
	,econ.population
	,econ.gini
FROM engeto_2024_04_01.countries
LEFT JOIN (
	SELECT country 
	,`year` 
	,GDP 
	,population 
	,gini 
FROM engeto_2024_04_01.economies
WHERE `year` BETWEEN 2006 AND 2018
) econ
ON countries.country = econ.country
WHERE continent = 'Europe'
	AND econ.country IS NOT NULL
ORDER BY econ.country ASC