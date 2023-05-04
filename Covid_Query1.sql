SELECT *
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL

SELECT *
FROM [dbo].[CovidVaccinations$]

SELECT [location], [date], [total_cases], [new_cases], [total_deaths], [population]
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL
ORDER BY 1, 2

--Total Cases vs Total Deaths
--Percentage rate of dying if one gets covid in the country

SELECT [location], [date], [total_cases], [total_deaths], ([total_deaths]/[total_cases])*100 AS Death_percentage
FROM [dbo].[CovidDeaths$]
 WHERE [continent] IS  NOT NULL
 ORDER BY 1, 2

SELECT [location], [date], [total_cases], [total_deaths], ([total_deaths]/[total_cases])*100 AS Death_percentage
FROM [dbo].[CovidDeaths$]
WHERE [location] = 'Nigeria'
 ORDER BY 1, 2

 --Total Cases vs Population
 --Shows the percentage of people that got covid

 SELECT [location], [date], [population], [total_cases], ([total_cases]/[population])*100 AS Infected_percentage
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL
ORDER BY 1, 2

SELECT [location], [date], [population], [total_cases], ([total_cases]/[population])*100 AS Infected_percentage
FROM [dbo].[CovidDeaths$]
WHERE [location] = 'Nigeria' AND [continent] IS  NOT NULL
ORDER BY 1, 2

--Country with highest infection rate compare to population
SELECT [location], [population], Max([total_cases]) AS HighestInfectionCount, Max(([total_cases]/[population])*100) AS HighestPopulationInfected_percentage
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL
GROUP BY [location], [population]
ORDER BY 4 DESC

--Country with highest Death rate. Death count per Population...Used CAST to change the data type of the "Total Death" column from "nvarchar" to "Integer"
SELECT [location], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
GROUP BY [location]
ORDER BY HighestDeathCount DESC

--Fixing the issue with continent showing in the location column in the above query by inserting a WHERE clause where the column "continent" is  not NULL
SELECT [location], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL
GROUP BY [location]
ORDER BY HighestDeathCount DESC

--Breaking things down by continent
SELECT [continent], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS  NOT NULL
GROUP BY [continent]
ORDER BY HighestDeathCount DESC

--To get the correct highest death count by continent 
SELECT [location], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS NULL
GROUP BY [location]
ORDER BY HighestDeathCount DESC

/*looking at the highest death count by both continent and location, So that for a continent we can see all the countries under it 
and also order by the highest death count so we know the country with the highest death after ordering by the continent*/

SELECT [continent], [location], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS NOT NULL
GROUP BY [continent], [location]
ORDER BY HighestDeathCount DESC, [continent]

SELECT [continent], [location], Max(CAST([total_deaths] AS Integer)) AS HighestDeathCount
FROM [dbo].[CovidDeaths$]
WHERE [continent] IS NOT NULL
GROUP BY [continent], [location]
ORDER BY [continent] DESC, HighestDeathCount DESC

--percentage of death cases globally per day
SELECT [date], SUM([new_cases]) AS Total_cases, SUM(CAST([new_deaths] AS Integer)) AS Total_deaths, (SUM(CAST([new_deaths] AS Integer))/SUM([new_cases]))*100 AS Death_percentage_globally
FROM [dbo].[CovidDeaths$]
 WHERE [continent] IS  NOT NULL
GROUP BY [date]
ORDER BY [date]

--Total cases and death with percentage globally
SELECT SUM([new_cases]) AS Total_cases, SUM(CAST([new_deaths] AS Integer)) AS Total_deaths, (SUM(CAST([new_deaths] AS Integer))/SUM([new_cases]))*100 AS Death_percentage_globally
FROM [dbo].[CovidDeaths$]
 WHERE [continent] IS  NOT NULL

 --Covid vaccination table

 SELECT *
FROM [dbo].[CovidVaccinations$]

--Joining both tables 
SELECT *
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date

--Total Population vs Vaccination
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
ORDER BY 1, 2, 3

--Using window functions
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS AddingUpOfPeopleVaccinated_PerDay
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL
ORDER BY 1, 2, 3

--To get the average of vaccinated people per location and date so far (the avg is being calc by the amt of vaccinated pple so far since the vacc started, and that is why the avg keeps reducing because it is doing the calc as the dat goes on)
SELECT Death.continent, Death.location, Death.population, Vacc.new_vaccinations,
AVG(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS Avg_VaccinatedPeople_perlocation_tilldate
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

--To get the average of vaccinated people per location.
SELECT Death.continent, Death.location, Death.population, Vacc.new_vaccinations,
AVG(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location) AS Avg_VaccinatedPeople_perlocation
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL



--USING CTE to determine the percentage of the sum of vaccination by location and date
WITH Pop_Vac (continent, location, date, population, new_vaccinations, AddingUpOfPeopleVaccinated_PerDay)
AS
( SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS AddingUpOfPeopleVaccinated_PerDay
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL )

SELECT *, (AddingUpOfPeopleVaccinated_PerDay/population)*100 AS Percentage_vaccinatedPeople
FROM Pop_Vac

--TEMP TABLE
Drop Table if exists #PercentageOfpopulation_Vaccinated
CREATE TABLE #PercentageOfpopulation_Vaccinated
( continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  AddingUpOfPeopleVaccinated_PerDay numeric )

  INSERT INTO #PercentageOfpopulation_Vaccinated
  SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS AddingUpOfPeopleVaccinated_PerDay
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM #PercentageOfpopulation_Vaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentageOfPopulation_Vaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS AddingUpOfPeopleVaccinated_PerDay
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM PercentageOfPopulation_Vaccinated

CREATE VIEW Death_Percentage_Globally AS 
SELECT [date], SUM([new_cases]) AS Total_cases, SUM(CAST([new_deaths] AS Integer)) AS Total_deaths, (SUM(CAST([new_deaths] AS Integer))/SUM([new_cases]))*100 AS Death_percentage_globally
FROM [dbo].[CovidDeaths$]
 WHERE [continent] IS  NOT NULL
GROUP BY [date]

SELECT *
FROM Death_Percentage_Globally

CREATE VIEW General_Death_percentage_Globally AS
SELECT SUM([new_cases]) AS Total_cases, SUM(CAST([new_deaths] AS Integer)) AS Total_deaths, (SUM(CAST([new_deaths] AS Integer))/SUM([new_cases]))*100 AS Death_percentage_globally
FROM [dbo].[CovidDeaths$]
 WHERE [continent] IS  NOT NULL

 SELECT *
 FROM General_Death_percentage_Globally

CREATE VIEW Average_Vaccinated_People_perLocation AS
SELECT Death.continent, Death.location, Death.population, Vacc.new_vaccinations,
AVG(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location) AS Avg_VaccinatedPeople_perlocation
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM Average_Vaccinated_People_perLocation

CREATE VIEW Average_Vaccinated_People_perLocation_tillDate AS
SELECT Death.continent, Death.location, Death.population, Vacc.new_vaccinations,
AVG(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS Avg_VaccinatedPeople_perlocation_tilldate
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL

SELECT *
FROM Average_Vaccinated_People_perLocation_tillDate


CREATE VIEW CTE_PercentageOfPopVaccinated AS
WITH Pop_Vac (continent, location, date, population, new_vaccinations, AddingUpOfPeopleVaccinated_PerDay)
AS
( SELECT Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations,
SUM(CAST(Vacc.new_vaccinations AS Integer)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) AS AddingUpOfPeopleVaccinated_PerDay
FROM [dbo].[CovidDeaths$] AS Death
JOIN [dbo].[CovidVaccinations$] AS Vacc
     ON Death.location = Vacc.location
	 AND Death.date = Vacc.date
WHERE Death.continent IS NOT NULL )

SELECT *, (AddingUpOfPeopleVaccinated_PerDay/population)*100 AS Percentage_vaccinatedPeople
FROM Pop_Vac

SELECT *
FROM CTE_PercentageOfPopVaccinated
 










