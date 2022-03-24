-- PART I: coviddeaths
	-- 1) overview
	-- 2) total cases vs total deaths
    -- 3) total cases vs total deaths in italy 
    -- 4) total cases vs population (in italy)
    -- 5) hospitalised patients rate vs death rate
    -- 6) countries with highest death rate
    -- 7) countries with highest infection rate wrt population
	-- 8) highest number of deaths by country 
    -- 9) highest number of deaths by continent 
    -- 10) global death rate
    
-- 1) overview
select location, date, total_cases,new_cases,total_deaths, population
from coviddeaths
where continent != ''
order by 1,2;

-- 2) total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
from coviddeaths
where continent != ''
order by 1,2;

-- 3) total cases vs total deaths in italy 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate_italy
from coviddeaths
where location like '%italy%' 
order by 1,2;

-- 4) total cases vs population (in italy)
select location, date, population, total_cases, (total_cases/population)*100 as infection_rate
from coviddeaths
-- where location like '%italy%' 
order by 1,2;

-- 5) hospitalised patients rate vs death rate
-- 


-- 6) countries with highest death rate
select location, max(total_deaths) as max_deaths_count
from coviddeaths
group by location
order by max_deaths_count desc;

-- 7) countries with highest infection rate wrt population
select location, population, max(total_cases) as max_infection_count, max((total_cases/population))*100 as max_infection_rate_count
from coviddeaths 
group by location, population
order by max_infection_rate_count desc;

-- 8) highest number of deaths by country 
select location, max(cast(total_deaths as unsigned)) as max_deaths_count
from DmProject.coviddeaths
where continent != ''
group by location
order by max_deaths_count desc;

-- 9) highest number of deaths by continent 
select location, max(cast(total_deaths as unsigned)) as max_deaths_count
from DmProject.coviddeaths
where continent = '' and iso_code != 'OWID_UMC' and iso_code != 'OWID_HIC' and iso_code != 'OWID_LIC' and iso_code != 'OWID_LMC' and iso_code != 'OWID_INT'
group by location
order by max_deaths_count desc;

-- 10) global death rate
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_rate
from DmProject.coviddeaths
where continent != ''
group by date 
order by 1,2;

-- PART 2: covidvaccinations
	-- 1) overview
	-- 2) peaks of infections and deaths in italy wrt average test
    -- 3) peaks of infections and deaths in italy wrt average test before 2021
    -- 4) total population vs vaccination (countries and continents)

-- 1) overview
select location, date, population, total_tests, positive_rate, total_vaccinations
from covidvaccinations
where continent != ''
order by 1,2;

-- 2) peaks of infections and deaths in italy wrt average test
select D.location, D.date, max(new_cases) as cases_peacks, V.date, avg(new_tests)
from coviddeaths D join covidvaccinations V on
	D.location=V.location and D.date=V.date
where D.location like '%italy%'
group by D.location, D.date
order by 3 desc
limit 5;

-- 3) peaks of infections and deaths in italy wrt average test before 2021
select D.location, D.date, max(new_cases) as cases_peacks, V.date, avg(new_tests)
from coviddeaths D join covidvaccinations V on
	D.location=V.location and D.date=V.date
where D.location like '%italy%' and D.date < '2021-1-1'
group by D.location, D.date
order by 3 desc
limit 5;

-- 4) total population vs vaccination (countries and continents)
with PopVsVac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
from DmProject.coviddeaths dea
join DmProject.covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent != ''
)
select *, (rolling_total_vaccinations/population)*100 as rolling_vaccination_rate
from PopVsVac;

-- PART 3: nested queries and relational algebra queries on the slices
	-- TO DO
    
    

-- EXTRAS
-- takes a bit... it is just an example of natural join (not particularly significative)
select distinct coviddeaths.continent
from coviddeaths, covidvacciantions
where coviddeaths.location = covidvacciantions.location  
	and coviddeaths.total_cases_per_million>1000;

-- 
select location, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as global_death_rate
from DmProject.coviddeaths
where continent = '' or iso_code = 'OWID_UMC' or iso_code = 'OWID_HIC' 
	or iso_code = 'OWID_LIC' or iso_code = 'OWID_LMC' or iso_code = 'OWID_INT' 
group by location 
order by 4;

-- average vaccination rate by country
select location, avg(people_fully_vaccinated)/population
from DmProject.covidvacciantions
where(continent = '' or iso_code = 'OWID_UMC' or iso_code = 'OWID_HIC' 
	or iso_code = 'OWID_LIC' or iso_code = 'OWID_LMC' or iso_code = 'OWID_INT')
    and iso_code != 'OWID_INT'
group by location 
order by 1;

-- ?
select location
from DmProject.covidvacciantions
where (total_boosters > new_vaccinations) and median_age > 35
group by location;
						
