-- Part 1: Exploratory data analysis

-- Countries ordered by number of cases
SELECT
  location,
  MAX(CAST(total_cases AS INT64)) as total_cases
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Countries ordered by number of deaths
SELECT
  location,
  MAX(CAST(total_deaths AS INT64)) as total_deaths
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Countries ordered by percent of population that died due to COVID
SELECT
  location,
  (MAX(total_deaths)/MAX(population)) * 100 AS percent_of_population_deaths
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Checking diabetes prevalence among countries with highest percent of population that died from COVID
SELECT
  location,
  (MAX(total_deaths)/MAX(population)) * 100 AS percent_of_population_deaths,
  MAX(diabetes_prevalence) as diabetes_prevalence
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Doesn't appear to have much of a connection, let's check percent of population at least partially vaccinated
SELECT
  location,
  (MAX(total_deaths)/MAX(population)) * 100 AS percent_of_population_deaths,
  (MAX(people_vaccinated)/MAX(population)) * 100 AS percent_of_population_vaccinated
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Countries ordered by percent of population that are fully vaccinated
SELECT
  location,
  (MAX(people_fully_vaccinated)/MAX(population)) * 100 AS percent_of_population_vaccinated
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC;

-- Some countries, such as Gibraltar, seem to have over 100% of their population fully vaccinated
-- Let's see if the error is in the data or our query
SELECT 
  location, 
  people_fully_vaccinated, 
  population
FROM 
  Covid_Vaccinations.country_vaccinations
WHERE 
  location = 'Gibraltar'
ORDER BY 
  people_fully_vaccinated DESC
LIMIT 10;

-- Error seems to be in the data, as population numbers are sometimes less than or equal to the number of people fully vaccinated
-- Let's remove these cases for now, but overall, these results likely can't be relied on
SELECT
  location,
  (MAX(people_fully_vaccinated)/MAX(population)) * 100 AS percent_of_population_vaccinated
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
HAVING
  percent_of_population_vaccinated < 100
ORDER BY
  2 DESC;

-- Checking GDP of countries with highest percent of population fully vaccinated
SELECT
  location,
  (MAX(people_fully_vaccinated)/MAX(population)) * 100 AS percent_of_population_fully_vaccinated,
  MAX(gdp_per_capita) AS gdp_per_capita
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  location
HAVING
  percent_of_population_fully_vaccinated < 100
ORDER BY
  2 DESC;

-- Total number of cases and deaths by continent
SELECT
  continent,
  SUM(CAST(new_cases AS INT64)) AS total_cases,
  SUM(CAST(new_deaths AS INT64)) AS total_deaths
FROM
  Covid_Vaccinations.country_vaccinations 
WHERE
  continent IS NOT NULL
GROUP BY
  continent;

-- Finally, total number of cases and deaths globally
SELECT
  SUM(CAST(new_cases AS INT64)) AS total_cases_globally,
  SUM(CAST(new_deaths AS INT64)) AS total_deaths_globally
FROM
  Covid_Vaccinations.country_vaccinations; 


-- Part 2: Queries for Tableau Dashboard, comparing COVID vaccinations and deaths by country

-- Don't need every feature for each record
-- Want people vaccinated, deaths, and a few other potential points of comparison
SELECT 
  iso_code,
  location,
  continent,
  date,
  total_deaths,
  people_vaccinated,
  people_fully_vaccinated,
  gdp_per_capita,
  extreme_poverty,
  diabetes_prevalence,
  human_development_index,
  population
FROM
  Covid_Vaccinations.country_vaccinations;

-- Add on another column for percent of population fully vaccinated
SELECT 
  iso_code,
  location,
  continent,
  date,
  total_deaths,
  people_vaccinated,
  people_fully_vaccinated,
  gdp_per_capita,
  extreme_poverty,
  diabetes_prevalence,
  human_development_index,
  population,
  (people_fully_vaccinated/population) AS percent_fully_vaccinated
FROM
  Covid_Vaccinations.country_vaccinations;

-- Create a View from our results
CREATE VIEW IF NOT EXISTS Covid_Vaccinations.country_vaccinations_view AS 
(SELECT 
    iso_code,
    location,
    continent,
    date,
    total_deaths,
    people_vaccinated,
    people_fully_vaccinated,
    gdp_per_capita,
    extreme_poverty,
    diabetes_prevalence,
    human_development_index,
    population,
    (people_fully_vaccinated/population) AS percent_fully_vaccinated
  FROM
    Covid_Vaccinations.country_vaccinations)