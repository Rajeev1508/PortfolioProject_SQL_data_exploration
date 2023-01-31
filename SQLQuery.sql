select * 
from PortfolioProject..[Raw_CovidDeaths(20-21)]
where continent is Not NULL
order by 3,4

--select * 
--from PortfolioProject..[Raw_CovidVacciation(20-21)]
--order by 3,4

---Select Data that we are going to be using 
Select location, date, total_cases, new_cases,total_deaths, population 
from PortfolioProject..[Raw_CovidDeaths(20-21)]
order by 1,2

---looking at total cases VS total deaths
---it shows percentage of deaths in total cases
Select location, date, total_cases, total_deaths,CAST((total_deaths/total_cases)*100 as int) as DeathPercentage
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
order by 1,2

---Total Cases VS Population
---Show percentage of population have covid
Select location, date, population,total_cases,CAST((total_cases/population)*100 as int) as CovidPercentage
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
order by 1,2

---Looking at countries with highest rate of infection rate compared to population
Select location, population,MAX(total_cases)as Highestinfectioncount,CAST(MAX(total_cases/population)*100 as int) as CovidInfectedPercentage
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
group by location , population
order by 4 desc
 
 ---Showing Coutries with highest death count per population 
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
where continent is Not NULL
group by location
order by 2 desc

---Lets Break things down by Continent
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
where continent is NULL
group by location
order by 2 desc


---Showing the contintents with the highest death count per population
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
where continent is NOT NULL
group by continent
order by 2 desc

---Global Numbers
Select /*date,*/sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as total_deaths, (Sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
from PortfolioProject..[Raw_CovidDeaths(20-21)]
--where location like '%state%'
where continent is NOT NULL
--group by date
order by 1 


-------------------------------------------------------------------------------------------------------------------------------------
-------Vaccination Table Use--
Select *
from [PortfolioProject]..[Raw_CovidVacciation(20-21)] as dea
join [PortfolioProject]..[Raw_CovidVacciation(20-21)] as vac
	on dea.location = vac.location
	and dea.date = vac.date

---looking for total Popuation Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--- , (RollingPeopleVaccinated/dea.population)*100 for solving this error we use CTE
from [PortfolioProject]..[Raw_CovidDeaths(20-21)] as dea
join [PortfolioProject]..[Raw_CovidVacciation(20-21)] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
order by 2,3


-----------USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--- , (RollingPeopleVaccinated/dea.population)*100 for solving this error we use CTE
from [PortfolioProject]..[Raw_CovidDeaths(20-21)] as dea
join [PortfolioProject]..[Raw_CovidVacciation(20-21)] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
)
select * , (RollingPeopleVaccinated/Population)*100 as vaccinationPercentage
from PopvsVac


--------TEMP TaBLE
----Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
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
 , SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--- , (RollingPeopleVaccinated/dea.population)*100 for solving this error we use CTE
from [PortfolioProject]..[Raw_CovidDeaths(20-21)] as dea
join [PortfolioProject]..[Raw_CovidVacciation(20-21)] as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is NOT NULL
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100 as vaccinationPercentage
from #PercentPopulationVaccinated


----CREATING VIEW to store data for Later Visulizations
use PortfolioProject
go
CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--- , (RollingPeopleVaccinated/dea.population)*100 for solving this error we use CTE
from [PortfolioProject]..[Raw_CovidDeaths(20-21)] as dea
join [PortfolioProject]..[Raw_CovidVacciation(20-21)] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
--order by 2,3

select * 
from PercentPopulationVaccinated



























































