Select * 
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From Portflio_Project..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 1,2
-- Select data to exploration


-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%Thai%'
and continent is not null
order by 1,2


-- Looking at the total cases vs population
-- Show that percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
where continent is not null
order by 1,2


-- Looking at countrys with highest infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing country with highest death count per population
Select Location, MAX(cast(total_deaths as int)) TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- Global numbers group by date
Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
Where continent is not null
Group by date
order by 1,2

--Global numbers
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
Where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated --Build in for running multiple time by not drop or alter it (use to be on the top)
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated



-- Create Multiple Views to store data for later uses

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


-- Look out view table
Select *
From PercentPopulationVaccinated