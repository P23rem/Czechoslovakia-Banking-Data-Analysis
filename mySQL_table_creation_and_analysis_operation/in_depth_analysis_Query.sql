use bank_stu_data;

------------------------------ Indepth Analysis of data -----------------------------

------------ Total cash Withdrawal per Account --------------------------------------------
select account_id,sum(amount) as total_withdrawal from transaction
where operation='Withdrawal in cash' 
group by 1
order by 2 desc;

------------- Highest Balance after Interest Credit ------------------------------------
select account_id,balance
from transaction
where operation ='Interest Credit'
order  by 2 desc;  ---- The range is very close as the top balance is 148366.1 and followed by acccount_id with 145342.6 and 144251.6

---- consistenly withdrawing money from last 2 month ---------------
with temp as(
select * from transaction 
where date_>=(select date_sub(max(date_),interval 2 month) from transaction)),temp2 as (
select account_id,sum(case when type_='Credit' then 1 else 0 end) as credit_count,
sum(case when type_='Withdrawal' then 1 else 0 end) as Withdrawal_count from temp
group by 1)
select count(account_id) as total_account_with_consistent_withdrawal
from temp2
where Withdrawal_count>=0.75*(Withdrawal_count+credit_count); ---- 20 account has shown consistent withdrawal in last 2 months

------------------------- Total Transaction by purpose --------------------------------------
select purpose,count(1) as total_transaction from transaction 
group by purpose
order by 2 desc; ------------------ transaction for loan payment is highest and then interest credited and after that Payment on Statement

-------------- Detect account with unusual Large Interest Payment Credited ----------------------
select distinct account_id,amount,balance from transaction 
where purpose='Interest Credited' and
amount>=(select avg(amount)+2*stddev(amount) from transaction where purpose='Interest Credited')
order by 2 desc;
------- account id 3127 with interest credited is 503 and then 2219 with 500

--------------------------- Total amount deposited in the bank -------------------------------
select bank,sum(balance) as total_amount_deposited
from (
select * from (select
*,row_number() over(partition by account_id,bank order by date_ desc) as rnk_number 
from transaction
) as temp
 where rnk_number=1) as temp2
 group by 1
 order by 2 desc;
 
----------------------- Distribution of Customer based on Gender -------------------------
select sum(case when Gender='Male' then 1 else 0 end)*100/count(*) as total_male_pt
,sum(case when Gender='Female' then 1 else 0 end)*100/count(*) as total_female_pt
from(select distinct client_id,Gender from client) as temp; ----- 52% Male and 48% female

------------/* 1. What is the demographic profile of the bank's clients and how does it vary 
across districts? YEAR WISE COUNTS.*/
select * from client;
select * from district;

select a.district_code,a.district_name,count(b.client_id) as total_customer,concat(round(sum(case when b.Gender='Male' then 1 else 0 end)*100/count(b.client_id)),"%") as total_male_pt,
concat(round(sum(case when b.Gender='Female' then 1 else 0 end)*100/count(b.client_id)),"%") as total_Female_pt,
round(avg(b.age)) as average_age
from district as a
inner join 
client as b
on a.district_code=b.district_id
group by 1,2
order by  3 desc; ----- Hl.m.Praha has highest number of customer and has significant difference in total number of customer from 2nd highest one which is Ostrava and has 179 customers.

--------------------------- How the banks have performed over the years.Give their detailed analysis month wise?----------------
select * from transaction;
select year,month,bank,total_credit,total_withdrawal,case when total_credit-total_withdrawal>0 then 
concat("Net Credit  ",total_credit-total_withdrawal) else concat('Net Withdrawal   ',total_withdrawal-total_credit) end as net_operation
,total_number_of_transactions
from(
select bank,year(date_) as year,month(date_) as month,sum(case when type_='Credit' then amount else 0 end) as total_credit,
sum(case when type_='Withdrawal' then amount else 0 end) as total_withdrawal,
sum(trans_id) as total_number_of_transactions
from transaction 
group by 1,2,3
order by 3 desc) as temp
order by 3,2,1;

--------------- Most Common Account Types & Profitability--------------------------
select * from account;
select * from disp;
select * from transaction;
select * from card;

with temp as(
select a.district_id,a.frequency,a.date_ as a_date_2,a.Account_type,a.Card_Assigned,b.* from account as a
inner join transaction as b
on b.account_id=a.account_id
inner join
(select c.card_id,c.type_ as c_type_2,d.account_id as account_id_d,d.type_,d.client_id from 
disp as d
inner join card as c
on c.disp_id=d.disp_id) as temp
on temp.account_id_d=b.account_id)
select  Account_type,count(distinct account_id) as total_card,count(trans_id) as total_transaction 
,sum(amount) as total_amount_transacted
from temp 
group by 1; ---- The card issued for Nri account is highest (251) with total number of transaction 32238 and 28.08 M total transactions

------------------ Which district has very less number of active bank users and for which Account_type --------------------------
select * from district;
select * from transaction;
select * from account;
with temp as (
select a.account_id, a.Account_type, a.district_id, b.district_name
from account a
inner join district b on b.district_code = a.district_id
left join transaction t on t.account_id = a.account_id where t.account_id is null
),
total_customer as (select a.district_id, a.Account_type, b.district_name, count(distinct a.account_id) as total_
from account a
inner join district b on b.district_code = a.district_id
group by 1,2,3)
select temp.district_name, temp.Account_type, count(distinct temp.account_id) as total_inactive_customer,
total_customer.total_ as total_customer,
round(count(distinct temp.account_id)*100.0/total_customer.total_,2) as total_percent_of_inactive_customer
from temp
inner join total_customer 
on total_customer.district_name = temp.district_name and total_customer.Account_type = temp.Account_type
group by 1,2, total_customer.total_
order by 4,5 desc; ----------------- 

--------------------------------------------- Average loan amount based on Gender ----------------
select * from loan
order by account_id;
select * from client;
select * from account;
select * from disp;
select round(sum(case when client_info.Gender='Female' then l.amount else 0 end)*100/sum(l.amount),2) as total_loan_by_female
,round(sum(case when client_info.Gender='male' then l.amount else 0 end)*100/sum(l.amount),2) as total_loan_by_male
 from(
select a.client_id,a.account_id,b.district_id,b.Gender
from disp as a inner join client as b
on b.client_id=a.client_id) client_info
inner join loan as l
on l.account_id=client_info.account_id; -------------- 48.76% loan taken by female and 51.24 are taken by male.

------------------------- Bank who issued the different card -------------------

select distinct year(issued) from card;

select distinct year(issued), count(*) as total_count from card
group by 1 order by 1; --- Constantly the number of card issued increasing

----------- Number of loan Clients Who Took Loans But Have Low Transaction Activity --------------
with ranked as (
  select 
    account_id,
    count(*) as num_transactions
  from transaction
  group by account_id
),
bucketed as (
  select 
    account_id,
    num_transactions,
    ntile(4) over (order by num_transactions) as quartile
  from ranked
),temp2 as(
select 
  min(case when quartile = 1 then num_transactions end) as q1_lower,
  max(case when quartile = 1 then num_transactions end) as q1_upper,
  min(case when quartile = 3 then num_transactions end) as q3_lower,
  max(case when quartile = 3 then num_transactions end) as q3_upper
from bucketed)
select (count(account_id)*100)/(select count(distinct account_id) from loan) as total_customer_having_loan_but_fewer_transactions
from (
select loan.account_id,count(transaction.trans_id) as total_number_of_transaction
from loan
left join transaction 
on loan.account_id=transaction.account_id
group by 1
having count(transaction.trans_id)<=(select Q1_upper from temp2)
order by 2 ) as initial;

------------------------ Which distirict has most number of defaulter --------------------
select * from loan	;
select * from district;
select * from account;
with temp as(
select d.district_code,d.district_name,count(l.loan_id) as total_loan_given,
sum(case when l.status_='Client in debt' then 1 else 0 end ) as total_default
from loan as l
inner join account as a
on a.account_id=l.account_id
inner join district as d
on d.district_code=a.district_id
group by 1,2)
select *,round(total_default*100/total_loan_given,2) as percentage_of_default
from temp
order by 5 desc;

------------------- Which Account Types have the highest average balance ------------------------
select * from account;
select * from transaction;
SELECT 
    a.Account_type,
    round(avg(t.amount), 2) as avg_transaction_amount
from account a
join transaction t ON t.account_id = a.account_id
group by a.Account_type
order by avg_transaction_amount desc; ------------- NRI account 

-------------- What is the average time between a customer opening an account and receiving a card? ----------
select * from account;
select * from card;
select * from disp;
select avg(datediff(a.issued,b.date_)) as average_days_to_receive_card from 
account as b
inner join disp as d
on b.account_id=d.account_id
inner join card as a on d.disp_id=a.disp_id;  ------------- 777 days
------------------- How many client have cards ---------------------------
select * from client;
select * from card;
select count(distinct card_id)*100/(select count(distinct client_id) from client) from card;


-------- Average Transaction done by Card Holder -------------------------- 

select avg(total_tran) as average_transaction_done_by_Card from (
select a.account_id,count(distinct b.trans_id) as total_tran
from account as a
inner join 
transaction as b
on a.account_id=b.account_id
inner join disp as c
on c.account_id=a.account_id
inner join card as d
on d.disp_id=c.disp_id
group by 1) as temp;

------------------------------- How many client never used their transaction ------------------
select count(distinct a.account_id) as total_customer_who_never_used_their_account
from account as a
right join transaction as b
on b.account_id=a.account_id
where b.amount is null; ----------- every customer have used at least a times --------

-------------------------- district wise distribution of the Card_Assigned ------------------
select a.district_code,a.district_name,
sum(case when b.Card_Assigned='Silver' then 1 else 0 end)*100/count(*) as pt_of_Silver,
sum(case when b.Card_Assigned='Diamond' then 1 else 0 end)*100/count(*) as pt_of_diamond,
sum(case when b.Card_Assigned='Gold' then 1 else 0 end)*100/count(*) as pt_of_Gold
from district as a
inner join account as b
on b.district_id=a.district_code
group by 1,2
order by 3,4,5 desc;

------------------- Average Number of transaction on the basis of district and Card_Assigned -------------
select c.district_code,c.district_name,sum(case when b.Card_Assigned='Diamond' then 1 else 0 end) as no_of_txn_of_diamon,
sum(case when b.Card_Assigned='Silver' then 1 else 0 end) as no_of_txn_silver,
sum(case when b.Card_Assigned='Gold' then 1 else 0 end) as no_of_txn_Gold
from account as b
inner join 
transaction as a
on a.account_id=b.account_id
inner join district as c on 
c.district_code=b.district_id
group by 1,2;

--------------------- Most of the transaction done based on age --------------
select * from client;
select * from transaction;
select * from disp;
with temp as(
select c.age,count(d.trans_id) as total_transaction_done
from transaction as d
inner join disp as a
on a.account_id=d.account_id
inner join client as c
on c.client_id=a.client_id
group by c.age order by 2 desc),temp2 as(
select age,total_transaction_done,(case when age<18 then 'Child'
when age>=18 and age<25 then 'Adult'
when age>=25 and age<35 then 'Millennial'
when age>=35 and age<50 then 'Middle Age'
when age>=50 and age<65 then 'Senior'
else 'Old' end ) as Age_classification from temp)
select Age_classification,sum(total_transaction_done) as total_transaction
from temp2
group by 1 order by 2 desc; --- Middle Age has highest number of transaction followed by Senior and then Millennial

------------------------- Total Loan taken on the basic of age ----------------------------------
select * from loan order by account_id;
select * from client;
select * from disp;
with temp as(
select a.disp_id,a.client_id,a.type_,b.account_id,b.loan_id,b.amount,b.status_,(
case when c.age<18 then 'Child'
when c.age>=18 and age<25 then 'Adult'
when c.age>=25 and age<35 then 'Millennial'
when c.age>=35 and age<50 then 'Middle Age'
when c.age>=50 and age<65 then 'Senior'
else 'Old' end) as age_classification
from disp as a
inner join loan as b
on a.account_id=b.account_id
inner join client c 
on c.client_id=a.client_id)
select a.age_classification,a.total_loan,b.total_defaulted_loan from (
select age_classification,count(loan_id) as total_loan
from temp 
group by 1)as a
inner join (select age_classification,count(loan_id) as total_defaulted_loan
from temp
where status_='Client in debt'
group by 1) as b
on a.age_classification=b.age_classification; -------- Middle age people have taken most number of loan and number of defaulted loan in them is almost 5.2% followed by Senior people

------------------ Which Gender has defaulted most -------------------------------------
select * from client;
select * from loan;
select * from disp;
select c.Gender,count(b.loan_id) as total_default
from 
client as c
inner join disp as d
on d.client_id=c.client_id
inner join loan as b
on d.account_id=b.account_id
where b.status_='Client in debt'
group by 1; -------------- Almost equal number of default by both male and female(23- Female and 22- Male)

-------------------- District distribution of product ---------------------
select * from district;
select * from card;
select * from disp;
select * from account;
select a.district_code,a.district_name,
sum(case when b.Card_Assigned='Gold' then 1 else 0 end) as total_gold_type_customer,
sum(case when b.Card_Assigned='Diamond' then 1 else 0 end) as total_Diamond_type_customer,
sum(case when b.Card_Assigned='Silver' then 1 else 0 end) as total_Silver_type_customer
from account as b
inner join district as a
on a.district_code=b.district_id
group by 1,2
order by 1;

----- Bad debt given over the year --------------------
select year(date_) as year
,sum(amount) as total_debt
from loan
where status_='Client in debt'
group by 1
order by 1;

------------ total_balance per account throught the year -----------------------
with temp as (
select year(date_) as date_,bank,sum(case when type_='Credit' then amount else -1*amount end) as total_balance
,count(distinct account_id) as total_account
from transaction 
group by 1,2)
select date_,bank,total_balance,total_account,total_balance/total_account
from temp
order by 2 desc;

--------------- COunt number of transaction by bank -----------------
select bank,count(distinct trans_id) as total_transaction 
from transaction 
group by 1;








