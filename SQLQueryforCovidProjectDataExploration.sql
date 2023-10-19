
SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations
ORDER BY 3,4

--this query is to select the data that I'll be using!

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2

--total cases vs total deaths, unable to change the column types to integer so used the formula below instead of (total_deaths/total_cases)
--the percentage can be used as the likelihood of death from covid

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--total cases vs population, the percentage of the pop that has been diagnosed with covid-19

SELECT location, date, population, total_cases, (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths 
--WHERE location LIKE 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing the highestdeathcount by population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths 
--WHERE location LIKE 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths 
--WHERE location LIKE 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS int)), SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases), SUM(CAST(new_deaths AS int)), SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--VACCINATIONS

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date


----new vaccinations
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

----rolling count

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

----total population&vax, using a column name that you just created produces an error

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount,
	(RollingVacCount/population)*100
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

-------So a CTE would be better to use

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVacCount)
as
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
	FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
--ORDER BY 2,3 
)
SELECT *, (RollingVacCount/population)*100 --rolling percentage
FROM PopvsVac

-------OR temp table can be used

DROP TABLE if exists #PercentPopulationVaccinated ----this removes the table but you can keep the code here
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVacCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
	FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
--ORDER BY 2,3 

SELECT *, (RollingVacCount/population)*100 
FROM #PercentPopulationVaccinated


----view created to look at the percent of the population vaccinated
USE [Portfolio Project] 
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
	FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
--ORDER BY 2,3 