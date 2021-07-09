use [SQL Covid Data Exploration];
--Find count of values in covid deaths table.
select count(*) from CovidDeathsInfo;


--Find count of values in covid vaccination table;
select count(*) from CovidVaccinationsInfo;

select * from CovidDeathsInfo;
select * from CovidDeathsInfo order by 3,4;

--Select data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population from
CovidDeathsInfo
order by 1,2;

--Finding Total cases vs Total Deaths
--Change data type of columns to integer so that sum operation can be performed
Alter table CovidDeathsInfo
alter column total_cases float;

Alter table CovidDeathsInfo
alter column total_deaths float;

--Delete rows were total cases are 0 to avoid division by 0.
Delete from CovidDeathsInfo where total_cases = 0;

--Execute the query to show death percentage
Select location, date, total_cases,  total_deaths, round(CAST(((total_deaths / total_cases) * 100)as float), 2) as Death_Percentage
from
CovidDeathsInfo
where continent is not null;

--To check the result in united states
Select location, date, total_cases,  total_deaths, round(CAST(((total_deaths / total_cases) * 100)as float), 2) as Death_Percentage
from
CovidDeathsInfo
where location like '%Pakistan%'
order by 1,2;

--Check the covid 19 percentage with respect to population (What percentage of population is affected by COvid-19)
Select location, date, total_cases, population, round(CAST(((total_cases / population)*100)as float), 4)as Affected_Rate
from
CovidDeathsInfo
where location like '%Pakistan%' and continent is not null;

--Which country has infection rates higher than 15%
Alter table CovidDeathsInfo
alter column population bigint;

Delete from CovidDeathsInfo where population = 0;

Select location, round(CAST(((total_cases / population)*100)as float), 4)as Affected_Rate
from CovidDeathsInfo
where
round(CAST(((total_cases / population)*100)as float), 4) > 15.0 and continent is not null;

--Countries most affected with affected rate percentage
Select location, population, max(total_cases) as Total_Cases_Overall, round((max(total_cases) / population) * 100, 2) as Percentage_
from CovidDeathsInfo
where continent is not null
group by location, population
order by Percentage_ desc;

--Countries with highest death rate
Select location, population, max(total_deaths) as Total_Deaths_Overall, round((max(total_deaths) / population) * 100, 4) as Percentage_
from CovidDeathsInfo
where continent is not null
group by location, population
order by Percentage_ desc;

--Total Death country wise
Select location, max(total_deaths) as Total_Deaths
from CovidDeathsInfo
where continent is not null
group by location
order by Total_Deaths desc;



--Break up things by continent
select distinct(continent) from CovidDeathsInfo;
--Remove Empty field in continent
delete CovidDeathsInfo where continent is null;
select distinct(continent) from CovidDeathsInfo;

--Show
Select continent, max(total_deaths) as Total_Deaths
from CovidDeathsInfo
where continent is not null
group by continent
order by Total_Deaths desc;


--GLOBAL NUMBERS
Alter table CovidDeathsInfo
alter column new_cases float;
Alter table CovidDeathsInfo
alter column new_deaths float;

delete from CovidDeathsInfo where new_cases = 0 and new_deaths = 0;

select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, round(sum(new_deaths) / sum(new_cases) * 100, 2) as Death_Percentage
from CovidDeathsInfo
where continent is not null
group by date
order by 4;

--Total cases in world vs total deaths in world 
select sum(new_cases) as Total_Cases_In_World, sum(new_deaths) as Total_Death_In_World
from CovidDeathsInfo;



---------------------------------------------------VACCINATION DATA EXPLORATION--------------------------

select * from CovidVaccinationsInfo;

alter table CovidVaccinationsInfo
alter column new_tests float;
--Total tests continent wise
select continent, sum(new_tests) as Total_Tests from
CovidVaccinationsInfo
group by continent
order by Total_Tests desc;

--Total Test Date and Continet Wise
select continent, date, sum(new_tests) as Total_Tests from
CovidVaccinationsInfo
group by continent, date
order by Total_Tests desc;

--Countrywise total tests
select location, sum(new_tests) as Total_Tests from
CovidVaccinationsInfo
group by location
order by Total_Tests desc;


--Join both the tables based on location and date

alter table CovidVaccinationsInfo
alter column new_vaccinations float;

--Total vaccinations location wise
select dea.location, dea.population, sum(vac.new_vaccinations) as Vaccinations
from CovidDeathsInfo dea
join CovidVaccinationsInfo vac
On dea.location = vac.location and dea.date = vac.date
group by dea.location, dea.population;

--Cummulative sum of vaccinations over time for LAOS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Vaccinations
from CovidDeathsInfo dea
join CovidVaccinationsInfo vac
On dea.location = vac.location and dea.date = vac.date
where dea.location like 'Laos'
order by 2,3;


--USE OF CTE to use Calculated columns for further calculations
with Population_vs_Vaccination(location, continent, date, population, new_vaccinations, Vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Vaccinations
from CovidDeathsInfo dea
join CovidVaccinationsInfo vac
	On dea.location = vac.location and dea.date = vac.date
where dea.location like 'Pakistan')

select *, round((Vaccinations/population)*100, 2) as Percentage_Vaccinated
from Population_vs_Vaccination;



--TEMP TABLE

create table #PercentageVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Vaccinations numeric
)
Insert into #PercentageVaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Vaccinations
from CovidDeathsInfo dea
join CovidVaccinationsInfo vac
	On dea.location = vac.location and dea.date = vac.date

select *, round((Vaccinations / population) *100, 2)
from #PercentageVaccinations;


--CREATE VIEW TO STORE DATA FOR LATER USE
create view PercentageVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as Vaccinations
from CovidDeathsInfo dea
join CovidVaccinationsInfo vac
	On dea.location = vac.location and dea.date = vac.date

select * from PercentageVaccinated