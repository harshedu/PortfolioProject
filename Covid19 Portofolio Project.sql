SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--##Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total-cases vs total_deaths and the deathpercentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at total-cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 as CovidEffectedPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking for countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestCovidEffectedPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by HighestCovidEffectedPercentage desc

--Showing countries with highest death rate per population

SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as HighestCovidDeathPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by HighestCovidDeathPercentage desc

--Showing countries with highest number of death

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc



-- LET'S BREAK THINGS BY CONTINENT


-- showing continents with highesT death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

--date wise death percentage

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
GROUP by date
order by 1,2


--total death percentage all in one

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--GROUP by date
order by 1,2



-- Looking at Total population vs Vaccinations

Select DEA.continent, DEA.location , DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast (VAC.new_vaccinations as int)) OVER (Partition by DEA.location Order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null
order by 2,3


--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.continent, DEA.location , DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast (VAC.new_vaccinations as int)) OVER (Partition by DEA.location Order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null
--order by 2,3
) 
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

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
Select DEA.continent, DEA.location , DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast (VAC.new_vaccinations as int)) OVER (Partition by DEA.location Order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	On DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


