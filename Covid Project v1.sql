-- First i check that all the data have been imported

Select * 
from CovidProject..CovidDeaths

select * 
from CovidProject..CovidVaccinations

-- From the table CovidDeaths i select the data that i will be using

Select location,date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
order by 1,2   --order by location and date to be easier to organise

-- How many deaths have occured versus the total cases per country at the most recent date (for most countries)? (percentage)
-- Shows likelihood of dying if you contract covid

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null and date = '2023-02-10 00:00:00.000'
order by 1

-- What is the percentage in Greece from the beginning?

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%Greece%'
and continent is not null 


-- What percentage of population has gotten Covid?

Select location,date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidProject..CovidDeaths
where location like '%Greece%'

-- Which Countries have the highest infection rate compared to Population?

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasesPercentage
from CovidProject..CovidDeaths
Group by location, population
order by CasesPercentage desc

-- Which Countries have the highest death numbers

Select location, max(cast(total_deaths as int)) as totaldeathcount  -- Converted from nvarchar to integer
from CovidProject..CovidDeaths
where continent is not null
Group by location
order by totaldeathcount desc

-- Break things by continent

-- Which Continents have the highest death numbers?

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidProject..CovidDeaths
where continent is not null
Group by continent
order by totaldeathcount desc


-- GLOBAL NUMBERS

Select date, sum(new_cases), sum (cast(new_deaths as int)) 
from CovidProject..CovidDeaths
where continent is not null
group by date
order by 1

-- death percentage per day since the beginning

Select date, sum(new_cases) as totalcases, sum (cast(new_deaths as int)) as totaldeaths , sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidProject..CovidDeaths
where continent is not null
group by date
order by 1

-- death percentage per total population

Select sum(new_cases) as totalcases, sum (cast(new_deaths as int)) as totaldeaths , sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidProject..CovidDeaths
where continent is not null
-- group by date
order by 1,2


-- What percentage of population has received at least one vaccine?

Select * 
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
 From ProjectPortfolio..CovidDeaths dea
 Join ProjectPortfolio..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
 From ProjectPortfolio..CovidDeaths dea
 Join ProjectPortfolio..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
 From ProjectPortfolio..CovidDeaths dea
 Join ProjectPortfolio..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
