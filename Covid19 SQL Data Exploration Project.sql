/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from [Portfolio Project]..covidDeaths
where continent is not null
order by 3, 4

--select *
--from [Portfolio Project]..covidvaccination
--order by 3, 4

--select data to be used

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..covidDeaths
order by 1, 2


--Total cases vs total deaths
--Likelihood of dying from covid in Ghana

select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases*1.0)*100 as deathpercentage
from [Portfolio Project]..covidDeaths
where location like '%ghana%'
order by 1, 2

--Total cases vs population
--Shows the percentage of population who got covid in Ghana
select location, date, total_cases, population, (total_cases*1.0/population*1.0)*100 as CasePercentage
from [Portfolio Project]..covidDeaths
where location like 'Ghana'
order by 1, 2

--Countries with highest infection rate compared to population
select location, population, Max(total_cases) as Highest_infectionCount, max((total_cases*1.0/population*1.0))*100 as CasePercentage
from [Portfolio Project]..covidDeaths
--where location like 'Ghana'
group by population, location
order by CasePercentage desc



--Let's break things down by continent

--Countries with highest death count per population
select location, max(total_deaths) as totaldeathcount
from [Portfolio Project]..covidDeaths
--where location like 'Ghana'
where continent is null
group by location
order by totaldeathcount desc


--lET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

select continent, max(total_deaths) as totaldeathcount
from [Portfolio Project]..covidDeaths
--where location like 'Ghana'
where continent is not null
group by continent
order by totaldeathcount desc




--GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_deaths*1.0)/sum(new_cases*1.0)*100  as DeathPercentage
from [Portfolio Project]..covidDeaths
--where location like 'Ghana'
where continent is not null
--group by date
order by 1, 2



select *
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date



--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Ghana'
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotal_VaccinatedPeople
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Ghana'
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopsvsVac (Continent, location, date, population, new_vaccinations, RunningTotal_VaccinatedPeople)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotal_VaccinatedPeople
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Ghana'
--order by 2,3
)
select *, (RunningTotal_VaccinatedPeople/Population)*100
from popsvsvac


--Using Temp Table to perform Calculation on Partition By in previous quer

Drop table if exists #Percentpopulationvaccinated
Create table #PercentPopulationVaccincated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RunningTotal_VaccinatedPeople numeric
)


Insert into #PercentPopulationVaccincated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotal_VaccinatedPeople
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Ghana'
--order by 2,3




--Creating view to store data for later visualizations


Create view percentpopulaionvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotal_VaccinatedPeople
from [Portfolio Project]..covidDeaths dea
join [Portfolio Project]..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Ghana'
--order by 2,3


Select *
from percentpopulaionvaccinated
