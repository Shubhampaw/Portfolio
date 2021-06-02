/*


Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


*/




---**** INFECTION AND DEATHS ANALYSIS ****---



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

-- Maximum  deaths for different continents

SELECT continent, Max(cast(total_deaths as int)) as Maximum_deaths
FROM CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY Maximum_deaths DESC


-- Maximum deaths for different Countries in Asia

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





---%**** VACCINATION ANALYSIS ****%---



--How many people have been vaccinated globally till 28th may? 817 mn


SELECT sum(Total_vaccinated) as total_globally_vaccinated_people
FROM
 (

SELECT cd.location, Max(cast(people_vaccinated as int)) as Total_vaccinated FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
) tab

--Daily people vaccination count in India till 28th may? 160mn

SELECT cd.location, cd.date, Max(cast(cv.people_vaccinated as int)) as A FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null and cd.location like '%India%'
GROUP BY cd.location,cd.date
ORDER BY A desc


--**Country wise Daily Vaccination count**--

With PopsvsVacs  as
(
SELECT cd.continent,cd.location, cd.date, cv.new_vaccinations,cd.population,

Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date)  as Running_total

FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null  
)
SELECT location, date, 
(Running_total/population)*100 as Percent_vaccinated_global
from PopsvsVacs
WHERE new_vaccinations is not null;


--**India's Daily Vaccination count with perceentage**--

-- Insights derived - 
--1. 13.82% vaccinated so far | 2. 190 million people vaccinated out of 1380 mn
 

With PopsvsVacs  as
(
SELECT cd.continent,cd.location, cd.date, cv.new_vaccinations,cd.population,

Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date)  as Running_total

FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null  and cd.location like '%India%'
)

SELECT continent,location, date, population,Running_total,
(Running_total/population)*100 as Percent_vaccinated
FROM PopsvsVacs WHERE PopsvsVacs.new_vaccinations is not null
Order by Percent_vaccinated desc


--- Created view which inlcudes Running total to use it later in visualitzation

Create View PercentpopulationvaccinatedGlobal as

SELECT cd.continent,cd.location, cd.date, cv.new_vaccinations,cd.population,

Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date)  as Running_total

FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null  


SELECT * FROM  PercentpopulationvaccinatedGlobal
