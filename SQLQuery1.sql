select 
* from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

-- Death Ratio

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_ration
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2
;

--  Total Deaths in a particular country

select location,MONTH(date) as month_1, total_cases,total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%India%'
order by 1,2;

-- People Infected

select location,date, population,total_cases,(total_cases/population) as Infection_rate
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- countires with highest infection count

select location, population,MAX(total_cases) as highest_infection,MAX((total_cases/population))*100 as percent_popu_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by percent_popu_infected desc;

--	Highest Death count

select location,MAX(cast(total_deaths as int)) as total_Death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by total_Death_count desc;

-- Lets break it down by continent

select continent,MAX(cast(total_deaths as int)) as total_Death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by total_Death_count desc;

-- Cosindering that may entires have world written in them

select location,MAX(cast(total_deaths as int)) as total_Death_count
from PortfolioProject.dbo.CovidDeaths
where continent is  null
group by location
order by total_Death_count desc;

-- Global Based on the number of cases and deaths that are occuring daily

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 		 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

--Working on the second table.

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- total poputaion vs vaccination

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated,

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- creating a CTE(common table Expression)

With PopvsVac (Continent, Location,Date,Population,new_vaccinations,rolling_people_vaccinated)
as
(
	select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select * , (rolling_people_vaccinated/Population)*100
from PopvsVac;


-- Create a Temp table

drop table if exists #PercentpopulationVaccinated

create table #PercentpopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentpopulationVaccinated

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

select * , (rolling_people_vaccinated/Population)*100
from #PercentpopulationVaccinated;

-- Creating a view 

create view PercentpopulationVaccinated as 
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location , dea.date) as rolling_people_vaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
	where dea.continent is not null
	--order by 2,3


select * 
from PercentpopulationVaccinated;