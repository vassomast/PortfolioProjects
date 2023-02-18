Select * 
from ProjectPortfolio..CovidDeaths
order by 3,4

--select * 
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

--select data that we are goinf to be using

Select location,date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like '%Greece%'
order by 1,2

-- looking total cases vs population
-- shows percentage of population that got covid

Select location,date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from ProjectPortfolio..CovidDeaths
where location like '%Greece%'
order by 1,2

-- show Countries with highest infection rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasesPercentage
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
Group by location, population
order by CasesPercentage desc

-- show Countries with highest death count per Population

Select location, max(cast(total_deaths as int)) as totaldeathcount
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is not null
Group by location
order by totaldeathcount desc

-- Break things by continent

-- correct way to break by continent

Select location, max(cast(total_deaths as int)) as totaldeathcount
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is null
Group by location
order by totaldeathcount desc

-- showing continents with highest death count

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is not null
Group by continent
order by totaldeathcount desc

-- GLOBAL NUMBERS

Select date, sum(new_cases), sum (cast(new_deaths as int)) 
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is not null
group by date
order by 1,2

-- death percentage

Select date, sum(new_cases) as totalcases, sum (cast(new_deaths as int)) as totaldeaths , sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as totalcases, sum (cast(new_deaths as int)) as totaldeaths , sum (cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from ProjectPortfolio..CovidDeaths
-- where location like '%Greece%'
where continent is not null
-- group by date
order by 1,2


--looking at total population vs vaccinations

Select * 
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location
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