/* Covid 19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, COnverting Data Types

*/
/*
--------------EDA LIST---------------
	-Total Cases vs Total Deaths
	-Total Cases vs Population
	-Countries with Highest Infection Rate compared to Population
	-Countries with Highest Death Count per Population
	-Showing contintents with the highest death count per population
	-Total Population vs Vaccinations
	-Using Temp Table to perform Calculation on Partition By in previous query
	-Creating View to store data for later visualizations
*/

SELECT *
FROM covid19.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

SELECT *
FROM covid19.dbo.CovidVaccine
WHERE continent is not null 

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid19.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows percentage of deaths from total cases in a country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Percentage_of_deaths
FROM covid19.dbo.CovidDeaths
WHERE location LIKE '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Percented_of_infected
FROM covid19.dbo.CovidDeaths
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX((total_cases/population) * 100) AS HighestInfection
FROM covid19.dbo.CovidDeaths
GROUP BY location, population
ORDER BY HighestInfection DESC


-- Countries with Highest Death Count per Population

SELECT location, population, MAX(total_deaths) AS HighestDeaths
FROM covid19.dbo.CovidDeaths
GROUP BY location, population
ORDER BY HighestDeaths DESC

-- Showing contintents with the highest death count per population

SELECT  continent, MAX(CAST(total_deaths AS int)) AS HighestDeathsPerCont
FROM covid19.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathsPerCont DESC


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.location, CD.date, CD.population, 
	SUM(CONVERT(bigint,CC.total_vaccinations))  OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Vac
FROM covid19.dbo.CovidDeaths AS CD
JOIN covid19.dbo.CovidVaccine AS CC
	ON CD.location = CC.location
	AND CD.date = CC.date
WHERE CD.continent IS NOT NULL
AND CC.total_vaccinations IS NOT NULL
---GROUP BY CD.location, CD.date, CD.population
ORDER BY CD.location ASC, Total_Vac DESC

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
Totall_Vaccinations numeric

)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.location, CD.date, CD.population,
	SUM(CONVERT(bigint,CC.total_vaccinations))  OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Totall_Vaccinations
FROM covid19.dbo.CovidDeaths AS CD
JOIN covid19.dbo.CovidVaccine AS CC
	ON CD.location = CC.location
	AND CD.date = CC.date
WHERE CD.continent IS NOT NULL
AND CC.total_vaccinations IS NOT NULL

SELECT *,(Totall_Vaccinations/population) * 100
FROM #PercentPopulationVaccinated