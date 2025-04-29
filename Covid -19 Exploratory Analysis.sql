select * 
from [potfolio project]..CovidDeaths$
order by 3, 4

--select * 
--from [potfolio project]..CovidVaccinations$
--order by 3, 4

-- Selecting data for usage
select location, date, total_cases, new_cases, total_deaths, population
from [potfolio project]..CovidDeaths$
where continent is not null
order by 1, 2


-- Looking at Total cases VS Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [potfolio project]..CovidDeaths$
where location like 'india'
order by 1, 2


-- Looking at total cases VS Population
-- Shows how much got infected by covid
select location, date, population,  total_cases, (total_cases/population)*100 as Percent_Population_Infected
from [potfolio project]..CovidDeaths$
--where location like 'india'
order by 1,2


-- Looking location with highest infection compared to population
select location, population,  max(total_cases) as Highest_Infection_count, max((total_cases/population))*100 as Percent_Population_Infected
from [potfolio project]..CovidDeaths$
-- where location like 'india'
where continent is not null
group by location, population
order by Percent_Population_Infected desc


-- Showing Countries with Highest Death Count 
select location, max(cast(total_deaths as int)) as Highest_Death_count  
from [potfolio project]..CovidDeaths$
--where location like 'india'
where continent is not null
group by location
order by Highest_Death_count desc


-- Exploring Continents
select continent, max(cast(total_deaths as int)) as Total_Death_count  
from [potfolio project]..CovidDeaths$
--where location like 'india'
where continent is not null
group by continent
order by Total_Death_count desc

-- Global Death Percentage
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Global_Death_Percentage
from [potfolio project]..CovidDeaths$
--where location like 'india'
where continent is not null
--group by date
order by 1, 2

-- Looking as Total Population VS New Vacinations, Using CTE
with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vacinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [potfolio project]..CovidDeaths$ dea
join [potfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rolling_people_vacinated/population)*100
from popvsvac


--Temp Table
drop table if exists Percentage_population_vaccinated
create Table Percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into Percentage_population_vaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [potfolio project]..CovidDeaths$ dea
join [potfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rolling_people_vaccinated/population)*100
from Percentage_population_vaccinated

-- Creating a view for further visualization 
create view Percentagepopulationvaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [potfolio project]..CovidDeaths$ dea
join [potfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [potfolio project]..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [potfolio project]..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [potfolio project]..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [potfolio project]..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

