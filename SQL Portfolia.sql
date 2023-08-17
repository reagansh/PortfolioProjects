select * 
from dbo.Death$
order by 3,4

---select data

select location, date, total_cases, new_cases, total_deaths, population
from Death$
order by 1,2


----- looking at Total Cases and Total Deaths
------Shows Likelihood of dying if you contarct Covid in your country
select location, date, total_cases, total_deaths, (Convert (Decimal(15, 3), total_deaths)/Convert (Decimal(15, 3),total_cases)*100) DeathPercentage
from Death$
where location like '%Zim%'
order by 1,2

------Looking at Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 PopulationPercentage
from Death$
where location like '%Zim%' and continent is not null
order by 1,2

------Looking at Country with the Highest Infaction Rate 

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 PercentagePopulation
from Death$
Group by Location, Population
order by PercentagePopulation desc


-------Showing Countries with Highest Death Count per Population
select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, (MAX(total_deaths)/population)*100 as PopulationPercentageDeaths
from Death$
where continent is not null
Group by Location, Population
order by TotalDeathCount desc

---- Breakining it down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Death$
where continent is not null
Group by continent
order by TotalDeathCount desc

-----Global Numbers

select  date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/ Nullif(Sum(new_cases),0)*100) DeathPercentage
from Death$
where continent is not null
group by date
order by 1,2

select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, (Sum(cast(new_deaths as int))/ Nullif(Sum(new_cases),0)*100) DeathPercentage
from Death$
where continent is not null
order by 1,2


select Death$.continent,Death$.location, Death$.date, cast (Vac$.new_vaccinations as int) as NewVaccinations
from Death$
join Vac$
On Death$.location= Vac$.location
and Death$.date= Vac$.date
where Death$.continent is not null and Death$.location like '%zim%'
order by 2,3


select Death$.continent,Death$.location, Death$.date, cast (Vac$.new_vaccinations as int) as NewVaccinations,
SUM(cast(vac$.new_vaccinations as bigint)) Over (partition by death$.location order by death$.location,
death$.date) as CumulativeTotal
from Death$
join Vac$
On Death$.location= Vac$.location
and Death$.date= Vac$.date
where Death$.continent is not null 
order by 2,3

----TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeTotal numeric
)

insert into #PercentPopulationVaccinated
select Death$.continent, Death$.location, Death$.date, Death$.population, Vac$.new_vaccinations,
SUM(cast(vac$.new_vaccinations as bigint)) Over (partition by death$.location order by death$.location,
death$.date) as CumulativeTotal
from Death$
join Vac$
On Death$.location= Vac$.location
and Death$.date= Vac$.date
where Death$.continent is not null 

select * , nullif(CumulativeTotal,0)/Nullif(Population,0)*100
From #PercentPopulationVaccinated


select population from Death$ where location='Albania'
select * from Vac$ where location='Albania'


---USING CET

with ProvsVac (continent,location,date,population,new_vaccinations,CumulativeTotal)
as
(
select Death$.continent, Death$.location, Death$.date, Death$.population, Vac$.new_vaccinations,
SUM(cast(vac$.new_vaccinations as bigint)) Over (partition by death$.location order by death$.location,
death$.date) as CumulativeTotal
from Death$
join Vac$
On Death$.location= Vac$.location
and Death$.date= Vac$.date
where Death$.continent is not null 
)
select * , (CumulativeTotal/Population)*100 as Percentage
From ProvsVac


-----Creating View 

create view PercPopVaccinated as

select Death$.continent, Death$.location, Death$.date, Death$.population, Vac$.new_vaccinations,
SUM(cast(vac$.new_vaccinations as bigint)) Over (partition by death$.location order by death$.location,
death$.date) as CumulativeTotal
from Death$
join Vac$
On Death$.location= Vac$.location
and Death$.date= Vac$.date
where Death$.continent is not null 
