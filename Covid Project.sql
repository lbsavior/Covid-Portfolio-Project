select * 
from [Covid Portfolio Project]..CovidDeaths$
Where continent is not null
order by 3,4

--select * 
-- from CovidPortfoli..CovidVaccinations
--order by 3,4

--Select data that we are going to be using


--looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you 
select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at the total cases vs Population
-- Shows what percentage of population got covid
select Location, date, total_cases, population, total_deaths, (total_cases/population)*100 as InfectedPercentage
from [Covid Portfolio Project]..CovidDeaths$
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectedPercentage
from [Covid Portfolio Project]..CovidDeaths$
--where location like '%states%'
Group By location, population
order by InfectedPercentage desc


-- showing countries with highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [Covid Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group By location
order by TotalDeathCount desc


-- Let's bresk things down bu continent
--Showing the continents with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Covid Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount desc


--Breaking Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths$
-- Where location like '%state%'
where continent is not null
Group By date
order by 1,2


-- Looking at total Populatiom Vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated 
From [Covid Portfolio Project]..CovidDeaths$ dea
Join [Covid Portfolio Project]..CovidVaccinationData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Portfolio Project]..CovidDeaths$ dea
Join [Covid Portfolio Project]..CovidVaccinationData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
select * , RollingPeopleVaccinated/population*100
from PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Portfolio Project]..CovidDeaths$ dea
Join [Covid Portfolio Project]..CovidVaccinationData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)


-- Creating View to store data for later visualization


Create view PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Portfolio Project]..CovidDeaths$ dea
Join [Covid Portfolio Project]..CovidVaccinationData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)