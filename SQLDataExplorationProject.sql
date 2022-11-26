select *
from CovidDeaths
order by 3, 4

--select data that we are going to be using

 select location, date, total_cases, new_cases, total_deaths, population
 from CovidDeaths
 order by 1,2

--looking at total cases vs total deaths

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
 from CovidDeaths
 where location like '%india%'
 order by 1,2

 --Look at total cases vs population

 select location, date, total_cases, population, (total_cases/population)*100 CovidAffectedPopulation
 from CovidDeaths
 where location like '%india%'
 order by 1,2 

 --Look at countries with highest infection rate w.r.t population

 select location, population, max((total_cases/population)*100) MaxInfectionRate
 from CovidDeaths
 group by location, population
 order by MaxInfectionRate desc

 --Look at countries with highest rate w.r.t population

 select location, population, max((total_deaths/population)*100) MaxDeathRate
 from CovidDeaths
 group by location, population
 order by MaxDeathRate desc

 --Look at countries with most deaths

 select location, max(cast(total_deaths as int)) as TotalDeaths
 from CovidDeaths
 where continent is not null
 group by location
 order by TotalDeaths desc

 --Continents with most deaths

 select continent, sum(cast((total_deaths) as int)) as TotalDeaths
 from CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeaths desc

 --Continental Death rate

 select continent, ((sum(cast(total_deaths as int))/sum(population))*100) MaxDeathRate
 from CovidDeaths
 where continent is not null
 group by continent
 order by MaxDeathRate desc

 --Global Numbers

 select date, ((sum(cast(new_deaths as int))/sum(new_cases))*100) MaxDeathRate
 from CovidDeaths
 where continent is not null
 group by date
 order by 1,2

 --Join new table

 select *
 from CovidDeaths dea
 join CovidVaccinations vac
     on dea.location = vac.location and dea.date = vac.date


--Rise in vaccinated population

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) CountOfVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
     on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null and dea.location = 'India'
 order by 2, 3

 --use CTE

 with popvsvac (continent, location, date, population, new_vaccinations, countofvaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) CountOfVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
     on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null
 )

 select *, (countofvaccinated/population)*100 RiseInVaccPercentage
 from popvsvac
 

--Temp Table

drop table if exists #PercentOfVaccPopulation
create table #PercentOfVaccPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CountOfVaccinated numeric
)

insert into #PercentOfVaccPopulation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) CountOfVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
     on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null

 select *, (countofvaccinated/population)*100 RiseInVaccPercentage
 from #PercentOfVaccPopulation



