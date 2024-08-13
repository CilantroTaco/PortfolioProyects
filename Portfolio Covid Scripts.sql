SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- VIENDO TOTAL CASES VS TOTAL DEATHS 

-- MUESTRA LA PROBABILIDAD DE MORIR DEPENDIENDO DE TU PAIS Y EL TIEMPO
SELECT Location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--MUESTRA EL PORCENTAJE DE PERSONAS QUE CONTRAJERON COVID
SELECT Location, date, total_cases, population,  (1.0*total_cases/population)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--VIENDO PAISES CON UN PORCENTAJE DE INFECCION ALTO COMPARADO CON LA POBLACION
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((1.0*total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--MOSTRANDO CONTINENTES CON EL % MAS ALTO DE MUERTES POR POBLACION
Select Continent, MAX(Total_Deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like %states%
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--NUMEROS GLOBALES
SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(1.0*new_deaths)/SUM(1.0*New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--Group by date
order by 1,2

--POBLACION VS VACUNAS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USANDO CTE PARA REALIZAR UN CALCULO CON PARTITION BY A PARTIR DEL ANTERIOR QUERY
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (1.0*RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations Numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated
--,(1.0*RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
JOin PortfolioProject..CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREANDO UNA VISTA 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated
--,(1.0*RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
JOin PortfolioProject..CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

SELECT *
From PercentPopulationVaccinated