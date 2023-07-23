Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select location, Date, Total_Cases, New_cases, Total_deaths, Population
FROM PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Show likelihood of dying if you contract covid in your country
Select location, Date, Total_Cases, Total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%Afghan%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows that percentage of population got covid in Afghanistan

Select location, Date, population, Total_Cases,(total_cases/population)*100 as Percentofpopulatoninflected
FROM PortfolioProject.dbo.CovidDeaths
where location like '%Afghan%'
Order by 1,2

-- looking at countries with hieghest infection rate compared to population

Select location,  population, Max(Total_Cases) as HieghestInfectioncount,max((total_cases/population))*100 as Percentofpopulatoninflected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Afghan%'
Group by population, location 
Order by Percentofpopulatoninflected desc

-- Showing countries with highest death count per populatoin

Select location, Max(Total_Deaths) as TotalDeathscount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Afghan%'
where continent is not null
Group by location
Order by TotalDeathscount desc

-- let's break things down by continent

Select continent, Max(Total_Deaths) as TotalDeathscount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Afghan%'
where continent is not null
Group by continent
Order by TotalDeathscount desc


-- Global Numbers


Select date, SUM(New_Cases), SUM(Cast(New_Deaths as int)), SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases), 0)*100 as DeathsPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Date
Order By 4 desc


Select SUM(New_Cases), SUM(Cast(New_Deaths as int)), SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases), 0)*100 as DeathsPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
--Group by Date
--Order By 4 desc


-- looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by dea.location

Alter Table PortfolioProject..CovidVaccinations
Alter Column New_Vaccinations int


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by dea.location

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date
ROWS UNBOUNDED PRECEDING)
From PortfolioProject.dbo.CovidDeaths as cd
join PortfolioProject.dbo.CovidVaccinations cv
	on cd.location = cv.location and
	   cd.date = cv.date
Where cd.continent is not null
--and cd.location like '%States%'
order by 2,3


-- use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as cd
join PortfolioProject.dbo.CovidVaccinations cv
	on cd.location = cv.location and
	   cd.date = cv.date
Where cd.continent is not null
--and cd.location like '%States%'
)
Select *, (RollingPeopleVaccinated/population)*100 as Percentageofpopulaionvaccinated
From PopvsVac
Order by 2,3

-- USE Temp

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as cd
join PortfolioProject.dbo.CovidVaccinations cv
	on cd.location = cv.location and
	   cd.date = cv.date
Where cd.continent is not null
--and cd.location like '%States%'

Select *, (RollingPeopleVaccinated/population)*100 as Percentageofpopulaionvaccinated
From #PercentPopulationVaccinated
Order by 2,3

-- Creating Data to store data for later


Create view PercentPopulationVaccinated
as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date
ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths as cd
join PortfolioProject.dbo.CovidVaccinations cv
	on cd.location = cv.location and
	   cd.date = cv.date
Where cd.continent is not null
--and cd.location like '%States%'
--order by 2,3

Select *
From PercentPopulationVaccinated



