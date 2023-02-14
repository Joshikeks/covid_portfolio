use covid;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;

-- Looking at Total Cases vs Total Deaths
SELECT location,
	   date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS "deadly_rate"
FROM coviddeaths
WHERE location LIKE "%states%";

-- Looking at Total Cases vs Population
SELECT location,
	   date,
       total_cases,
       population,
       (total_cases/population)*100 AS "infection_rate"
FROM coviddeaths
WHERE location LIKE "%germany%";

-- Looking at countries with highest infection rates compared to population
SELECT location,
population,
       max(total_cases) AS "highest_infection_count",
       max((total_cases/population))*100 AS "infection_rate"
FROM coviddeaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Showing countries with highest death count per population
SELECT location,
	   population,
       max(total_deaths) AS "highest_death_count"
FROM coviddeathst
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_count DESC;

-- Breakdown by continent (ERROR)
SELECT continent,
       cast(total_deaths as int) AS "highest_death_count"
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Showing continents with the highest death count per population
SELECT 
	   continent,
	   population,
       max(total_deaths) AS "highest_death_count"
FROM coviddeathst
WHERE continent = "Europe"
GROUP BY continent, population
ORDER BY highest_death_count DESC;

-- Global deaths per day
SELECT
	date,
	SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths
FROM coviddeathst
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY global_new_deaths DESC;

-- Joining total population and total vaccination
SELECT
	d.date,
	SUM(population) AS global_population,
    SUM(total_vaccinations) AS global_vaccination
FROM coviddeathst d
JOIN covidvaccinationst v
	ON d.location = v.location AND d.date = v.date
WHERE total_vaccinations IS NOT NULL
GROUP BY d.date
ORDER BY d.date;

-- SUM OVER 
SELECT
	d.location,
	d.date,
    new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER by d.location, d.date) AS daily_new_vaccination_per_country
FROM coviddeathst d
JOIN covidvaccinationst v
	ON d.location = v.location AND d.date = v.date
WHERE total_vaccinations IS NOT NULL
AND d.location != "World"

-- CTE
WITH percent_vac_population (continent, location, date, population, running_sum_vac)
AS (
SELECT
	d.continent,
	d.location,
	d.date,
    new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY d.location) AS running_sum_vac
FROM coviddeathst d
JOIN covidvaccinationst v
	ON d.location = v.location AND d.date = v.date
WHERE total_vaccinations IS NOT NULL
AND d.location != "World")
SELECT *,
       (running_sum_vac/population)*100
FROM percent_vac_population
