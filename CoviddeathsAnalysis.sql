


--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM CovidDeaths ORDER BY 1,2


-- Total cases vs Total deaths.
-- Likely to die.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths Where location like '%India%' ORDER BY 1,2

-- Total cases by Total Population

SELECT location, date, total_cases, total_deaths, (total_cases/ population)*100 AS Infection_percentage, population
FROM CovidDeaths Where location like '%India%' ORDER BY 1,2

--Infection rates--

SELECT location, population, Max(total_cases) AS Max_cases,
Max((total_cases/ population)*100) AS Infection_percentage
FROM CovidDeaths 
GROUP BY location,population 
ORDER BY Infection_percentage DESC


-- Maximum deaths for different countries

SELECT location,Max(cast(total_deaths as int)) as total_deaths
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths DESC

-- Maximum (not total) deaths for different continents

SELECT continent, Max(cast(total_deaths as int)) as Maximum_deaths
FROM CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY Maximum_deaths DESC


-- Maximum (not total) deaths for different Countries in Asia

SELECT continent, location, Max(cast(total_deaths as int)) as Maximum_deaths
FROM CovidDeaths 
WHERE continent is not null and continent like '%Asia%'
GROUP BY continent,location
ORDER BY Maximum_deaths DESC


--GLOBAL NUMBERS

SELECT date,SUM(Cast(total_deaths as int)) as Total_deaths, SUM(total_cases) as  Total_cases,
(SUM(Cast(total_deaths as int))/SUM(total_cases))*100 as Death_percentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date desc

--GLOBAL NUMBERS (observation) : Astonishing 170 millions of cases till date and 3.5 million deaths!

