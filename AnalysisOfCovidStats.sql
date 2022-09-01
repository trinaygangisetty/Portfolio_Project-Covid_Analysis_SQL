SELECT *
FROM CovidProjectForPortfolio..CovidSpreadStatistics
ORDER BY 3,4

SELECT *
FROM CovidProjectForPortfolio..CovidVaccinationStats
where location='United States'
ORDER BY 3,4

--Selecting All Distinct Location

SELECT DISTINCT location
FROM CovidProjectForPortfolio..CovidSpreadStatistics
ORDER BY location

--Selecting the Required Data From CovidSpreadStatistics Table

SELECT location, date, population, total_cases, new_cases, total_deaths, new_deaths
FROM CovidProjectForPortfolio..CovidSpreadStatistics
WHERE location NOT IN ('High income','Low income','Lower middle income','Upper middle income','World')
ORDER BY 1,2

--Looking at Total Deaths and Total Cases Country wise.

SELECT continent, location, MAX(CAST(total_cases AS bigint)) as total_cases, MAX(CAST(total_deaths AS bigint)) as total_deaths
FROM CovidProjectForPortfolio..CovidSpreadStatistics
WHERE location NOT IN ('High income','Low income','Lower middle income','Upper middle income','World')
      AND continent IS NOT NULL
GROUP BY continent, location
order by 4 desc,3 desc

--Looking at death percentage for India

SELECT continent, location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidProjectForPortfolio..CovidSpreadStatistics
WHERE location like '%India%'
order by 3 desc

--Country with highest death percentage

SELECT continent, 
       location, 
	   MAX(CAST(total_deaths as bigint)) as latestDeathCount, 
	   MAX(total_cases) as TotalCases, 
	   (MAX(CAST(total_deaths as bigint))/MAX(total_cases))*100 as death_percentage, -- MAX was used because the structure of the data in table is continuos.
	   RANK() OVER(ORDER BY (MAX(CAST(total_deaths as bigint))/MAX(total_cases))*100 DESC) AS RankingAsPerDeathRate
FROM CovidProjectForPortfolio..CovidSpreadStatistics
WHERE location NOT IN ('High income','Low income','Lower middle income','Upper middle income','World','North Korea') --North Korea data is incorrect. So, excluded it.
      AND continent IS NOT NULL
GROUP BY continent, location
order by 5 desc


--Continent with total death count and highest Infection Rate

SELECT location,
	   max(total_cases) as latest_case_count, 
	   max(population) as total_population,
	   max(cast(total_deaths as bigint)) as latest_death_toll,
	   ROUND(max(total_cases)/max(population)*100,3) as infection_rate,
	   DENSE_RANK() OVER(ORDER BY max(total_cases)/max(population) DESC) as highest_ranking_continent
from (SELECT location, total_cases, population, total_deaths
      FROM CovidProjectForPortfolio..CovidSpreadStatistics 
	  where location in ('Europe','Oceania','North America','South America','Asia','Africa')) as filtered
group by location;



-- Total cases daily all over the world with rolling numbers column
WITH toll_table (date, new_cases_per_day, new_deaths_per_day, rolling_total_case_count, rolling_total_death_roll)
as (
SELECT date, 
       sum(new_cases) as new_cases_per_day,
	   sum(CAST(new_deaths as bigint)) as new_deaths_per_day,
	   sum(sum(new_cases)) over(order by date) as rolling_total_case_count,
	   sum(sum(CONVERT(bigint,new_deaths))) over(order by date) as rolling_total_death_toll
from CovidProjectForPortfolio..CovidSpreadStatistics
where continent is not null 
group by date
--order by 1
)
SELECT *, (rolling_total_death_roll/rolling_total_case_count)*100 as death_percentage_daily
FROM toll_table
order by 1


--Percent of people Vaccinated

DROP TABLE IF EXISTS #VaccinationStatus

CREATE TABLE #VaccinationStatus
(Continent nvarchar(255),
 Location nvarchar(255),
 Population numeric,
 Total_people_vaccinated integer)

INSERT INTO #VaccinationStatus
SELECT spr.continent,
       spr.location,
       spr.population,
	   max(CONVERT(bigint,vac.people_vaccinated)) as Total_people_vaccinated
FROM CovidProjectForPortfolio..CovidSpreadStatistics spr
JOIN CovidProjectForPortfolio..CovidVaccinationStats vac
ON spr.location = vac.location
   and spr.date = vac.date
where spr.continent is not null
group by spr.continent,
         spr.location,
         spr.population
order by 2,3

SELECT *, 
      (Total_people_vaccinated/Population)*100 as percentOfPeopleVaccinated,
	  CASE WHEN (Total_people_vaccinated/Population)*100 > 70 THEN 'SAFE'
	       WHEN (Total_people_vaccinated/Population)*100 > 40 THEN 'MODERATE'
		   ELSE 'UNSAFE' END AS CountryStatus
From #VaccinationStatus
order by 5 desc


--PERCENT People vaccinated with rolling numbers


DROP Table if exists #PeopleVaccinated

Create Table #PeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PeopleVaccinated
Select spr.continent, 
       spr.location, 
	   spr.date, 
	   spr.population, 
	   vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by spr.Location Order by spr.location, spr.Date) as RollingPeopleVaccinated
From CovidProjectForPortfolio..CovidSpreadStatistics spr
Join CovidProjectForPortfolio..CovidVaccinationStats vac
	On spr.location = vac.location
	and spr.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PeopleVaccinated
order by 2,3