-- TESTING Relevant data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- COVID-19 Case Fatality Rate in Portugal

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%portugal%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- COVID-19 Prevalence Rate in Portugal

SELECT location, date, total_cases, population, (total_cases/population)*100 AS prevalence_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- COVID-19 Prevalence Rates 

SELECT location, population, MAX(total_cases) AS max_total_cases, (MAX(total_cases/population))*100 AS prevalence_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY prevalence_rate DESC

-- COVID-19 Mortality Rates per Country

SELECT location, population, MAX(cast(total_deaths AS int)) AS max_total_deaths, MAX(total_deaths/population)*100 AS max_mortality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_mortality_rate DESC

-- COVID-19 Mortality Rates per Continent

SELECT location, MAX(cast(total_deaths AS int)) AS max_total_deaths, MAX(total_deaths/population)*100 AS max_mortality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY max_mortality_rate DESC

-- Global COVID-19 Case Fatality Rate evolution

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER by date

-- Vaccination per Country per Date with Cummulative count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_total --, (vaccination_total/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- CTE: Vaccination per Country per Date with Cummulative count and Percentage

WITH popVSvac (Continent, Location, Date, Population, NewVaccinations, VaccinationsTotal)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_total
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (VaccinationsTotal/Population)*100 AS PercVaccination
FROM popVSvac

-- TEMP TABLE: Vaccination per Country per Date with Cummulative count and Percentage

DROP TABLE IF EXISTS #PercentVaccination
CREATE TABLE #PercentVaccination
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
NewVaccinations numeric, 
VaccinationsTotal numeric
)

INSERT INTO #PercentVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_total
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *, (VaccinationsTotal/Population)*100 AS PercVaccination
FROM #PercentVaccination

-- Creating View for later visualizations

CREATE VIEW PercentVaccination AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccination_total
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

CREATE VIEW ContinentMortalityRates AS
SELECT location, MAX(cast(total_deaths AS int)) AS max_total_deaths, MAX(total_deaths/population)*100 AS max_mortality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
--ORDER BY max_mortality_rate DESC

CREATE VIEW PrevalenceRates AS
SELECT location, population, MAX(total_cases) AS max_total_cases, (MAX(total_cases/population))*100 AS prevalence_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
-- ORDER BY prevalence_rate DESC

CREATE VIEW FatalityRates AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- ORDER BY 1,2
