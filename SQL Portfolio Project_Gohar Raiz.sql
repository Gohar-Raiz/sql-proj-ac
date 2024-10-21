select * from customer_churn;
describe customer_churn;
-- data types of all columns is correct
select * from customer_churn where `Churn Reason` is null;
select distinct * from customer_churn where `Customer ID`;
-- adding primary key to Customer ID as it is unique identifier for all rows in dataset

select * from customer_churn;
select length(`Customer ID`) from customer_churn;
-- changing the datatype and setting it to primary key
alter table customer_churn
modify column `Customer ID` varchar(15);
alter table customer_churn
add primary key (`Customer ID`);

-- setting empty rows in both these columns to null
set sql_safe_updates = 0;
start transaction;
update customer_churn
set `Churn Reason` = null
where `Churn Reason` = " ";
commit;
start transaction;
update customer_churn
set `Churn Category` = null where `Churn Category` = "";
commit;
select `Churn Category` from customer_churn;
select * from customer_churn;
-- -----------------------------------




-- Query 1: Considering the top 5 groups with the highest average monthly charges among churned customers,
-- how can personalized offers be tailored based on age, gender, and contract type to potentially improve
-- customer retention rates?
SELECT 
CASE
	WHEN `Age` <= 25 THEN "gen_z"
    WHEN `Age` >= 26 AND `Age` <= 41 THEN "millennial"
    WHEN `Age` >= 42 THEN "gen_x"
    END AS age_groups,
`Gender`, `Contract`, ROUND(AVG(`Monthly Charge`), 2) AS avg_monthly_charge
FROM customer_churn
WHERE `Churn Label` = "Yes"
GROUP BY age_groups, `Gender`, `Contract`
ORDER BY avg_monthly_charge DESC
LIMIT 5;
-- ------------------------------------------------
-- Initially I wanted to do grouping based on monthly charges, make categories on monthly average charge range with min and max value
-- in data as lower and upper bounds for the range. But age, gender categories wont be grouped in aove categories, then I would have to go deep dive 
-- into each monthly charge category and see what range of age and how gender and contract are spread out, making it complicated.

-- I have made age groups as Gen X, Millennials, Gen Z using CASE statements
-- GROUP BY on the asked categories in query: Age, gender, Contract which have less than 5 sub categories themselves
-- ORDER BY averge monthly charge of each age group, in descending order, with expensive at top

-- ------------------------------------------------------------------
-- Query 2: What are the feedback or complaints from those churned customers
SELECT DISTINCT `Churn Reason`, COUNT(`Churn Reason`) AS frequency FROM customer_churn
WHERE `Churn Reason` IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
limit 3;
-- In SELECT clause, I have selected only the unique churn reason; some reasons are definitely repeated across the churned customers
-- GROUP BY unique churn reason and counting the churn reasons as frequency, ORDER BY frequency in descending order
-- Allowing me to see top churn reasons given by most people; higher frequency
-- Top 3 reasons for customers to churn away!

-- lets look deeper into churn categories and their accompanying churn reasons.
select distinct `Churn Category`, count(*) from customer_churn
where `Churn Label` = "Yes" 
group by 1 
order by 2 desc;
select distinct `Churn Reason`, `Churn Category` from customer_churn
where `Churn Label` = "Yes" having `Churn Category` = "Other";
select distinct `Churn Category` from customer_churn;

select distinct `Churn Reason`, `Churn Category` from customer_churn
where `Churn Label` = "Yes" having `Churn Category` = "Dissatisfaction";
-- poor expertise of online support needs to be in dissatisfaction category not others
start transaction;
update customer_churn
set `Churn Category` = "Dissatisfaction"
where `Churn Reason` = "Poor expertise of online support" and `Churn Category` = "Other";
commit;




-- -------------------------------------------------------------

-- Query 3: How does the payment method influence churn behavior?
SELECT DISTINCT `Payment Method`, COUNT(`Payment Method`) FROM customer_churn
WHERE `Churn Label` = "Yes"
GROUP BY 1;

-- Unique payment methods were selected in SELECT clause, along with their count of customers opting to those methods and churned

-- trying to delve into reasons why so many churned customers due to bank withdrawl:
select * from customer_churn where `Payment Method` = "Bank Withdrawal" having `Churn Label` = "Yes";
select count(*), `Contract` from customer_churn where `Payment Method` = "Bank Withdrawal" and `Churn Label` = "Yes" group by 2;



