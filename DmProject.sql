-- SELECT * FROM DmProject.covidvacciantions
-- order by 3,4; 

-- select * from DmProject.coviddeaths
-- order by 3,4;

-- Select data we will use 
select location, date, total_cases,new_cases,total_deaths, population
from DmProject.coviddeaths
order by 1,2;

-- polish the data
select location, date, total_cases,new_cases,total_deaths, population
from DmProject.coviddeaths
where continent != ''
order by 1,2;

-- Look at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from DmProject.coviddeaths
where continent != ''
order by 1,2;

-- Look at total cases vs total deaths in italy
-- likelihood of dying if you contract covid in italy
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from DmProject.coviddeaths
where location like '%italy%' 
order by 1,2;

-- Look at total cases vs population (in italy)
select location, date, population, total_cases, (total_cases/population)*100 as infection_rate
from DmProject.coviddeaths
-- where location like '%italy%' 
order by 1,2;

-- Look at countries with highest infection rate wrt population
select location, population, max(total_cases) as max_infection_count, max((total_cases/population))*100 as max_infection_rate_count
from DmProject.coviddeaths
-- where location like '%italy%' 
group by location, population
order by max_infection_rate_count desc;

-- Look at countries with highest death rate
select location, max(total_deaths) as max_deaths_count
from DmProject.coviddeaths
-- where location like '%italy%' 
group by location
order by max_deaths_count desc;

-- Issue with data type we need to cast it as an integer (as numeric)
select location, max(cast(total_deaths as unsigned)) as max_deaths_count
from DmProject.coviddeaths
where continent != ''
group by location
order by max_deaths_count desc;

-- by continent
select location, max(cast(total_deaths as unsigned)) as max_deaths_count
from DmProject.coviddeaths
where continent = '' and iso_code != 'OWID_UMC' and iso_code != 'OWID_HIC' and iso_code != 'OWID_LIC' and iso_code != 'OWID_LMC' and iso_code != 'OWID_INT'
group by location
order by max_deaths_count desc;

-- continents with highest death count
-- problem with northamerica but simpler and goo ordering
select continent, max(cast(total_deaths as unsigned)) as max_deaths_count
from DmProject.coviddeaths
where continent != ''
group by continent
order by max_deaths_count desc;

-- Reminder: drill down

-- global numbers 
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_rate
from DmProject.coviddeaths
where continent != ''
group by date 
order by 1,2;

-- join tables
-- total population vs vaccination
-- use cte
with PopVsVac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
from DmProject.coviddeaths dea
join DmProject.covidvacciantions vac
	on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent != ''
)
select *, (rolling_total_vaccinations/population)*100 as rolling_vaccination_rate
from PopVsVac

