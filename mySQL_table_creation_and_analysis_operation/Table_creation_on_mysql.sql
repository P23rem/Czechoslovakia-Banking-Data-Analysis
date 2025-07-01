create database bank_stu_data;

use bank_stu_data;
create table account(account_id int,
district_id int,frequency varchar(30),date_ varchar(10),Account_type varchar(30));

create table card(card_id int,disp_id int,type_ varchar(10),issued varchar(40));



create table disp(disp_id int,client_id int,account_id int ,type_ varchar(10));


create table district(A1 int,A2 varchar(30),A3 varchar(20),A4 int,A5 int,A6 int,
A7 int,A8 int,A9 int,A10 decimal(4,1),A11 int,A12 decimal(3,2),A13 decimal(3,2),A14 int,A15 int,A16 int);


CREATE TABLE loan (
  loan_id INT,
  account_id INT,
  date_ CHAR(20),  -- since format is YYMMDD like '930705'
  amount DECIMAL(10,2),
  duration INT,
  payment DECIMAL(10,2),
  status_ varchar(30)
);





create table order_details(order_id int,account_id int,Bank_to varchar(30),account_to int,amount decimal(5,1));



create table transaction(trans_id int,
account_id int,
date_ date,
type_ varchar(30),
operation varchar(30),
amount int,
balance decimal(10,1),
purpose varchar(20),
bank varchar(30),
account_pattern_id int);













