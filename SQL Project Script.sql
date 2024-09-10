select * from amazon;
select distinct `product line` from amazon;
alter table amazon
add column dayname varchar(10);
update amazon
set dayname = DATE_FORMAT(Date, '%a');

alter table amazon
add column monthname varchar(10);

update amazon
set monthname = date_format(Date, '%b');

create table Product (
    Product_ID int auto_increment primary key,
    Product_Line varchar(100),
    Unit_Price float
);


-- Insert data into Product table
insert into Product (Product_Line, Unit_Price)
select distinct `Product line`, `Unit price`
from amazon;
select * from product;
drop table sales;
create table Sales (
    Sales_ID INT AUTO_INCREMENT PRIMARY KEY,
    Invoice_ID VARCHAR(20),
    Product_ID INT,
    Quantity INT,
    Tax_5 FLOAT,
    Total FLOAT,
    COGS FLOAT,
    Gross_Income FLOAT,
    monthname varchar(50),
    timeofday varchar(50),
    Payment varchar(50),
    Branch varchar(1),
    City varchar(100),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Insert data into Sales table
INSERT INTO Sales (Invoice_ID, Product_ID, Quantity, Tax_5, Total, COGS, Gross_Income, monthname, timeofday, Payment, Branch, City)
SELECT `Invoice ID`, 
       (SELECT Product_ID FROM Product WHERE Product.Product_Line = amazon.`Product line` LIMIT 1), 
       Quantity, `Tax 5%`, Total, COGS, `gross income`, monthname, Timeofday, Payment, Branch, City
FROM amazon;
select * from sales;

create table Customer (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Invoice_ID VARCHAR(20),
    Customer_Type VARCHAR(20),
    Gender VARCHAR(10),
    Rating FLOAT,
    Branch VARCHAR(1)
);

-- Insert data into Customer table
insert into Customer (Invoice_ID, Customer_Type, Gender, Rating, Branch)
select `Invoice ID`, `Customer type`, Gender, Rating, Branch
from amazon;
select * from customer;

-- Count of distinct product lines
select count(distinct Product_Line) as DistinctProductLines
from Product;

-- Product lines with the highest revenue
select P.Product_Line, SUM(S.Total) as TotalRevenue
from Product P
join Sales S on P.Product_ID = S.Product_ID
group by P.Product_Line
order by TotalRevenue DESC; 

-- Total revenue generated each month
select monthname, SUM(S.Total) AS MonthlyRevenue
FROM Sales S
GROUP BY S.monthname
ORDER BY MonthlyRevenue desc;

-- City with the highest sales revenue
select S.City, sum(S.Total) as CityRevenue
from Sales S
group by S.City
order by CityRevenue desc
limit 1;

-- Most frequent payment method
select S.Payment, count(*) as PaymentCount
from Sales S
group by S.Payment
order by PaymentCount desc
limit 1;

-- Customer type contributing the highest revenue
select C.Customer_Type, sum(S.Total) as TotalRevenue
from Customer C
join Sales S on C.Invoice_ID = S.Invoice_ID
group by C.Customer_Type
order by TotalRevenue desc;

-- Average rating for each product line
select P.Product_Line, avg(C.Rating) as AverageRating
from Customer C
join Sales S on C.Invoice_ID = S.Invoice_ID
join Product P on S.Product_ID = P.Product_ID
group by P.Product_Line
order by AverageRating DESC;


ALTER TABLE amazon
ADD COLUMN time_ofday VARCHAR(15);

UPDATE amazon
SET timeofday = CASE
    WHEN TIME(Time) < '12:00:00' THEN 'Morning'
    WHEN TIME(Time) < '18:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- What is the count of distinct cities in the dataset?
SELECT  count(distinct City) AS DistinctCities
FROM amazon; -- 3

-- For each branch, what is the corresponding city?
SELECT Branch, City
FROM amazon
GROUP BY Branch, city; -- Yangon, Naypyitaw, Mandalay

-- What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT `Product line`) AS DistinctProductLines
FROM amazon; -- 6

-- Which payment method occurs most frequently?
SELECT Payment, COUNT(*) AS Frequency
FROM amazon
GROUP BY Payment
ORDER BY Frequency DESC
LIMIT 1; -- Ewallet

-- Which product line has the highest sales?
SELECT `Product line`, SUM(Total) AS TotalSales
FROM amazon
GROUP BY `Product line`
ORDER BY TotalSales DESC; -- Food and Beverages

-- How much revenue is generated each month? 
SELECT monthname, SUM(Total) AS MonthlyRevenue
FROM amazon
GROUP BY monthname
ORDER BY monthname; -- jan - 116291.86800000005, Feb - 97219.37399999997, Mar - 109455.50700000004

-- In which month did the cost of goods sold reach its peak?
SELECT monthname, SUM(cogs) AS TotalCOGS
FROM amazon
GROUP BY monthname
ORDER BY TotalCOGS DESC
limit 1; -- January

-- Which product line generated the highest revenue?
select `Product line`, SUM(Total) AS TotalRevenue
from amazon
group by `Product line`
order by TotalRevenue desc
limit 1; -- Food and beverages

-- In which city was the highest revenue recorded?
select City, sum(Total) as TotalRevenue
from amazon
group by City
order by TotalRevenue desc
limit 1; -- Naypyitaw

-- Which product line incurred the highest Value Added Tax?
select `Product line`, SUM(`Tax 5%`) as TotalVAT
from amazon
group by `Product line`
order by TotalVAT desc; -- Food and beverages

-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 
select `Product line`,
       case 
           when SUM(Total) > (select avg(sum(Total))  from (select sum(Total) as line_total 
                                    from amazon 
                                    group by `Product line`) as subquery) 
           then 'Good' 
           else 'Bad' 
       end as SalesPerformance
from amazon
group by `Product line`;


-- Identify the branch that exceeded the average number of products sold.
select branch, sum(quantity) as TotalQuantity
from amazon
group by branch
having sum(quantity) > (
    select avg(TotalQuantity)
    from (
        select SUM(quantity) as TotalQuantity
        from amazon
        group by branch
    ) as greater
); -- Branch A 

-- Which product line is most frequently associated with each gender?
select Gender, `Product line`, count(*) as Frequency
from amazon
group by Gender, `Product line`
order by  Frequency desc; -- Electronic accessories

select Gender, count(*) as Frequency
from amazon
group by Gender
order by  Frequency desc;

-- Calculate the average rating for each product line.

select `Product line`, avg(Rating) as AverageRating
from amazon
group by `Product line`;

-- Count the sales occurrences for each time of day on every weekday.
select dayname, timeofday, count(*) as SalesOccurrences
from amazon
where dayname not in ('Sat', 'Sun')
group by dayname, timeofday
order by dayname, timeofday;

-- Identify the customer type contributing the highest revenue.
select `Customer type`, sum(Total) as TotalRevenue
from amazon
group by `Customer type`
order by TotalRevenue desc
limit 1; -- Member

-- Determine the city with the highest VAT percentage.
select City, sum(`Tax 5%`) / sum(Total) * 100 as VATPercentage
from amazon
group by City
order by VATPercentage desc
limit 1; -- Mandalay

-- Identify the customer type with the highest VAT payments.
select `Customer type`, sum(`Tax 5%`) as TotalVAT
from amazon
group by `Customer type`
order by TotalVAT desc
limit 1; -- Member

-- What is the count of distinct customer types in the dataset?
select count(distinct `Customer type`) as DistinctCustomerTypes
from amazon; -- 2 customer types

-- What is the count of distinct payment methods in the dataset?
select count(distinct Payment) as DistinctPaymentMethods
from amazon; -- 3 payment types

-- Which customer type occurs most frequently?
select `Customer type`, count(*) as Frequency
from amazon
group by `Customer type`
order by Frequency desc
limit 1; -- Member

-- Identify the customer type with the highest purchase frequency.
select `Customer type`, count(*) as PurchaseFrequency
from amazon
group by `Customer type`
order by PurchaseFrequency desc
limit 1; -- Member

-- Determine the predominant gender among customers.
select Gender, count(*) as Frequency
from amazon
group by Gender
order by Frequency DESC
limit 1; -- Female

-- Examine the distribution of genders within each branch.
select Branch, Gender, count(*) as Frequency
from amazon
group by Branch, Gender
order by Branch, Gender;

-- Identify the time of day when customers provide the most ratings.
select timeofday, count(Rating) as RatingCount
from amazon
group by timeofday
order by RatingCount desc
limit 1; -- Afternoon

-- Determine the time of day with the highest customer ratings for each branch.
select Branch, timeofday, avg(Rating) as AverageRating
from amazon
group by Branch, timeofday
order by Branch, AverageRating desc; -- A - Afternoon, B - Morning, C - Afternoon

-- Identify the day of the week with the highest average ratings.
select dayname, avg(Rating) as AverageRating
from amazon
group by dayname
order by AverageRating desc
limit 1; -- Monday

-- Determine the day of the week with the highest average ratings for each branch.
select Branch, dayname, avg(Rating) as AverageRating
from amazon
group by Branch, dayname
order by branch, AverageRating desc; -- A - Friday, B - Monday, C - Friday



































 
