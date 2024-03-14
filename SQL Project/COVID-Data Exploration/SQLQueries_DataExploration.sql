SELECT TOP (10) *
FROM CovidDeaths
ORDER BY 3,4

SELECT TOP (10) *
FROM CovidVaccinations
ORDER BY 3,4

Select * From CovidDeaths
Where continent is not null
order by 3,4

-- Selecting data that we are going to be use
Select location, date, total_cases, new_cases, total_deaths,population
From CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
Select location,date,total_cases,total_deaths
From CovidDeaths
Where continent is not null
Order By 1,2

--Total deaths per cases
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From CovidDeaths
Where continent is not null
Order By 1,2

--Total deaths per cases from India
-- Shows likelihood of dying if you have covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From CovidDeaths
Where location = 'India'
Order By 1,2

--- Total Cases vs Population 
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidDeaths
--Where location = 'India'
Where continent is not null
Order By 1,2

--Countries with Highest Infection Rate compared to Population
Select location, population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
--Where location = 'India'
Where continent is not null
Group by location, population
Order by 4 DESC

--Countries with Highest Death Count
Select location, population,Max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
--Where location = 'India'
Where continent is not null
Group By location, population
Order by 3 Desc

-- Break things with continent
--Continent with Highest Death Count
Select location, population,Max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
--Where location = 'India'
Where continent is null
Group By location, population
Order by 3 Desc


-- Global Data 
--Death Percentage daywise

Select date, Sum(new_cases) as TotalCasesOnADay,Sum(cast(new_deaths as int)) as TotalDeathsOnADay,Sum(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
Group By date
Order by 1,2

-- World Death Percent
Select Sum(new_cases) as TotalCasesOnADay,Sum(cast(new_deaths as int)) as TotalDeathsOnADay,Sum(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
Order by 1,2

-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location --Partition by dea.location means count will start over after every new location
Order by dea.location, dea.Date) as RollingPeopleVaccinatedCount --Order by dea.location,dea.date will make it a Consecutive sum for all dates for a particular country
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


---Using CTE

With PopvsVac(Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location --Partition by dea.location means count will start over after every new location
Order by dea.location, dea.Date) as RollingPeopleVaccinatedCount --Order by dea.location,dea.date will make it a Consecutive sum for all dates for a particular country
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

--Select * from PopvsVac

Select *, (RollingPeopleVaccinatedCount/Population) * 100
From PopvsVac

-- Using TEMP

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinatedCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location --Partition by dea.location means count will start over after every new location
Order by dea.location, dea.Date) as RollingPeopleVaccinatedCount --Order by dea.location,dea.date will make it a Consecutive sum for all dates for a particular country
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinatedCount/Population) * 100
From #PercentPopulationVaccinated

--Creating Views and storing it for later purposes
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location --Partition by dea.location means count will start over after every new location
Order by dea.location, dea.Date) as RollingPeopleVaccinatedCount --Order by dea.location,dea.date will make it a Consecutive sum for all dates for a particular country
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null


Select * From PercentPopulationVaccinated