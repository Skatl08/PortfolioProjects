#Q1. Print product, price, sum of quantity more than 5 sold during all three months.  
Select product, price , month, sum(quantity )
from bank_inventory_pricing
Group by product , month
Having sum(quantity) > 5;

#Q2.Print product, quantity , month and count of records for which estimated_sale_price is less than purchase_cost
Select product, quantity , month ,
sum( COALESCE ( estimated_sale_price < purchase_cost , 0, 1 )  ) count_of_trans
from bank_inventory_pricing
group by product , month
having sum( COALESCE ( estimated_sale_price < purchase_cost , 0, 1 )  )  > 0;

#Q3. Extarct the 3rd highest value of column Estimated_sale_price from bank_inventory_pricing dataset
SELECT Estimated_sale_price FROM bank_inventory_pricing ORDER BY Estimated_sale_price DESC LIMIT 2,1;

#Q4. Count all duplicate values of column Product from table bank_inventory_pricing
SELECT Product, count(Product) FROM bank_inventory_pricing GROUP BY Product HAVING count(Product) > 1;

#Q5. Create a view 'bank_details' for the product 'PayPoints' and Quantity is greater than 2 
CREATE VIEW bank_details1 AS
SELECT Product, Quantity, Price FROM bank_inventory_pricing
WHERE Product = 'PayPoints' AND
Quantity > 2;
SELECT * FROM bank_details1;

#Q6 Update view bank_details1 and add new record in bank_details1.
-- --example(Producct=PayPoints, Quantity=3, Price=410.67)
UPDATE bank_details1
   SET Product= 'PayPoints' 
    WHERE Quantity=3 AND Price=410.67;

#Q7.Real Profit = revenue - cost  Find for which products, branch level real profit is more than the estimated_profit in Bank_branch_PL.
Select branch, sum(estimated_profit)  , sum(revenue - cost )   
From Bank_branch_PL
Group by branch
having  (sum(estimated_profit)  > sum(revenue - cost ) );

#Q8.Find the least calculated profit earned during all 3 periods
Select branch, product, cost , min(revenue-cost)
From Bank_branch_PL
group by  branch, product
having min(revenue-cost) > 0;

#Q9. In Bank_Inventory_pricing, 
-- a) convert Quantity data type from numeric to character 
-- b) Add then, add zeros before the Quantity field.  
SELECT lpad( convert(quantity , char) , 4, "0")  from Bank_Inventory_pricing;

#Q10. Write a MySQL Query to print first_name , last_name of the titanic_ds whose first_name Contains ‘U’
SELECT Quantity , Product FROM Bank_Inventory_pricing WHERE Product LIKE '%U%';

#Q11.Reduce 30% of the cost for all the products and print the products whose  calculated profit at branch is exceeding estimated_profit .
Select branch,product,  sum(estimated_profit)  , sum(revenue- .7*cost)
From Bank_branch_PL
where revenue < cost
group by  branch , product
having sum(revenue- .7*cost) >  sum(estimated_profit);

#Q12.Write a MySQL query to print the observations from the Bank_Inventory_pricing table excluding the values “BusiCard” And “SuperSave” from the column Product
SELECT * FROM Bank_Inventory_pricing  
WHERE Product NOT IN ('BusiCard','SuperSave');

#Q13. Extract all the columns from Bank_Inventory_pricing where price between 220 and 300
Select * from Bank_Inventory_pricing where price between 220 and 300;

#Q14. Display all the non duplicate fields in the Product form Bank_Inventory_pricing table and display first 5 records.
select distinct product from Bank_Inventory_pricing where product is not null limit 5;

#Q15.Update price column of Bank_Inventory_pricing with an increase of 15%  when the quantity is more than 3.
Update Bank_Inventory_pricing set price = price * 1.15 Where quantity > 3;

#Q16. Show Round off values of the price without displaying decimal scale from Bank_Inventory_pricing
SELECT convert ( price, decimal(5,0) ) as estimated_sale_price FROM Bank_Inventory_pricing;
select * from Bank_Inventory_pricing;

#Q17.Increase the length of Product size by 30 characters from Bank_Inventory_pricing.
Alter table Bank_Inventory_pricing modify Product VARCHAR (30);

#Q18. Add '100' in column price where quantity is greater than 3 and dsiplay that column as 'new_price' 
select price + '100' as new_price from Bank_Inventory_pricing where quantity > 3;

#Q19. Display all saving account holders have “Add-on Credit Cards" and “Credit cards" 
SELECT  
br_1.Account_Number primary_account_number ,
br_1.Account_type primary_account_type,
br_2.Account_Number secondary_account_number,
br_2.Account_type secondary_account_type
from bank_account_relationship_details br_1
JOIN bank_account_relationship_details br_2
on br_1.Account_Number = br_2.Linking_Account_Number
and br_2.Account_type like '%Credit%' ;

#Q20.
# a) Display records of All Accounts , their Account_types, the transaction amount.
# b) Along with first step, Display other columns with corresponding linking account number, account types 
# c) After retrieving all records of accounts and their linked accounts, display the  transaction amount of accounts appeared  in another column.
SELECT br1.Account_Number primary_account_number ,
br1.Account_type primary_account_type,
br2.Account_Number secondary_account_number,
br2.Account_type secondary_account_type,  
bt1.Transaction_amount   primary_acct_tran_amount
from bank_account_relationship_details br1
LEFT JOIN bank_account_relationship_details br2
on br1.Account_Number = br2.Linking_Account_Number
LEFT JOIN bank_account_transaction bt1
on br1.Account_Number  = bt1.Account_Number;

#Q21.Display all type of “Credit cards”  accounts including linked “Add-on Credit Cards" 
# type accounts with their respective aggregate sum of transaction amount. 
# Ref: Check linking relationship in bank_transaction_relationship_details.
# Check transaction_amount in bank_account_transaction. 
Select
br1.Account_Number Primary_account_number,
br1.Account_type Primary_account_type,
br2.Account_Number Secondary_account_number,
br2.Account_type Secondary_account_type,
sum(bt2.Transaction_amount)  Secondary_account_transaction_amount
FROM bank_account_relationship_details br1
JOIN bank_account_relationship_details br2
ON  br1.Account_Number   = br2.Linking_Account_Number
AND br2.Account_type      = '%Credit%'    
JOIN bank_account_transaction bt2
on bt2.Account_Number = br2.Account_Number
group by
br1.Account_Number,
br1.Account_type,
br2.Account_Number,
br2.Account_type; 

#Q22. Compare the aggregate transaction amount of current month versus aggregate transaction with previous months.
# Display account_number, transaction_amount , 
-- sum of current month transaction amount ,
-- current month transaction date , 
-- sum of previous month transaction amount , 
-- previous month transaction date.
 SELECT
bt1.account_Number  Primary_account_number,
date_format(bt2.Transaction_Date , '%Y-%m') next_month_transaction_date,
sum(bt2.Transaction_amount) current_month_cr_tran,
sum(bt1.Transaction_amount) prev_month_cr_tran,
date_format(bt1.Transaction_Date , '%Y-%m') previous_month_transaction_date
FROM
bank_account_transaction bt2
JOIN
bank_account_transaction bt1
on bt2.Account_Number = bt1.Account_Number
and date_format(bt2.Transaction_Date , '%Y-%m') > date_format(bt1.Transaction_Date , '%Y-%m')
group by
bt2.account_Number,
date_format(bt2.Transaction_Date , '%Y-%m') ,
date_format(bt1.Transaction_Date , '%Y-%m');

#Q23.Display individual accounts absolute transaction of every next  month is greater than the previous months .
SELECT
bt2.account_Number  Primary_account_number,
sum(bt2.Transaction_amount) current_month_tran,
bt2.Transaction_Date CURRENT_tran_date,
sum(bt1.Transaction_amount) prev_month_tran,
bt1.Transaction_Date prev_tran_date
FROM bank_account_transaction bt2
JOIN bank_account_transaction bt1
on bt2.Account_Number = bt1.Account_Number
and bt2.Transaction_Date > bt1.Transaction_Date
group by 
bt2.account_Number,
bt2.Transaction_Date,
bt1.Transaction_Date
HAVING abs(sum(bt2.Transaction_amount)) > abs(sum(bt1.Transaction_amount));

#Q24. Find the no. of transactions of credit cards including add-on Credit Cards
SELECT
	br1.Account_Number credit_card_account_number,
	br1.Account_type   credit_card_account_type,
	count(bat.transaction_amount) count_of_Transaction_amount
FROM
 	bank_account_relationship_details br1
LEFT JOIN
 	bank_account_relationship_details br2
ON br1.Account_Number     = br2.Linking_Account_Number
JOIN bank_account_transaction bat
ON   br1.Account_Number = bat.Account_Number
and  br1.Account_type   like '%Credit%'
group by
	br1.Account_Number,
	br1.Account_type;
    
#Q25.From employee_details retrieve only employee_id , first_name ,last_name phone_number ,salary, job_id where department_name is Contracting (Note
#Department_id of employee_details table must be other than the list within IN operator.
SELECT employee_id , first_name,last_name,phone_number,salary, job_id
FROM employee_details
WHERE DEPARTMENT_ID NOT IN(
SELECT DEPARTMENT_ID FROM Department_Details
WHERE DEPARTMENT_NAME='Contracting');   

    
#Q26. Display savings accounts and its corresponding Recurring deposits transactions are more than 4 times.
SELECT
	ba.Account_Number savings_account_number,
	ba.Account_type   savings_account_type,
	br.Account_Number recurring_deposit_account_number,
	br.Account_type   recurring_deposit_account_type,
	count(bat.transaction_date) transaction_date
FROM bank_account ba
JOIN bank_account_relationship_details br
ON ba.Account_Number = br.Linking_Account_Number
JOIN bank_account_transaction bat
ON   br.Account_Number = bat.Account_Number
and  br.Account_type   = 'RECURRING DEPOSITS'
group by
	ba.Account_Number,
	ba.Account_type  ,
	br.Account_Number,
	br.Account_type  
having count(bat.transaction_date) > 3;

#Q27. From employee_details fetch only employee_id, ,first_name, last_name , phone_number ,email, job_id where job_id should not be IT_PROG.
 select employee_id , first_name,last_name,phone_number,email, job_id 
 from employee_details where Job_id = any (select job_id from employee_details where Not Job_id = 'IT_PROG');
 
#Q28.The DEPARTMENT_ID of employee_details table must be the same DEPARTMENT_ID of employee_details table with following conditions -
#1.DEPARTMENT_ID of employee_details table should come distinctly
#2.Employee_id should be 109
SELECT employee_id , first_name, last_name, salary, job_id
FROM employee_details
WHERE  DEPARTMENT_ID=(
SELECT DISTINCT  DEPARTMENT_ID
FROM employee_details WHERE EMPLOYEE_ID='109'); 


#Q29.From employee_details retrieve only employee_id , first_name ,last_name phone_number ,salary, job_id where manager_id is '60' (Note
#Department_id of employee_details table must be other than the list within IN operator.
SELECT employee_id , first_name,last_name,phone_number,salary, job_id
FROM employee_details
WHERE DEPARTMENT_ID NOT IN(
SELECT DEPARTMENT_ID FROM Department_Details
WHERE MANAGER_ID=60);  

#Q30.Create a new table as emp_dept and insert the result obtained after performing inner join on the two tables employee_details and department_details.
CREATE TABLE emp_dept AS
SELECT ed.employee_id, ed.first_name, ed.last_name, ed.phone_number, ed.job_id, dept.department_name, dept.location_id
FROM employee_details as ed
INNER JOIN
department_details as dept ON ed.EMPLOYEE_ID = dept.EMPLOYEE_ID;
