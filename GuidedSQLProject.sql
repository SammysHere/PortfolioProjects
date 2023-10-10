--this 2 queries used to double check that the tables came in correctly! in ORDER BY the numbers refer to the columns in the SELECT statement i.e. it will order by the first column written if you put 1

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccinations
--ORDER BY 3,4

--this query is to select the data that we'll be using!

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2

--total cases vs total deaths, unable to change the column types to integer so used the formula below instead of (total_deaths/total_cases)
--the percentage can be used as the likelihood of death from covid

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--total cases vs population, the percentage of the pop has gotten covid

SELECT location, date, population, total_cases, (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--countries with highest infection rate compared to the population

SELECT location, MAX(total_cases) AS HighestInfectionCount, total_deaths, MAX((CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--ERROR: Column 'Portfolio Project.dbo.CovidDeaths.location' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY claus
--e. nEED to add GROUP BY!

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing the highestdeathcount by population, remember you need group by when you do an aggregate function, use CAST() to change the data type

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--double check the NA number, it seems to only be counting the number for USA and not other NA countries!
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
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

--BY CONTINENT, for drill down affect in visualization, do the other codes with continent!

-- global numbers!!!!!!

SELECT date, total_cases, (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location LIKE 'United States'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--got this error: Column 'Portfolio Project.dbo.CovidDeaths.total_cases' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
------this is b/c there are several columns in the SELECT and so it cant group by only the date, in order to do thie we have to put the other columns in aggregate functions

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


----new vaccinations!!!
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

----rolling count, this adds up each row cumulatively one after another, if you take off the order by in SELECT the number will be the same for each location instead of adding up daily per row

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

----total population&vax, you cannot use a column name that you just created in calculations, you will get an error

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount,
	(RollingVacCount/population)*100
FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
ORDER BY 2,3

-------instead you can use a cte, remember all of the columns named in SELECT must be in the WITH statement and put your SELECT * at the end!

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
SELECT *, (RollingVacCount/population)*100 --the division is doing a rolling %, be sure to run the full script including the CTE script!
FROM PopvsVac

-------OOOOR you could do a temp table, you must specify data types just like a reg table

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


----putting things in a view allows you to look at it in later visualization software, VIEWS ARE PERMANENT and you can query off of it!
USE [Portfolio Project] ---have to do this when the database you are connected to isn't the one you want to put the view in
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingVacCount
	FROM [Portfolio Project].dbo.CovidDeaths as Deaths
	JOIN [Portfolio Project].dbo.CovidVaccinations as Vac
		ON Deaths.location = Vac.location 
			AND Deaths.date = Vac.date
WHERE Deaths.continent is not null
--ORDER BY 2,3 