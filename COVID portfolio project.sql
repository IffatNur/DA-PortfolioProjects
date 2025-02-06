select * 
from PortfolioProject1..CovidDeaths
order by 3, 4

select * 
from PortfolioProject1..CovidVaccinations
order by 3,4

select location,date, population, total_cases, new_cases,total_deaths
from PortfolioProject1..CovidDeaths;

--Total cases vs death cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject1..CovidDeaths
where location = 'Bangladesh'
order by 1,2


--Total covid infected percentage

select location, date, total_cases, population,(total_cases/population)*100 as infected_percentage
from PortfolioProject1..CovidDeaths
where location like 'Bangladesh'
order by 1 ,2, 3

--Looking at countries with infected rate compared to population

select location, MAX( total_cases ) as highest_infected, population,
max( (total_cases/ population))*100 as Highest_infected_percentage
from PortfolioProject1..CovidDeaths
group by location, population
order by Highest_infected_percentage desc

--Looking at countries with death count per population

select location, MAX(CAST( total_deaths as int))  as Highest_death, population, 
MAX(total_deaths/population)*100 as highest_death_percentage
from PortfolioProject1..CovidDeaths
where continent is not null
group by location, population
order by Highest_death desc

--Highest Death count by continent

select continent, MAX(cast(total_deaths as int)) as highest_death_count
from PortfolioProject1..CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc

--Global infected cases and death cases

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percentage
from PortfolioProject1..CovidDeaths
where continent is not null
group by date
order by 1,2

--looking at total popuplation vs vaccination

select d.continent, d.location, d.date,d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)
as rolling_people_vaccinated --rollover new_vaccination 
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

--using CTE

with PopulationvsVaccination (continent, location,date, population, new_vaccination,VaccinatedPeople)
as
(
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
SUM(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as VaccinatedPeople
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
)
select *, (VaccinatedPeople/population) *100
from PopulationvsVaccination

--temp table 
drop table if exists #PercentPopualationVaccined
create table #PercentPopualationVaccined
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric, 
population numeric,
VaccinatedPeople numeric
)
insert into #PercentPopualationVaccined
select d.continent, d.location, d.date, v.new_vaccinations,d.population,
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.date = v.date
and d.location = v.location
--where d.continent is not null
order by 2,3

select *, (VaccinatedPeople/population) * 100
from #PercentPopualationVaccined


--create view

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, v.new_vaccinations,d.population,
SUM(CONVERT(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.date = v.date
and d.location = v.location
where d.continent is not null

select *
from PercentPopulationVaccinated