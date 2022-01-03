/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
From [dbo].[CovidDeaths]
where location like '%states%' and continent is not null 
order by DeathPercentage desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases,population, (cast(total_cases as decimal))/(cast(population as decimal))*100 as PercentagePopulatIoninfected
From [dbo].[CovidDeaths]
where location like '%states%' and continent is not null 
order by DeathPercentage desc


-- Countries with Highest Infection Rate compared to Population

Select Location, max(total_cases) as Highestinfectioncount,population, MAX((cast(total_cases as decimal))/(cast(population as decimal)))*100 as PercentagePopulatIoninfected
From [dbo].[CovidDeaths]
-- where location like '%states%' and continent is not null 
group by location, population
order by PercentagePopulatIoninfected DESC

-- Countries with Highest Death Count per Population

Select Location, max(cast(total_deaths as decimal)) as TotalDeathCount
From [dbo].[CovidDeaths]
-- where location like '%states%' and continent is not null 
where continent is not null
group by location, population
order by TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as decimal)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(New_Cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac
where New_Vaccinations is not null
order by 2,3


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations]  vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeaths]  dea
Join [dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

