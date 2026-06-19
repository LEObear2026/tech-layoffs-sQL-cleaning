
====================================================================
SQL Data Cleaning Project: Tech Layoffs Dataset		--https://www.kaggle.com/datasets/swaptr/layoffs-2022
Database Engine: POSTGRESQL
Purpose: Standardizing address fields, parsing delimited strings, 
         removing duplicate entries, and altering table schemas.
====================================================================



-- I created a duplicate table from the original raw data first
create table layoff_staging2 (		-- Creates a table similar to the defined table inside from the raw data
	like layoffs including all
);

insert into layoff_staging2		--Copies the records inside the table to another table
select *
from layoffs
;


-- 1. I started looking for duplicated records
select *
from layoff_staging2;

with duplicate_cte as(			-- CTE that checks any duplicate records
select *,
row_number() over(partition by company, layoff_staging2.location, total_laid_off, industry, country, stage, date_added, percentage_laid_off, layoff_staging2.source, funds_raised) as row_num
from layoff_staging2
)
select * 
from duplicate_cte where row_num > 1;

--Golden query to find inconsistencies in each letters in a column
	SELECT 
	LOWER(TRIM(company)) AS normalized_name, 
	COUNT(DISTINCT company) AS variation_count,
	STRING_AGG(DISTINCT company, ' vs ') AS variations_found
	FROM layoff_staging2
	GROUP BY LOWER(TRIM(company))
	HAVING COUNT(DISTINCT company) > 1;
	
	SELECT distinct LOWER(TRIM(company)) AS normalized_name
	from layoff_staging2
	order by 1
	;
	
	
	update layoff_staging2
	set company = LOWER(TRIM(company))		--Changes letters into lowercases
	;
	

		-- Then I looked for blank or null values next
select company, ls."location", ls.total_laid_off, ls.percentage_laid_off , ls.funds_raised , date -- Identifies blank records in all 3 columns
from layoff_staging2 ls 
where ls.total_laid_off = '' and ls.percentage_laid_off = '' and  ls.funds_raised = '';

select company, ls."location", ls.total_laid_off, ls.percentage_laid_off , ls.funds_raised , date --identifies blank records in any of 3 columns
from layoff_staging2 ls 
where ls.total_laid_off = '' or ls.percentage_laid_off = '' or ls.funds_raised = '';

delete from layoff_staging2 as ls
where ls.total_laid_off = '' and ls.percentage_laid_off = '' and  ls.funds_raised = ''	-- DELETES record with 3 columns with blank or null values
;

select *
from layoff_staging2;

select * from layoff_staging2	
where total_laid_off is null and percentage_laid_off is null
;

update layoff_staging2				--Update the blank values into NULL
set percentage_laid_off = null  	
where percentage_laid_off = ''
;

delete from layoff_staging2			-- Deletes records with both column null
where total_laid_off is null and percentage_laid_off is null
;

select company, total_laid_off, percentage_laid_off,  funds_raised
from layoff_staging2
where (total_laid_off is null or percentage_laid_off is null) and funds_raised = ''
order by 1
;

delete from layoff_staging2					--Deletes records with both columns null
where (total_laid_off is null or percentage_laid_off is null) and funds_raised = ''
;

update layoff_staging2				--Update the blank values into NULL
set funds_raised = null  	
where funds_raised = ''
;
	
	
	-- Next, I looked for inconsistencies 
	select total_laid_off		--Shows records with unnecessary digits
	from layoff_staging2
	where total_laid_off like '%.0';
	
	select trim(total_laid_off, '.0') as trimmed
	from layoff_staging2;
		
	update layoff_staging2 ls 
	set total_laid_off = trim(ls.total_laid_off, '.0')	-- Trims extra .0 character
	where total_laid_off like '%.0';					
	
	select *
	from layoff_staging2;
	
	with check_cte as (			-- CHECKS IF THERE ARE ANY MORE DUPLICATES LEFT IN THE RECORDS
	select *,
	row_number() over(partition by company, ls.location, total_laid_off, ls.date, percentage_laid_off, industry, country, date_added) as row_num
	from layoff_staging3 ls
	)
	select *
	from check_cte 
	where row_num > 1
	;
	
	
	select company, country, ls.location, ls.total_laid_off, percentage_laid_off, ls.funds_raised
	from layoff_staging2 ls 
	order by company asc
	;
	-- Checks more blank values from non integer columns
	select *
	from layoff_staging2
	where stage = '';
	
	select *
	from layoff_staging2
	where country = '';
	
	select *
	from layoff_staging2
	where industry = '';
	
	update layoff_staging2
	set industry = 'other'			--Sets industry to others from blank 
	where industry = 'appsmith'
	
	update layoff_staging2 
	set country = 'Canada'		--Set country to canada from montreal in location
	where country = '';		
	
	update layoff_staging2 
	set stage = null
	where stage = '';
	
	select distinct country
	from layoff_staging2
	order by country asc;
	
	update layoff_staging2 		-- Duplicated country
	set country = 'United Arab Emirates'
	where country = 'UAE';
	
	update layoff_staging2 ls 
	set total_laid_off = null		-- NULL values changed
	where ls.total_laid_off = -1
	;
	
	update layoff_staging2 ls 
	set percentage_laid_off = null	-- NULL values changed 
	where ls.percentage_laid_off = -1
	;
	
	update layoff_staging2 ls 
	set funds_raised = null			-- NULL values changed 
	where funds_raised = -1
	;
	
	update layoff_staging2 
	set company = initcap(company);		-- Capitalizes first letter in a column
	
	select *
	from layoff_staging2
	order by 1;
	
	-- Modifying column data types from initial text type values
	alter table layoff_staging2 		--Alters column type text to date data type
	alter column date type date
	using to_date(date, 'MM-DD-YYYY');
	
	alter table layoff_staging2 		--Alters column type text to date data type
	alter column date_added type date
	using to_date(date_added, 'MM-DD-YYYY');
	
	alter table layoff_staging2		--Alters column type text to int data type
	alter column total_laid_off type int
	using nullif(total_laid_off, '')::int;
	
	alter table layoff_staging2 		--Alter column type text to decimal data type
	alter column percentage_laid_off type decimal(6, 2)
	using nullif(percentage_laid_off, '')::decimal(6, 2);
	
	alter table layoff_staging2 
	alter column funds_raised type decimal(10, 2) 
	using nullif(funds_raised, '')::decimal(10, 2);
		
	alter table layoff_staging2		--Changes table name to layoffs_cleaned from layoff_staging2
	rename to layoffs_cleaned;
	
	
	
	
	
	
	
	
	
	
	
	
	
	

