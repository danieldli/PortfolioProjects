SELECT 	* 
FROM	CovidDeaths
ORDER BY 3, 4;

SELECT	*
FROM	CovidVaccinations
ORDER BY 3, 4;

SELECT	location, date, total_cases, new_cases, total_deaths, population
FROM	CovidDeaths
ORDER BY 1, 2;

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if contract Covid

SELECT	location, date, total_cases, total_deaths, 
		(total_deaths/total_cases)*100 AS death_percentage
FROM	CovidDeaths
WHERE	location LIKE '%States%'
ORDER BY 1, 2;


-- Total cases vs Population
-- Shows what percentage of population got Covid

SELECT	location, date, total_cases, population, 
		(total_cases/population)*100 AS infection_rate
FROM	CovidDeaths
WHERE	location LIKE '%States%'
ORDER BY 1, 2;


-- Countries with the highest infection rate

SELECT	location, MAX(total_cases) AS highest_infection_count , population, 
		(MAX(total_cases)/population)*100 AS infection_rate
FROM	CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC;


-- Countries with the highest death count

SELECT	location, MAX(total_deaths) AS total_death_count
FROM	CovidDeaths
WHERE continent IS not null
GROUP BY location
ORDER BY total_death_count DESC;


-- DEATH COUNT BY CONTINENT

SELECT	location, MAX(total_deaths) AS total_death_count
FROM	CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY total_death_count DESC;


-- GLOBAL NUMBER

SELECT	date, SUM(new_cases) AS total_cases, 
		SUM(new_deaths) AS total_deaths, 
		SUM(new_deaths)/SUM(new_cases)*100 AS death_rate
FROM	CovidDeaths
WHERE	continent IS NOT null
GROUP BY date
ORDER BY 1;


-- Total population vs Vaccination
-- Use CTE

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



-- Use Temp Table
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

-- View is permanent
SELECT * FROM PercentPopulationVaccinated;
