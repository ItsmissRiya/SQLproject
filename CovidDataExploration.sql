Select * 
from SQL_Prjct1..CovidDeaths
order by 3,4;

Select * 
from SQL_Prjct1..CovidVaccinations;

SELECT Location,date,total_cases,new_cases,total_deaths,population
From SQL_Prjct1..CovidDeaths
order by 1,2;

SELECT Location,date,total_cases,population,(total_cases/population)*100 as death_percentage
From SQL_Prjct1..CovidDeaths
Where Location = 'India'
order by 1,2;

SELECT Location,Max(total_cases) as Highest_Infection,population,MAX((total_cases/population))*100 as death_percentage
From SQL_Prjct1..CovidDeaths
Group by Location,Population
order by 1,2 Desc;

--DEATH COUNT HIGHEST per pop
SELECT Location,Max(cast(total_deaths as int)) as death_count,MAX((total_deaths/population))*100 as death_percentage
From SQL_Prjct1..CovidDeaths
where continent is not null
Group by Location
order by death_count Desc;


--Lets break it by continent

Select continent , MAX(cast(total_deaths as int )) as TotalDeathCount
from SQL_Prjct1..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC;

--showing continents with highesht death count per population
select continent,MAX(cast(total_deaths as int)) as tot_death_count
FROM SQL_Prjct1..CovidDeaths
where continent is not null
group by continent
order by tot_death_count desc;

--global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQL_Prjct1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
from SQL_Prjct1..CovidDeaths as dea
JOIN SQL_Prjct1..CovidVaccinations as vac
on dea.location=vac.location and 
dea.date = vac.date
where dea.continent is not null
order by 2,3;

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Prjct1..CovidDeaths dea
Join SQL_Prjct1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Prjct1..CovidDeaths dea
Join SQL_Prjct1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Prjct1..CovidDeaths dea
Join SQL_Prjct1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
