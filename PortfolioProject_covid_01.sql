
-- covid_deaths
-- covid_vaccinations


-- Select Data that we are going to be using
Select	location
		,date
		,total_cases
		,new_cases
		,total_deaths
		,population
FROM	PorfolioProject..covid_deaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select	location
		,date
		,total_cases
		,total_deaths
		,(total_deaths/total_cases)*100 as deathpercentage
FROM	PorfolioProject..covid_deaths
Where	location like '%kingdom%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid
Select	location
		,date
		,population
		,total_cases
		,total_deaths
		,(total_cases/population)*100 as infected_rate
		,(total_deaths/population)*100 as death_rate
		,(total_deaths/total_cases)*100 as death_rate_per_infected
FROM	PorfolioProject..covid_deaths
Where	location like '%kingdom%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select	location
		,population
		,MAX(total_cases) as highest_infection_cnt
		,MAX((total_cases/population)*100) as highest_infection_rate
FROM	PorfolioProject..covid_deaths
Where	continent is not null
Group by location,population
Order by highest_infection_rate desc


-- Looking at Total Population vs Vaccinations

-- Use CTE
With PopvsVac (continent,location,date,population,new_vaccinations,Rolling_ppl_vaccinated)
as
(
Select	dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date)
		as Rolling_ppl_vaccinated
--		,(Rolling_ppl_vaccinated/population)*100
From	PorfolioProject..covid_deaths dea
Join	PorfolioProject..covid_vaccinations vac
on		dea.location = vac.location
and		dea.date = vac.date
where	dea.continent is not null
--order by 2,3
)
Select * 
		,(Rolling_ppl_vaccinated/population)*100 as Rolling_ppl_vaccinated_percentage
From PopvsVac
order by 2,3




--TEMP Table
DROP Table if exists ##PopvsVac
Create Table ##PopvsVac 
(continent nvarchar(255)
,location nvarchar(255)
,date datetime
,population numeric
,new_vaccinations numeric(12,0)
,Rolling_ppl_vaccinated numeric(12,0)
)
Insert into ##PopvsVac
Select	dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.location order by dea.location,dea.date)
		as Rolling_ppl_vaccinated
--		,(Rolling_ppl_vaccinated/population)*100
From	PorfolioProject..covid_deaths as dea
Join	PorfolioProject..covid_vaccinations as vac
on		dea.location = vac.location
and		dea.date = vac.date
where	dea.continent is not null
order by 2,3

Select * 
		,(Rolling_ppl_vaccinated/population)*100 as Rolling_ppl_vaccinated_percentage
From ##PopvsVac


-- Creating View to stroe data for later visualizations
Drop View if exists PopvsVac
go
Create View PopvsVac as 
Select	dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.location order by dea.location,dea.date)
		as Rolling_ppl_vaccinated
--		,(Rolling_ppl_vaccinated/population)*100
From	PorfolioProject..covid_deaths as dea
Join	PorfolioProject..covid_vaccinations as vac
on		dea.location = vac.location
and		dea.date = vac.date
where	dea.continent is not null
order by 2,3



	




 