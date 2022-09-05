SELECT * 
FROM portfolioproject..coviddeath
order by 3,4

/*SELECT * 
FROM portfolioproject..covidvaccination
order by 3,4 */

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject..coviddeath
ORDER BY 1,2

--looKING AT TOTAL CASES VS TOTAL DEATHS
--WHAT % OF POPULATION

SELECT Location,date,total_cases,total_deaths,population,(total_deaths/population)*100 AS DeathPercentage
FROM portfolioproject..coviddeath 
WHERE location like '%India%'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to Population
SELECT Location,Population,MAX(total_cases) AS HighestInfectionCount,population,MAX((total_cases/population))*100 AS 
PercentPoulationAffected
FROM portfolioproject..coviddeath 
--WHERE location like '%India%'
GROUP BY Location,Population
ORDER BY PercentPoulationAffected desc


--Showing Countries with Highest Death Count per population
SELECT Location,MAX(total_deaths) AS TotalDeathCount
FROM portfolioproject..coviddeath 
WHERE continent IS NOT NULL
--WHERE location like '%India%'
GROUP BY Location
ORDER BY TotalDeathCount desc


--GROUP BY CONTINENT

--Showing continents with the highest death count per population


SELECT continent,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM portfolioproject..coviddeath 
WHERE continent IS  NOT NULL
--WHERE location like '%India%'
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Numbers

SELECT /*date*/SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100
 AS DeathPercentage
FROM portfolioproject..coviddeath 
--WHERE location like '%India%'
WHERE CONTINENT IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking At total Population Vs Total Vaccination(NEW VACCINATIONS PER DAY)

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,dea.Date)
FROM portfolioproject..coviddeath AS dea
JOIN portfolioproject..covidvaccination AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER by 2,3

--USE CTC



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..coviddeath dea
Join portfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeath dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeath dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 