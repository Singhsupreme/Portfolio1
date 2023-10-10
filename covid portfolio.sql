select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select*
from PortfolioProject..Covidvaccination
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2
--Total cases vs Total deaths
--likely hood of dying in usa
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

---total cases vs population
--shows percentage of population got covid
select location, date,population, total_cases,(total_cases/population)*100 as Affected_population
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infecrion rate compared to population

select location, population, max(total_cases) as Highestinfectioncount, max((total_cases/population))*100 as Affected_population

from PortfolioProject..CovidDeaths
Group by location, population
order by Affected_population desc


----alternate note if max not used all the data of particular country will be reflected


select location, date,population, total_cases,(total_cases/population)*100 as Affected_population
from PortfolioProject..CovidDeaths

order by Affected_population desc

-- showing countries with highest death count

select location, max(cast(total_deaths as int)) as Totaldeathcount

from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by Totaldeathcount desc

--- Showing the continent with the highest deathcount 
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Totaldeathcount desc


----Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date 
order by 1,2 


--- total 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date 
order by 1,2 

---Looking at total population vs vaccination 
select*
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date)
as Rolling_people_vaccinated, 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3 


---use CTE
with Popvsvac (continent, location, date , population,new_vaccinations,Rolling_people_vaccinated) 
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date)
as Rolling_people_vaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select*, (Rolling_people_vaccinated/population)*100
From Popvsvac

--Temp table
Drop table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(
continent nvarchar (255),
Location Nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
Rolling_people_vaccinated numeric
)
insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date)
as Rolling_people_vaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

select*, (Rolling_people_vaccinated/population)*100
From #Percentpopulationvaccinated

---creating view to store data for later visulization

create view Percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast( vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date)
as Rolling_people_vaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select*
from Percentpopulationvaccinated