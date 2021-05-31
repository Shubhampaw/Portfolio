-- Covid data is till 28th of May.

--How many people are vaccinated globally till 28th may? 817 mn


SELECT sum(Total_vaccinated) as total_globally_vaccinated_people
FROM
 (

SELECT cd.location, Max(cast(people_vaccinated as int)) as Total_vaccinated FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
) tab

--Daily people vaccinated count in India till 28th may? 160mn

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


--- Created view which inlcudes Running total to use it later

Create View PercentpopulationvaccinatedGlobal as

SELECT cd.continent,cd.location, cd.date, cv.new_vaccinations,cd.population,

Sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date)  as Running_total

FROM
CovidDeaths cd JOIN CovidVaccination cv 
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent is not null  


SELECT * FROM  PercentpopulationvaccinatedGlobal