--SELECT *
--FROM SecondPortfolioProject.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM SecondPortfolioProject.DBO.CovidVaccinations
--ORDER BY 3,4

--the above 2 formulas show all of the data in the dataset I've uploaded



SELECT location, total_cases, population, total_deaths, hosp_patients, icu_patients
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT location, total_cases, population, total_deaths, hosp_patients, icu_patients
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%' AND
				total_cases is NOT NULL	
ORDER BY 1,2

SELECT continent, location, date, total_cases, population, total_deaths, hosp_patients, icu_patients
FROM SecondPortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 2,3



--total cases vs total deaths the percentage of people who died of the people who had covid as of that date of the data collected

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 as DeathPercentage
FROM SecondPortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 as DeathPercentage
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--a look at the deathpercentage in comparison to the number of patients hospitalized due to covid19 and new weekly hospital admissions due to covid19
SELECT location, date, total_cases, total_deaths, weekly_hosp_admissions, hosp_patients, (CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 as DeathPercentage
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--a look at the deathpercentage in comparison to the number of icu patients due to covid19 and new weekly icu admissions due to covid19
SELECT location, date, total_cases, total_deaths, weekly_icu_admissions, icu_patients, (CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2)))*100 as DeathPercentage
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--takes a look at the percentage of the population that has confirmed cases of covid19
SELECT location, date, population, total_cases, (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 AS PercentPopulationPercentage
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

--shows the highest infection rate by location/country; looking at the highest number of cases
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM SecondPortfolioProject.dbo.CovidDeaths 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--this will allow a drill down effect for visualizations
SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM SecondPortfolioProject.dbo.CovidDeaths 
GROUP BY continent, population
ORDER BY PercentPopulationInfected DESC

--shows the highest death count per country
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM SecondPortfolioProject.dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--in this query the north america category is not showing the numbers for canada, making it an inaccurate count
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM SecondPortfolioProject.dbo.CovidDeaths 
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--this query has categories that are not actual places so it wouldn't be good to use those categories
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--sum of the global numbers for new confirmed covid19 cases and new deaths as well percentage of new cases and new deaths by date globally; nullif is used here because some numbers in the data are 0
SELECT date, SUM(new_cases) as NewCases, SUM(CAST(new_deaths AS int)) as NewDeaths, SUM(CAST(new_deaths AS int))/SUM(nullif(new_cases,0))*100 AS GlobalDeathPercent
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
--shows the highest number of hospitalized and ICU patients on a given date globally with confirmed covid19 and the global death percentage per day
SELECT date, MAX(cast(icu_patients as int)) as ICU, MAX(cast(hosp_patients as int)) as Hospitalized, SUM(CAST(new_deaths AS int))/SUM(nullif(new_cases,0))*100 AS GlobalDeathPercent
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT MAX(cast(icu_patients as int)) as ICU, MAX(cast(hosp_patients as int)) as Hospitalized, SUM(CAST(new_deaths AS int))/SUM(nullif(new_cases,0))*100 AS GlobalDeathPercent
FROM SecondPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--joining the Covid Deaths and Covid Vaccinations tables
SELECT *
FROM SecondPortfolioProject.dbo.CovidDeaths
	JOIN SecondPortfolioProject.dbo.CovidVaccinations
			ON SecondPortfolioProject.dbo.CovidDeaths.location = SecondPortfolioProject.dbo.CovidVaccinations.location
				AND SecondPortfolioProject.dbo.CovidDeaths.date = SecondPortfolioProject.dbo.CovidVaccinations.date

--looking at the new vaccinations given in comparison to the population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SecondPortfolioProject.dbo.CovidDeaths as dea
	JOIN SecondPortfolioProject.dbo.CovidVaccinations as vac
			ON dea.location = vac.location
				AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--showing the number of vaccinations given and people fully vaccinated against covid19 daily by country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, vac.people_fully_vaccinated
FROM SecondPortfolioProject.dbo.CovidDeaths as dea
	JOIN SecondPortfolioProject.dbo.CovidVaccinations as vac
			ON dea.location = vac.location
				AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--comparing the diabetes prevalence and cardiovascular death rate to the number of patients hospitalized and in the icu due to covid19
SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, dea.icu_patients, dea.hosp_patients, vac.diabetes_prevalence, vac.cardiovasc_death_rate
FROM SecondPortfolioProject.dbo.CovidDeaths as dea
	JOIN SecondPortfolioProject.dbo.CovidVaccinations as vac
			ON dea.location = vac.location
				AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--this can be used to show a rolling count of the vaccination numbers, if the total size is too big in the ORDER BY function the query will not run
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingVacCount
FROM SecondPortfolioProject.dbo.CovidDeaths as Dea
	JOIN SecondPortfolioProject.dbo.CovidVaccinations as Vac
		ON Dea.location = Vac.location 
			AND Dea.date = Vac.date
WHERE Dea.continent is not null
ORDER BY 2,3

---- views created for visualizations

USE SecondPortfolioProject
GO
CREATE VIEW DiabetesPrevalence as
SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_deaths, dea.icu_patients, dea.hosp_patients, vac.diabetes_prevalence, vac.total_vaccinations
FROM SecondPortfolioProject.dbo.CovidDeaths as dea
	JOIN SecondPortfolioProject.dbo.CovidVaccinations as vac
			ON dea.location = vac.location
				AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

USE SecondPortfolioProject
GO
CREATE VIEW InfectionCount as
SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM SecondPortfolioProject.dbo.CovidDeaths 
GROUP BY continent, population
--ORDER BY PercentPopulationInfected DESC

USE SecondPortfolioProject
GO
CREATE VIEW HospitalPatients as
SELECT continent, location, date, total_cases, population, total_deaths, hosp_patients, icu_patients
FROM SecondPortfolioProject.dbo.CovidDeaths
--ORDER BY 2,3