/*
Create the schema for Bank segmentation analysis by creating the three tables transactionns,accounts,customers
by  using various constraints to create the column values .
*/

IF OBJECT_ID('transactions','U') IS NOT NULL
    DROP TABLE transactions;
GO

IF OBJECT_ID('accounts','U') IS NOT NULL
    DROP TABLE accounts;
GO

IF OBJECT_ID('customers','U') IS NOT NULL
    DROP TABLE customers;
GO


create table customers(
customer_id int identity(1,1) primary key,
customer_name text not null,
gender varchar(1) check(gender in('M','F')),
dob date not null,
signup_date date not null,
city text
);

go

create table accounts(
account_id int identity(1,1) primary key,
customer_id int references customers(customer_id),
account_type varchar(10) check(account_type in ('savings','current','loan')),
account_number text,
open_date date not null,
balance numeric(12,2) default 0
);

go

create table transactions(
transaction_id int identity(1,1) primary key,
account_id int references accounts(account_id),
transactions_date date not null,
amount numeric(12,2) not null,
transaction_type varchar(20),
description varchar(50)
);
go

