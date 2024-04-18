--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by location, date

-- total cases, total deaths
-- Likelihood of death when contracting covid - probabilite de mort

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like 'Fr%'
order by location, date

-- Total cases, population
-- percentage of population that got covid , pourcentage de population qui a attrapé le covid

Select location,date, total_cases, population, ( total_cases/population)*100 as PercentPopulation
From PortfolioProject..CovidDeaths
--Where location like 'Fr%'
order by location, date

--Highest infection rate vs population, taux de rattrapé la plus élevé 


--SELECT location, 
--       date, 
--       total_cases, 
--       population, 
--       MAX((total_cases/population)*100) as HighestInfection
--FROM PortfolioProject..CovidDeaths
--GROUP BY location, date, total_cases, population
--ORDER BY HighestInfection desc, location

-- This querry is used to check the highest infection rate in selected country or the whole table ( need to remove Where location like )
--Ce querry est utilisé pour demonstrer la plus eleve taux d'infection et la maximal cas de covid pour 1 ou plusier pays. (A modifier Where location like)
SELECT location, 
       MAX(total_cases) as max_total_cases, 
       population, 
       MAX((total_cases/population)*100) as HighestInfection
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
Having MAX(total_cases) is not null and MAX((total_cases/population)*100) is not null
ORDER BY location asc, HighestInfection DESC

-- Pays avec la plus des morts + taux de mortalite

SELECT location, 
       MAX(cast(total_deaths as int)) as DeathCount, 
       population, 
       MAX((total_deaths/population)*100) as HighestDeathsRate
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location, population
Having MAX(cast(total_deaths as int)) is not null and MAX((total_deaths/population)*100) is not null
ORDER BY  DeathCount desc, HighestDeathsRate DESC

-- Trier par continent
Select	location,
		Max(cast(total_deaths as int)) as TotalDeathcount,
		continent
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, continent
Having Max(cast(total_deaths as int)) is not null
order by TotalDeathcount desc


-- Global number by date

select	
		Sum(cast(new_deaths as int)) as totaldeath,
		Sum(cast(new_cases as int)) as totalcases,
		Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Having Sum(cast(new_deaths as int)) is not null and Sum(cast(new_cases as int)) is not null
--order by date


-- Total population avec vaccination


Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SumVacDayByDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 1,2,3

-- Avec Common table expression

With Popsurvac (Continent, date, location, population, new_vaccinations, SumVacDayByDay)
	as
	(Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SumVacDayByDay
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	)


Select *, (SumVacDayByDay/Population)*100 as PercentageVaccination
From Popsurvac 

--Temporal Table pour ameliorer la vitesse d'acces database


Drop Table if exists #PopsurvacPercentage -- suprimer si cette table existe pour eviter l'erreur 
Create table #PopsurvacPercentage --declaration nom des columns 
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
SumVacDaybyday numeric)
Insert into #PopsurvacPercentage -- add value into previous temp table with same order of columns

Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SumVacDayByDay
From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *						-- View result of temp table
From #PopsurvacPercentage

-- Creer view pour visualiser
Create view PourcentPOPVAC as 
Select	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SumVacDayByDay
From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *			-- verification view
From PourcentPOPVAC -- rolling count 