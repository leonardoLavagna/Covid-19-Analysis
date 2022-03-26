/*

Queries used for Tableau Visualization 

*/

-- 1)
select sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(New_Cases)*100 as DeathPercentage
From coviddeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;



-- 2)
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, sum(cast(new_deaths as unsigned)) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent = ''
		and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 3)
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4)
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;


-- Extra queries
-- 5)
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3;

-- 6)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
-- Where location like '%states%'
where continent = ''
-- Group By date
order by 1,2;

-- 7)
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as unsigned)) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 8).
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- 9)
-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From coviddeaths
-- Where location like '%states%'
where continent!=''
order by 1,2;


-- 10) 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent = '' 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac;

-- 11) 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;
