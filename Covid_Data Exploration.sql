SELECT *
FROM
PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Covid_Vacinations_1
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- We are going to be looking at Total Cases Vs Total Deaths
--Shows the likelyhood of dying if contracted covid

SELECT location, date, total_cases, total_deaths,(CAST(total_deaths AS FLOAT) / total_cases) * 100
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths,(CAST(total_deaths AS FLOAT) / total_cases) * 100
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at the Total Cases Vs Population

SELECT location, date, population, total_cases, (total_cases/ CAST(population AS float))* 100 AS DeathPercentByPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/ CAST(population AS float)))* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY population,location
ORDER BY 4 DESC

--Showing Countries with the Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Let's break things down by Continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the Continents with Highest Death Counts

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) AS toal_cases, SUM(CAST(new_deaths as float)) AS total_deaths, SUM(CAST(new_deaths as float))/ SUM(new_cases)*100 AS DeathPercentage--, total_deaths, (cast(total_deaths as float)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..Covid_Vacinations_1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE


WITH PopvsVac (Continent, Location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..Covid_Vacinations_1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * --(RollingVaccinationCount/CAST(population AS float))*100
FROM PopvsVac


-- TEMP TABLE


CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..Covid_Vacinations_1 vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated