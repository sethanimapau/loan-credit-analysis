USE CreditUnion

Select * 
From CU;

--1. How many loans are in each loan status category?
Select loan_status, count(*) as Num_of_Loans
From CU
Group by loan_status
Order by Num_of_Loans desc;

--2. What is the average loan amount, interest rate, and installment by loan grade?
Select Grade, avg(loan_amount) as L_amount, Round(avg(int_rate),2) as Interest, Round(avg(installment),2) as Installment
From CU
Group by grade
Order by L_amount desc

---3. Which top 10 states have the highest total loan amount issued?
Select Top 10 address_state, sum(loan_amount) as Total_Loan
From CU
Group by address_state
Order by Total_Loan desc


--4. What is the default rate (% of Charged Off loans) for each employment length band?
Select emp_length, count(*) as Number_of_loans, Round(100 * sum(Case when loan_status='Charged Off' then 1 Else 0 end)/count(*),2) as Percentage
From CU
Group by emp_length
Order by Percentage desc

--5. Find borrowers whose total payment is less than 50% of their loan amount — how many are there per grade?
With CTE AS (
Select ID, Grade, loan_amount, Sum(total_payment) AS Total_Payment
from CU
where total_payment < 0.5*loan_amount
Group by ID, loan_amount, Grade
)
Select Grade, Count(*) AS Num
from CTE
Group by Grade
Order by Num desc

---6. What is the average DTI (debt-to-income) for Fully Paid vs Charged Off loans, broken down by home ownership?
Select loan_status,home_ownership, Round(avg(DTI),2) AS AvgDTI
From CU
where loan_status in('charged off','fully paid')
Group by loan_status, home_ownership
Order by AvgDTI desc


--7. Rank sub-grades by average interest rate within each grade using a window function.
WITH avg_rates AS (
    SELECT 
        grade,
        sub_grade,
        ROUND(AVG(int_rate), 2) AS avg_int_rate
    FROM CU
    GROUP BY grade, sub_grade
)
SELECT 
    grade,
    sub_grade,
    avg_int_rate,
    RANK() OVER (
        PARTITION BY grade         
        ORDER BY avg_int_rate DESC  
    ) AS rank_within_grade
FROM avg_rates
ORDER BY grade, rank_within_grade;

