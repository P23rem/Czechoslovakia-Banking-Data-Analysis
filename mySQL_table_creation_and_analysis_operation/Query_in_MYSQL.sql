use bank_stu_data;

------- Count all rows in all tables ---------------------------------------------
select count(*) as total_rows from account;
select count(*) as total_rows  from card;
select count(*) as total_rows  from client;
select count(*) as total_rows  from disp;
select count(*) as total_rows  from district;
select count(*) as total_rows  from loan;
select count(*) as total_rows  from order_details;
select count(*) as total_rows  from transaction;

----- analyze and Fetch some samples of the data -----------------------
select * from account limit 10;
select * from card limit 10;
select * from client limit 10;
select * from disp limit 10;
select * from district limit 10;
select * from loan limit 10;
select * from order_details limit 10;
select * from transaction limit 10;

---- add age column in  client table --------------------------
alter table client
add age int;

update client
set age=year(now())-year(birth_number);

------------- Check minimum and maximum date of a transaction -------------------------
select min(date_) as oldest_txn , max(date_) as latest_txn
from transaction;------------ oldest transaction date is 2019-01-01 and latest transaction date is 2022-12-31

-- checking null values in column PURPOSE, BANK AND ACCOUNT_PARTERN_ID
select count(*) from transaction
where purpose is null;
select count(*) from transaction where
bank is null;
select count(*) from transaction
where account_pattern_id is null;

------- Transaction overview ----------------------------
select * from Transaction;
 
--- Distinct bank   (There are 15 Banks whose transaction data is given)
select distinct bank from transaction;

--------- Which bank through which most of the transactions have been made----------------------
select bank,count(1) as total_transaction_made from transaction
group by 1 order by 2 desc;
--- Southern bank through which highest number of transaction have taken place and Northen bank and DBS Bank are in 2nd and 3rd position respectively

----------- Total Interest Credited Per account--------------------------------------
SELECT account_id, SUM(amount) AS total_interest
FROM transaction
WHERE operation = 'Interest Credit'
GROUP BY account_id
ORDER BY total_interest DESC;     

------------- Number of transaction by operation ----------------------------------------------
select operation,count(account_id) as total_number_of_txn
from transaction group by 1
order by 2 desc;               -------- Maximum number of transaction occured in withdrawal in cash operation and followed by Remmittance to Another Bank

------------- Highest Balance after Interest Credit ------------------------------------
select account_id,balance
from transaction
where operation ='Interest Credit'
order  by 2 desc;  ---- The range is very close as the top balance is 148366.1 and followed by acccount_id with 145342.6 and 144251.6

----------- Average Interest credited per transaction ------------------
select avg(amount) as average_interest_per_txn from transaction
where operation='Interest Credit';   ----- 143.3 is avg interest credited

--------------- Average Transaction made per account -----------------------------
select round(count(*)/((select count(distinct account_id) from transaction)),0) as avg_transaction_per_account from transaction;---- 124 transaction per account

---------------- Customer Demographic Overview KPIs ---------------------------------
select * from client;

------------------ Average Age of Client -------------------------------------------
select round(avg(age)) as average_age from client; ----- 47 is the average age of the client
--------------- Total Client ---------------------------------------------------
select count(distinct  client_id) as account_holder from client; ------ 5346 are the total account holder
--------------------- Total District -----------------------------
select count(distinct district_code) as total_district from district ; ---- 77 district

------------------------ Loan KPIs ------------------------------------
select * from loan order by loan_id;
---------------------- Total Loan Amount till date --------------------------
select sum(amount)/power(10,6) as total_loan from loan; --------------- 103 million 

---- Average days to take loan -----------------------------
select avg(datediff(a.date_,b.date_))
from loan as a
inner join 
account as b
on a.account_id=b.account_id;

-------------------- total Loan Borrower -------------------------
select count(distinct loan_id) as total_borrower from loan; ----- 681
----------------- Average duration of loan ------------------------
select avg(duration) as avg_duration from loan;

------------------ Total Balance --------------------------------
select credit,debit,(credit-debit)/(pow(10,6)) as temp from (
select sum(case when type_ = 'Credit' then amount else 0 end) as credit,
sum(case when type_ = 'Withdrawal' then amount else 0 end) as debit 
from transaction ) as temo;

---------------------- Total number of transaction ------------------------
select count(distinct trans_id)/pow(10,3) as total_transaction from transaction;






 
 




