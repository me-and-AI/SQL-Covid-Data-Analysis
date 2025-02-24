SELECT *
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3,4



--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From [Portfolio Project]..CovidDeaths
Where location like '%India%'
and continent is not null
Order by 1,2



-- Looking at Total Cases vs Population	
-- Shows what percentage of population got covid 

Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
Where Location like '%India%'
and continent is not null
Order by 1,2



--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HoghestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By location, population
Order by 4 desc



--Countries with highest Death count per population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount Desc



--Death count by continent

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount Desc



--Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 AS Deathpercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2



--Looking at total population vs total vacinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (Partition By dea.location order by dea.location, dea.date) as cumulative_vaccinations--, (cumulative_vaccinations/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, cumulative_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (cumulative_vaccinations/Population)*100
From PopvsVac



Drop Table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

Insert into #Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (cumulative_vaccinations/Population)*100
From #Percentpopulationvaccinated



-- Creating View to store data for later visualizations

USE [Portfolio Project];
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as cumulative_vaccinations
--, (cumulative_vaccinations/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
