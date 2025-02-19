select count(*)
from layoffs_staging2;

-- create a copy of table(columns)
create table layoffs_staging
like layoffs;

-- insert the values of the table
insert layoffs_staging
select *
from layoffs;

select count(*)
from layoffs_staging;

-- Steps to follow:

 -- 1. Remove duplicates
 
 -- Checking duplicate rows with window function
 select *,
 row_number() over(
 partition by company, location, total_laid_off, `date`,country
 ) as row_num
 from layoffs_staging;
 
 with duplicate_cte as(
  select *,
 row_number() over(
 partition by company, location, industry, total_laid_off,percentage_laid_off, `date`,country,
 stage,country,funds_raised_millions
 ) as row_num
 from layoffs_staging
 )
 select *
 from duplicate_cte
 where row_num > 1;

-- Create, Insert table layoff_staging2
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over (
partition by company, location, industry, total_laid_off,percentage_laid_off, `date`,country,
 stage,funds_raised_millions
 ) as row_num
from layoffs_staging;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    row_num > 1;

DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;
 
 -- 2. Standardize the data
 
 select * 
 from layoffs_staging2;
 
 select distinct company
 from layoffs_staging2;
 
 update layoffs_staging2
 set company = trim(company);
 
 select distinct industry
 from layoffs_staging2
 ORDER BY 1;
 
 select *
 from layoffs_staging2
 where industry like 'Crypto%';
 
 update layoffs_staging2
 set industry = 'Crypto'
 where industry like 'Crypto%';
 
 select distinct country
 from layoffs_staging2
 order by 1;
 
 update layoffs_staging2
 set country = trim(trailing '.' from country)
 where country like 'United States%';
 
 select `date`
 from layoffs_staging2;
 
 update layoffs_staging2
 set `date` = str_to_date(`date`,'%m/%d/%Y');
 
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;
 
 
 -- 3. Populating/Remove null values
 SELECT *
 from layoffs_staging2
 where total_laid_off IS NULL;
 
 SELECT *
 FROM layoffs_staging2
 WHERE industry = ''
 OR industry IS NULL;
 
 SELECT *
 FROM layoffs_staging2
 WHERE industry is null;
 
SELECT t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null 
and t2.industry is not null ;

update layoffs_staging2
set industry = NULL
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;
 
 -- 4. Remove any column
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;
        
DELETE 
from layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;







