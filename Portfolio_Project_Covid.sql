/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select*
from Portfolio_Project..Covid_Death
Where continent is not null
order by 3,4

Select*
from Portfolio_Project..Covid_Vaccination
order by 3,4

-- Select Data that we are going to be starting with.

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Death
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country.

Select Location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as Death_Percentege
From Portfolio_Project..Covid_Death
Where continent is not null 
	and location like '%czech%'
order by 1,2

--Looking at Total Cases vs Population.
--Shows what percentege of population that was infected by Covid

Select Location, date, population,total_cases, (total_cases/population)*100 as Population_Infected_Percentage
From Portfolio_Project..Covid_Death
Where continent is not null 
	and location like '%czech%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population , Max(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Population_Infected_Percentage
From Portfolio_Project..Covid_Death
--where Location like '%czech%'
Where continent is not null 
Group by Location, Population
order by Population_Infected_Percentage desc


-- Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..Covid_Death
Where continent is not null 
Group by Location
order by Total_Death_Count desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..Covid_Death
Where continent is not null 
--	Where location like '%czech%'
Group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as Death_Percentage
From Portfolio_Project..Covid_Death
--Where location like '%czech%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Portfolio_Project..Covid_Death dea
Join Portfolio_Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Death dea
Join Portfolio_Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vaccinated_Percentage
From Pop_vs_Vac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Death dea
Join Portfolio_Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_People_Vaccinated_Percentage
From #Percent_Population_Vaccinated

-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Death dea
Join Portfolio_Project..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From Percent_Population_Vaccinated


