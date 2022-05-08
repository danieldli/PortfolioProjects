/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to be starting with

SELECT	location, date, total_cases, new_cases, total_deaths, population
FROM	CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if contract Covid

SELECT	location, date, total_cases, total_deaths, 
		(total_deaths/total_cases)*100 AS death_percentage
FROM	CovidDeaths
WHERE	location LIKE '%States%'
AND 	continent IS NOT NULL
ORDER BY 1, 2;


-- Total cases vs Population
-- Shows what percentage of population got Covid

SELECT	location, date, total_cases, population, 
		(total_cases/population)*100 AS infection_rate
FROM	CovidDeaths
WHERE	location LIKE '%States%'
AND 	continent IS NOT NULL
ORDER BY 1, 2;


-- Countries with the highest infection rate compared to Population

SELECT	location, MAX(total_cases) AS highest_infection_count , population, 
		(MAX(total_cases)/population)*100 AS infection_rate
FROM	CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC;


-- Countries with the highest death count per population

SELECT	location, MAX(total_deaths) AS total_death_count
FROM	CovidDeaths
WHERE continent IS not null
GROUP BY location
ORDER BY total_death_count DESC;


-- BREAKING THINGS DOWN BY CONTINENT
-- DEATH COUNT BY CONTINENT

SELECT	location, MAX(total_deaths) AS total_death_count
FROM	CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY total_death_count DESC;


-- GLOBAL NUMBERS

SELECT	date, SUM(new_cases) AS total_cases, 
		SUM(new_deaths) AS total_deaths, 
		SUM(new_deaths)/SUM(new_cases)*100 AS death_rate
FROM	CovidDeaths
WHERE	continent IS NOT null
GROUP BY date
ORDER BY 1;


-- Total population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

-- Use CTE to perform Calculation on Partition By

WITH VacvsPop (Continent, Location, Date, Population, New_vaccinations, RollingVaccinated)
AS(
    SELECT  dea.continent, dea.location, dea.date, population, 
            vac.new_vaccinations,
            SUM(vac.new_vaccinations) 
                OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
                AS  RollingVaccinated
    FROM    CovidDeaths dea JOIN CovidVaccinations vac
            ON  dea.location = vac.location 
            AND dea.date = vac.date
    WHERE   dea.continent IS NOT NULL
  )
SELECT *, (RollingVaccinated/Population)*100 AS VaccinationRate
FROM VacvsPop;



-- Using Temp Table to perform Calculation on Partition By

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent           nvarchar(255),
    Location            nvarchar(255),
    Date                datetime,
    Population          numeric,
    New_vaccinations    numeric,
    RollingVaccinated   numeric
)
INSERT INTO #PercentPopulationVaccinated
    SELECT  dea.continent, dea.location, dea.date, population, 
                vac.new_vaccinations,
                SUM(vac.new_vaccinations) 
                    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
                    AS  RollingVaccinated
        FROM    CovidDeaths dea JOIN CovidVaccinations vac
                ON  dea.location = vac.location 
                AND dea.date = vac.date
        WHERE   dea.continent IS NOT NULL
SELECT      *, (RollingVaccinated/Population)*100 AS VaccinationRate
FROM        #PercentPopulationVaccinated
ORDER BY    2,3;
 

 -- Creating a view to stroe data for later visualizations

 CREATE VIEW PercentPopulationVaccinated AS
 SELECT  dea.continent, dea.location, dea.date, population, 
         vac.new_vaccinations,
         SUM(vac.new_vaccinations) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.DATE)
            AS  RollingVaccinated
FROM    CovidDeaths dea JOIN CovidVaccinations vac ON  dea.location = vac.location 
                AND dea.date = vac.date
WHERE   dea.continent IS NOT NULL

