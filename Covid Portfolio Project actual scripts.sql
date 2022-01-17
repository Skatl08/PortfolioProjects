select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to use
 select
 location,date,total_cases,new_cases,total_deaths,population
 from PortfolioProject..CovidDeaths
 order by location,date;

 --Looking at Total Cases vs Total Deaths

 select
 location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
 from PortfolioProject..CovidDeaths
 where location='India'
 order by 1,2;

  select
 location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
 from PortfolioProject..CovidDeaths
 where location like '%states%'
 order by 1,2;

 --Looking at the total cases vs Population
 --Shows what percentage of population got covid
  select
 continent,location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 1,2;

 --show what percentage of USA population got covid
 select
 location,date,population,total_cases,(total_cases/population)*100 as PopulationPercentage
 from PortfolioProject..CovidDeaths
 where location like '%states%'
 order by 1,2;

 --Looking at Countries with Highest Infection rate compared to Population
  select
 continent,location,population,max(total_cases) as highestInfectionCount,max(total_cases/population)*100 as HighestPopulationInfected
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent,location,population
 order by HighestPopulationInfected desc;

 --LET'S BREAK THINGS DOWN BY CONTINENT
 select 
 continent,location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent,location
-- order by TotalDeathCount desc


 --Showing countires with Highest Death Count per population

 select 
 location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location
 order by TotalDeathCount desc

 --GLOBAL NUMBERS Death Percentage

 select 
 SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 --group by date
 order by 1,2

 select*
 from PortfolioProject..CovidVaccinations;

 --Joining Death and vaccination
 
 select *
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date;

 --Looking at Total Population vs Vaccinations

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3;

 --Looking at Rolling Vaccination per day per country 

 select 
 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeriodVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3;

 --USE CTE

 With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeriodVaccinated)
 as
 ( 
 select 
 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeriodVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
  )
 select *,(RollingPeriodVaccinated/population)*100 as RollingVacPopulation
 from PopvsVac
-- or
 --TEMP TABLE

drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeriodVaccinated numeric)

insert into #PercentPopulationVaccinated
 select 
 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeriodVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 --where dea.continent is not null

  select *,(RollingPeriodVaccinated/population)*100 as RollingVacPopulation
 from #PercentPopulationVaccinated


 -- create view to store data for later visualizations
 create view PercentPopulationVaccinated as
 select 
 dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeriodVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null

 select *
 from PercentPopulationVaccinated