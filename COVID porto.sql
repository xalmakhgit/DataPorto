select * from PortoProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortoProject..CovidVaccines
--order by 3,4

-- select data
select location, date, total_cases, new_cases, total_deaths, population 
from PortoProject..CovidDeaths
where continent is not null
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortoProject..CovidDeaths
where location like '%indonesia%'
and continent is not null
order by 1,2

--total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortoProject..CovidDeaths
--where location like '%indonesia%'
order by 1,2

--Country with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortoProject..CovidDeaths
group by location, population
--where location like '%indonesia%'
order by PercentPopulationInfected desc

-- country with highest death count
select location,  MAX(cast(total_deaths as int)) as TotalDeathsCount 
from PortoProject..CovidDeaths
where continent is not null
group by location
--where location like '%indonesia%'
order by TotalDeathsCount desc

-- continent with highest death count
select continent,  MAX(cast(total_deaths as int)) as TotalDeathsCount 
from PortoProject..CovidDeaths
where continent is not null
group by continent
--where location like '%indonesia%'
order by TotalDeathsCount desc

--GLOBAL

--select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
--from PortoProject..CovidDeaths
--where continent is not null
--group by date
--order by 1,2

--Total population vs total vaccines

select * 
from PortoProject..CovidDeaths dea
join PortoProject..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortoProject..CovidDeaths dea
join PortoProject..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with PopvsVac (continent, location, date, population, new_vacinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortoProject..CovidDeaths dea
join PortoProject..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP

--drop table if exists #PercentPopulationVaccinated
--create table #PercentPopulationVaccinated
--(
--continent varchar(255),
--location varchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)
--insert into #PercentPopulationVaccinated
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortoProject..CovidDeaths dea
--join PortoProject..CovidVaccines vac
--on dea.location = vac.location
--and dea.date = vac.date
--where dea.continent is not null
----order by 2,3

--select *, (RollingPeopleVaccinated/population)*100
--from #PercentPopulationVaccinated

--create view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortoProject..CovidDeaths dea
join PortoProject..CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
----order by 2,3

create view TotalDeathCount as
select continent,  MAX(cast(total_deaths as int)) as TotalDeathsCount 
from PortoProject..CovidDeaths
where continent is not null
group by continent
--where location like '%indonesia%'
--order by TotalDeathsCount desc

create view DeathPercentage as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortoProject..CovidDeaths
where location like '%indonesia%'
and continent is not null
--order by 1,2