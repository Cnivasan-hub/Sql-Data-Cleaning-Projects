-- Data Cleaning
use world_layoff;
show tables;
select * from layoffs order by 1;

-- 1. Remove Duplicates
-- 2. Standadise the data
-- 3. Remove null and blank values
-- 4. Removing unused columns

-- Firstly we should not use RAW file for data cleaning,so created duplicat table to workout.alter
Create table layoff_staging like layoffs; -- First create table like layoff table;
select * from layoff_staging;


insert into layoff_staging select * from layoffs;

-- Removing Duplicates
with duplacte_cte as
(select * ,
row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions) as rownumber from layoff_staging)
select * from duplacte_cte where rownumber=2;

create table layoff_staging2 (company text,location text,industry text,total_laid_off int,
percentage_laid_off int,date text,stage text,country text,funds_raised_millions int,rownumber int);
 
 select * from layoff_staging; 
 select * from layoff_staging2 ;
 
 
 insert into layoff_staging2
select * ,
row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions) as rownumber from layoff_staging;

set sql_safe_updates=0;
delete from layoff_staging2 where rownumber>1; -- now we have removed duplicates from  

-- 2. Standadising Data
update layoff_staging2 
set company=trim(company); -- removing spaces in company column

select industry from layoff_staging2 where industry like "crypt%";
update layoff_staging2
set industry="crypto" where industry like "crypto%"; -- making as common name

select country,trim(trailing "," from country) 
from layoff_staging2 where country like "united__%";
select * from layoff_staging2 where country like "united%";

update layoff_staging2
set country=trim(trailing "." from country) ; -- removing symbols in trailing country column

select date,str_to_date(date,"%m/%d/%YY") from layoff_staging2;-- Helps to convert the format
update layoff_staging2 
set date=str_to_date(date ,"%m/%d/%Y"); -- updated date format
select date from layoff_staging2; 

desc layoff_staging2; -- To Check the datatype of column,here need to change datatype for date column
alter table layoff_staging2
modify column date date;

-- 3. Removing null and Blank Values
-- For removing null values, firstly need to understand the data structure where the null values present
select * from layoff_staging2
where total_laid_off is null and percentage_laid_off is null;-- checking whether both column is common null values
select distinct industry from layoff_staging2;

select * from layoff_staging2
where industry is null or industry='';-- checking both null and black values availability

select * from layoff_staging2
where company="carvana";-- finding that particular company 

select * from layoff_staging2 t1
join layoff_staging2 t2
on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t1.industry is not null; -- findind the null values present using join

select t1.industry,t2.industry from layoff_staging2 t1
join layoff_staging2 t2
on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t1.industry is not null;

update layoff_staging2
set industry=null
where industry=''; -- firstly change blank into null values

update layoff_staging2 t1
join layoff_staging2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null 
and t1.industry is not null; -- later we can update here 

select * from layoff_staging2
where total_laid_off is null and 
percentage_laid_off is null; -- checking rows with null values

delete from layoff_staging2
where total_laid_off is null and 
percentage_laid_off is null; -- deleteing rows with null values

-- 4. Deleting unsued rows for optimizing data
select * from layoff_staging2;

alter table layoff_staging2
drop column rownumber; -- deleting unused column