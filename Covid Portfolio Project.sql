USE portfolio_project;
SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM covid_vaccinations
-- ORDER BY 3,4

-- Select Data that we are going to be using
SELECT 
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases Vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases) * 100 AS 'death percentage'	
FROM covid_deaths
where location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID
SELECT 
	location,
    date,
    total_cases,
    population,
    (total_cases/population) * 100 AS 'percent_population_infected'	
FROM covid_deaths
-- where location like '%states%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT 
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases/population)) * 100 AS 'percent_population_infected'	
FROM covid_deaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing Countries with Highest Death Count per Pppulation
SELECT 
	location,
    MAX(total_deaths) as total_death_count
FROM covid_deaths
-- where location like '%states%'
WHERE 
	continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Let's break things down by continent

-- Showing continents with the highest death count per population
SELECT 
	continent,
    MAX(total_deaths) as total_death_count
FROM covid_deaths
-- where location like '%states%'
WHERE continent is NOT null
GROUP BY continent
ORDER BY total_death_count DESC;


-- Global Numbers
SELECT 
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    SUM(new_deaths)/SUM(new_cases) * 100 AS 'death percentage'	
FROM covid_deaths
-- where location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by location ORDER BY dea.location,
    dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is NOT null
order by 2,3;

-- USE CTE
WITH PopsvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by location ORDER BY dea.location,
    dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is NOT null
-- order by 2,3
)
SELECT *, (rolling_people_vaccinated/population) * 100 AS percent_vaccinated
FROM PopsvsVac;


-- Creating a View for Tableu
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by location ORDER BY dea.location,
    dea.date) AS rolling_people_vaccinated
-- , (rolling_people_vaccinated/population) * 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent is NOT null;
-- order by 2,3; 
-- SELECT *, (rolling_people_vaccinated/population) * 100 AS percent_vaccinated FROM PercentPopulationVaccinated

SELECT * 
FROM percentpopulationvaccinated;