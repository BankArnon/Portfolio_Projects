-- Starting with looking for overall data


-- Then looking in First Table
Select * 
From Portfolio_Project..CovidDeaths
Where continent is not null            -- Looking for Country (Location)
--Where continent is not null          -- Looking for Continents
order by 3,4

-- Then looking in Second Table
Select * 
From Portfolio_Project..CovidVaccinations
Where continent is not null
order by 3,4


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
-- Show that percentage of population got Covid in country

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
Where location like '%Thai%'					-- You can hide this row for looking for each country percentage
and continent is not null						-- Change 'and' to 'Where'
order by 1,2


-- Looking at countrys with highest infection rate compared to Population ( Max data as 15/04/2022 )
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing country with highest death count per population ( Max data as 15/04/2022 )
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
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
Where continent is not null
Group by date
order by 1,2

--Global numbers total ( Max data as 15/04/2022 )
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%Thai%'
Where continent is not null
--Group by date
order by 1,2

-------------------------------------------------

-- Looking at Total Population vs Vaccinations at least 1 dose
--USE CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, people_vaccinated as RollingPeopleVaccinated
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
--Where location like 'Thailand'

-------------------------------------------------

--Looking at New vaccinated (Please use only fix location)

Select pcv.location, pcv.date, pcd.population, pcv.people_vaccinated
--,	Convert(bigint,Lag(pcv.people_vaccinated) OVER (Order by pcv.date)) as previous_data
,	pcv.people_vaccinated - Convert(bigint,Lag(pcv.people_vaccinated) OVER (Order by pcv.date)) as New_Vaccinated
,	( pcv.people_vaccinated / pcd.population )*100 as VaccinatedperPopulation
From Portfolio_Project..CovidVaccinations pcv
LEFT Join Portfolio_Project..CovidDeaths pcd
	on pcd.date = pcv.date
	and pcd.location = pcv.location
Where pcv.location like 'Thailand'
and pcv.people_vaccinated is not null
Order by 1,2

--vaccinated can decrease death?

Select pcv.location, pcv.date, pcd.population, pcv.people_vaccinated
--,	Convert(bigint,Lag(pcv.people_vaccinated) OVER (Order by pcv.date)) as previous_data
,	pcv.people_vaccinated - Convert(bigint,Lag(pcv.people_vaccinated) OVER (Order by pcv.date)) as New_Vaccinated
,	pcd.new_cases
,	pcd.icu_patients
,	( pcv.people_vaccinated / pcd.population )*100 as VaccinatedperPopulation
From Portfolio_Project..CovidVaccinations pcv
LEFT Join Portfolio_Project..CovidDeaths pcd
	on pcd.date = pcv.date
	and pcd.location = pcv.location
Where pcv.location like 'Thailand'
and pcv.people_vaccinated is not null
Order by 1,2


--TEMP TABLE
-- Looking at Vaccinated Percentage by rolling number
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
, vac.people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated
Where continent is not null
and location like 'Thailand'
Order by 2,3



-- Create Multiple Views to store data for later uses

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, vac.people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


-- Drop view
Drop view if exists PercentPopulationVaccinated


-- Look out view table
Select *
From PercentPopulationVaccinated

-------------------------------------------------

-- Prepare table for uses
Drop table if exists Firstvaccinated
Create Table Firstvaccinated
(
VaccinateDate datetime,
Location nchar(128),
VaccinateValue numeric
)

Insert into Firstvaccinated
Select Date, location, new_vaccinations
From Portfolio_Project..CovidVaccinations
Where new_vaccinations is not null
and continent is not null
and new_vaccinations is not null
--and location like 'Afghanistan'
Order by 2


--Create View for Location with the first date of vaccination drop and value of it

-- Find the date that deploy first vaccination

Select location
, MIN(date) as 'First vaccinated'
From Portfolio_Project..CovidVaccinations
Where continent is not null
Group by location
Order by 1

-- Find first date with value that deploy

Create view firstVac as
With TestingMinD (Location, VaccinateDate, VaccinateValue, rn)
as
(
Select 
        Location,
        min(VaccinateDate) OVER (PARTITION BY Location) min_Date,
        VaccinateValue,
        row_number() OVER (PARTITION BY Location ORDER BY VaccinateDate) rn
From Firstvaccinated
)
SELECT Location, VaccinateDate, VaccinateValue
FROM TestingMinD
WHERE rn = 1


-- Call view and check value

select *
from firstVac

Select location, date, new_vaccinations
From Portfolio_Project..CovidVaccinations
Where new_vaccinations is not null  
and location like 'Denmark'

-- Drop view

Drop View if exists firstVac

-------------------------------------------------

Select *
From Portfolio_Project..CovidDeaths pcd
Join Portfolio_Project..CovidVaccinations pcv
	on pcd.date = pcv.date
	and pcd.location = pcv.location
Where pcd.location like 'Thailand'
and pcv.total_vaccinations is not null


--accesibility to vaccine? or vaccinated ratio check /
--vaccine can decrease icu

------------Note and some testing------------
--people_vaccinated = people that receive at least 1 dose
--people_fully_vaccinated = people receive 2 doses

--Select pcv.location, pcv.date, pcd.population, pcv.people_vaccinated,
--		SUM(Convert(bigint,pcv.people_vaccinated)) OVER (Order by pcv.date
--											Rows Between UNBOUNDED PRECEDING
--												and current Row)
--			as New_Vaccinated
--From Portfolio_Project..CovidVaccinations pcv
--LEFT Join Portfolio_Project..CovidDeaths pcd
--	on pcd.date = pcv.date
--	and pcd.location = pcv.location
--Where pcv.location like 'Thailand'
--Order by 1

-------------------------------------------------
-- Trying about rolling number for column and check it
--Select date, continent, location, SUM(cast(new_deaths as int)) OVER (Partition by location order by location, date) as RollingDeaths
--From Portfolio_Project..CovidDeaths
--Where continent is not null
--and location = 'Algeria'
----Group by continent
--order by 2,3

--Select date, total_deaths
--From Portfolio_Project..CovidDeaths
--Where continent is not null
--and location = 'Algeria'
--order by 1