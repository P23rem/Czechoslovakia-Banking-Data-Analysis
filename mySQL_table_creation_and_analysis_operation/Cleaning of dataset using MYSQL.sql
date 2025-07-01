use bank_stu_data;
select * from account;
----------- data cleaning in account table ---------------------
/* change the date 1993-2018
				   1994-2019
                   1995-2020
                   1996-2021
                   1997-2022
*/
update  account
set date_=
concat_ws('-',convert(concat('19',substr(date_,1,2)),UNSIGNED)+25,substr(date_,3,2),substr(date_,-2,2));
--- Since some of the date are wrongly inserted hence i am going to remove them and in some of the date column month>12 hence delete it

select * from account;
alter table account
add column day_ int,
add column month_ int,
add column year_ int; 


update account
set day_=cast(right(date_,2) as unsigned),
month_=cast(substr(date_,6,2) as unsigned),
year_=cast(left(date_,4) as unsigned);

-- Add one more column to check the leap year
alter table account
add is_leap_year varchar(30);

update account
set is_leap_year=CASE
    WHEN (year_ % 4 = 0 AND year_ % 100 != 0) OR (year_ % 400 = 0)
    THEN 'Yes'
    ELSE 'No' end;
-- make another column for maximum days in a month
alter table account
add column max_days int;

update account
set max_days=
case when month_=1 then 31
when month_=2 and is_leap_year='Yes' then 29
when month_=2 and is_leap_year='No' then 28
when month_=3 then 31
when month_=4 then 30
when month_=5 then 31
when month_=6 then 30
when month_=7 then 31
when month_=8 then 31
when month_=9 then 30
when month_=10 then 31
when month_=11 then 30
when month_=12 then 31
end;
select * from account;


--- Delete all the row who has incorrect data --------------------------------------
delete from account
where day_>max_days
or month_>12 or month_<=0;


alter table account
modify column date_ date;

--- You can drop these column you have created------------------------------------------
alter table account
drop column day_,
drop column month_,
drop column year_,
drop column is_leap_year,
drop column max_days;
select * from account;

/*
2.	Replace in frequency attribute “POPLATEK MESICNE” AS Monthly Issuance,
 “POPLATEKTYDNE” AS Weekly Issuance, and 
 “POPLATEK POBRATU” AS Issuance After a Transaction in Excel or create a case statement in SQL.*/
 select * from account;
 update account
 set frequency=
 case
 when
 lower(replace(frequency,' ',''))='poplatekmesicne' then 'Monthly'
 when lower(replace(frequency,' ',''))='poplatektydne' then 'Weekly'
 when lower(replace(frequency,' ',''))='poplatekpoobratu' then 'After transaction'
 else null end;
 

 
-------- Loan table-----------------------
 select * from loan;
 desc loan;
 update loan
 set date_=
concat_ws('-',cast(concat('19',substr(date_,1,2))as unsigned)+25,substr(date_,3,2),substr(date_,-2,2));
--- remove the double quote from status_ ---------------------
update loan
set status_=left(status_,1);
--------- Here is the same problem so we have to delete the row with invalid date data
--- create a column with date,month,year,leap_year and max_days


create table for_loan_valid_data(
day_ int,
month_ int,
year_ int,
leap_year varchar(10),
max_days int);

insert into for_loan_valid_data(day_,month_,year_)
select cast(right(date_,2) as unsigned),cast(substr(date_,6,2) as unsigned),cast(left(date_,4) as unsigned)
from loan;

update for_loan_valid_data
set leap_year=CASE
    WHEN (year_ % 4 = 0 AND year_ % 100 != 0) OR (year_ % 400 = 0)
    THEN 'Yes'
    ELSE 'No'
  END;
  
update for_loan_valid_data
set max_days=
case when month_=1 then 31
when month_=2 and leap_year='Yes' then 29
when month_=2 and leap_year='No' then 28
when month_=3 then 31
when month_=4 then 30
when month_=5 then 31
when month_=6 then 30
when month_=7 then 31
when month_=8 then 31
when month_=9 then 30
when month_=10 then 31
when month_=11 then 30
when month_=12 then 31
end;
select * from loan;

DELETE o
FROM loan AS o
INNER JOIN for_loan_valid_data AS f
  ON CAST(LEFT(o.date_, 4) AS UNSIGNED) = f.year_
 AND CAST(SUBSTRING(o.date_, 6, 2) AS UNSIGNED) = f.month_
 AND CAST(RIGHT(o.date_, 2) AS UNSIGNED) = f.day_
WHERE f.day_ > f.max_days or f.month_>12 or f.month_<=0;

-- convert the status A as Contract Finished,B as Loan not paid,C as Running Contract and D as Client in debt
select * from loan;
update loan
set status_=
case when status_='A' then 'Contract Finished'
when status_='B' then 'Loan not paid'
when status_='C' then 'Running Contract'
when status_='D' then 'Client in debt'
else null end;
select * from loan;
alter table loan
modify date_ date; 

----------- District table -----------
-- delete the attribute 12
alter table district
drop  column A12;

alter table district
rename column A1 to district_code,
rename column A2 to district_name,
rename column A3 to region,
rename column A4 to no_of_inhabitants,
rename column A5 to no_of_municipalities_with_less_than_499,
rename column A6 to no_of_municipalities_with_between_500_and_1999,
rename column A7 to no_of_municipalities_with_between_2000_and_9999,
rename column A8 to no_of_municipalities_greater_than_10000,
rename column A9 to no_of_cities,
rename column A10 to ratio_of_urban_inhabitants,
rename column A11 to avg_salary,
rename column A13 to unemployement_rate_2019,
rename column A14 to no_of_entrepreneurs_per_1000_inhabitants,
rename column A16 to no_of_commited_crimes_2019;

alter table district
drop column A15;
select * from district;

-------------- Client table ----------------
select * from client;
-- Add a column defining gender
alter table client
add column Gender varchar(10);

--- change the data type and format for client dob---------------
update client
set birth_number = concat_ws('-',
  1900 + cast(left(birth_number, 2) as unsigned) + 23 + floor((cast(substr(birth_number, 3, 2) as signed) - 1) / 12),
  lpad(cast(substr(birth_number, 3, 2) as signed) - floor((cast(substr(birth_number, 3, 2) as signed) - 1) / 12) * 12, 2, '0'),
  lpad(right(birth_number, 2), 2, '0')
);

select * from client;
--------------------------------------------------------------------
--- Here some of the data in birth_number is invalid so we have to remove it---------------

alter table client
add column day_ int,
add column month_ int,
add column year_ int; 
update client
set day_=cast(right(birth_number,2) as unsigned),
month_=cast(substr(birth_number,6,2) as unsigned),
year_=cast(left(birth_number,4) as unsigned);



-- Add one more column to check the leap year
alter table client
add is_leap_year varchar(30);

update client
set is_leap_year=CASE
    WHEN (year_ % 4 = 0 AND year_ % 100 != 0) OR (year_ % 400 = 0)
    THEN 'Yes'
    ELSE 'No' end;
-- make another column for maximum days in a month
alter table client
add column max_days int;

update client
set max_days=
case when month_=1 then 31
when month_=2 and is_leap_year='Yes' then 29
when month_=2 and is_leap_year='No' then 28
when month_=3 then 31
when month_=4 then 30
when month_=5 then 31
when month_=6 then 30
when month_=7 then 31
when month_=8 then 31
when month_=9 then 30
when month_=10 then 31
when month_=11 then 30
when month_=12 then 31
end;
select * from client;

delete from client
where day_>max_days
or month_>12 or month_<=0;
----------------------------------------------
alter table client
modify column birth_number date;


update client 
set Gender=case when 
convert(replace(birth_number,'-',''),unsigned)%2=0 then 'Female'
else 'male' end;

select * from client;

------- drop all unnecessary column ----------------
alter table client
drop column day_,
drop column month_,
drop column year_,drop column is_leap_year,
drop column max_days;
select * from client;

----------------- add column of age in client ------------------------
alter table client
add age int;
update client
set age=TIMESTAMPDIFF(YEAR, birth_number, CURDATE());


----------------------- Transaction table -------------------

--------------------------------- transaction table----------

select * from transaction;

---------------- Sort and then change from highest to lowest and give them order according to the year ---------
/*
 CONVERT 2021 TXN_YEAR TO 2022
 CONVERT 2020 TXN_YEAR TO 2021
 CONVERT 2019 TXN_YEAR TO 2020
 CONVERT 2018 TXN_YEAR TO 2019
 CONVERT 2017 TXN_YEAR TO 2018
 CONVERT 2016 TXN_YEAR TO 2017 */
 
update transaction
set date_=date_add(date_,interval 1 year);
update transaction
set bank=upper(bank);

select year(date_) as year,count(trans_id) as total_transaction
from transaction
group by 1
order by 2 desc;
update transaction
set bank=upper('Sky Bank') where (bank='' or bank is null) and year(date_)=2021;

update transaction
set bank=upper('DBS Bank') where (bank='' or bank is null) and year(date_)=2019;

update transaction
set bank=upper('Northen Bank') where (bank='' or bank is null) and year(date_)=2018;

update transaction
set bank=upper('Southern Bank') where (bank='' or bank is null) and year(date_)=2017;

select distinct bank from transaction;

----- There are many null values in prupose column convert it to household and where it is blank then put it as 'Loan Payement'-----
select count(*) from transaction 
where purpose is null ;
select count(*) from transaction where
trim(purpose)='';

update transaction
set purpose='Loan Payment'
where trim(purpose)='';

update transaction SET purpose = 'Household' where purpose is null;

update transaction
set purpose = 'Loan Payment'
where trim(purpose) = '';

update transaction
set account_pattern_id = 123
where account_pattern_id is null;

---------------- Clean the card table ----------------------------

select * from card;
update card
set issued=substr(issued,1,6);
update card 
set issued=concat_ws('-',
  1900 + cast(left(issued, 2) as unsigned) + 25 + floor((cast(substr(issued, 3, 2) as signed) - 1) / 12),
  lpad(cast(substr(issued, 3, 2) as signed) - floor((cast(substr(issued, 3, 2) as signed) - 1) / 12) * 12, 2, '0'),
  lpad(right(issued, 2), 2, '0')
);

alter table card
add column day_ int,
add column month_ int,
add column year_ int; 


select *,right(issued,2) ,substr(issued,6,2),left(issued,4) from card;
update card
set day_=cast(right(issued,2) as unsigned),
month_=cast(substr(issued,6,2) as unsigned),
year_=cast(left(issued,4) as unsigned);



-- Add one more column to check the leap year
alter table card
add is_leap_year varchar(30);

update card
set is_leap_year=CASE
    WHEN (year_ % 4 = 0 AND year_ % 100 != 0) OR (year_ % 400 = 0)
    THEN 'Yes'
    ELSE 'No' end;
-- make another column for maximum days in a month
alter table card
add column max_days int;

update card
set max_days=
case when month_=1 then 31
when month_=2 and is_leap_year='Yes' then 29
when month_=2 and is_leap_year='No' then 28
when month_=3 then 31
when month_=4 then 30
when month_=5 then 31
when month_=6 then 30
when month_=7 then 31
when month_=8 then 31
when month_=9 then 30
when month_=10 then 31
when month_=11 then 30
when month_=12 then 31
end;
select * from card
where issued='2021-02-29';

delete from card
where day_>max_days
or month_>12 or month_<=0;

alter table card
modify issued date;

alter table card
drop year_,
drop month_,
drop is_leap_year,
drop max_days,
drop day_;
select * from card;
------------------------ Change the issued date to last date of previous column -------------
update card set issued=
last_day(issued-interval 1 month);

/*
 -- 3.	Create a Custom Column Card_Assigned and assign below : 
 ●	Silver -> Monthly issuance
●	Diamond - weekly issuance
●	Gold - Issuance after a transaction
*/
alter table account
add column Card_Assigned varchar(30);
update account
set Card_Assigned=
case when frequency='Monthly' then 'Silver'
when frequency='Weekly' then 'Diamond'
when frequency='After transaction' then 'Gold'
else null end;

-- set account_id in account table as primary key----------
alter table account
add primary key (account_id);


-- set district_id as primary key in district table ----------
alter table district
add primary key (district_code);

---- set order_id as primary key in order_details table ------
alter table order_details
add primary key (order_id);

---- set client_id as primary key in client table -------------
alter table client
add primary key (client_id);

----- set disp_id as primary key in disp table-------------------
alter table disp
add primary key (disp_id);

------ set card_id as primary key in card table -----------------
alter table card
add primary key (card_id);












