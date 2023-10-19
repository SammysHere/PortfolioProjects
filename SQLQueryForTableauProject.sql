--using the below queries to look at all of the data in the tables

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations
--WHERE continent is not null
ORDER BY 3,4

--Total Deaths, total new cases, total cases from COVID-19 by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2

SELECT location, continent, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2

--as of the last date of collection for this dataset, Infection rates globally
SELECT location,continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths 
GROUP BY location, continent, population
ORDER BY PercentPopulationInfected DESC













