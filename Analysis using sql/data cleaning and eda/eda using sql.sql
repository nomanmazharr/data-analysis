USE case_study;

# Performing eda on the data

# To see top 5 rows from data 
SELECT * FROM laptop ORDER BY `Index` LIMIT 5;

# To see bottom 5 rows from data
SELECT * FROM laptop ORDER BY `Index` DESC LIMIT 5;

# to select any random rows or sample from data
SELECT * FROM laptop ORDER BY rand() LIMIT 7;

# calculating mean,max,min,count and quartiles of numerical column
SELECT  count(Price) OVER(),
		MIN(Price) OVER(),
        MAX(Price) OVER(),
		AVG(PRICE) OVER(),
        STD(Price) OVER(),
		PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'q1',
        PERCENTILE_DISC(0.50) WITHIN GROUP(ORDER BY Price) OVER() AS 'q2',
        PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'q3'
 FROM laptop;
 
 # THERE are no null/missing values in the data so we do not need to compare all column
 SELECT * FROM laptop WHERE Company IS NULL;
 SELECT  COUNT(Price) FROM laptop WHERE Price IS NULL;
 
 # Finding outliers in the data
 # q1 - (1.5(q3-q1))  ---> for lower quartile
 # q3 + (1.5*(q3-q1)) ---> for upper quartie

SELECT * FROM (
SELECT *,
PERCENTILE_DISC(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS q1,
PERCENTILE_DISC(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS q3
FROM laptop) t
WHERE t.Price < t.q1 - (1.5*(t.q3-t.q1)) OR t.Price > t.q3 +  (1.5*(t.q3-t.q1)); 
 
 # working as a histogram
 # To check ranges of our prices we firstly divide them in buckets then take those bucket in count of 5 and repeat them using *
 SELECT t.buckets,REPEAT('*',COUNT(*)/5),COUNT(*) FROM (
 SELECT Price,
 CASE 
 WHEN Price BETWEEN 0 AND 25000 THEN '0-25k'
 WHEN Price BETWEEN 25000 AND 50000 THEN '25-50K'
 WHEN Price BETWEEN 50000 AND 75000 THEN '50K-75K'
 WHEN Price BETWEEN 75000 AND 100000 THEN '75K-100K'
 ELSE '>100K'
END AS 'buckets'
FROM laptop) t
GROUP BY t.buckets;


# Total companies in data
SELECT Company,COUNT(Company) FROM laptop GROUP BY Company;
 
 # companies having touchscreen product and their quantity
SELECT Company, COUNT(*) AS total_products,
SUM(CASE WHEN touchscreen =  1 THEN 1 ELSE 0 END) AS 'touchscreen_yes',
SUM(CASE WHEN touchscreen = 0 THEN 1 ELSE 0 END) AS 'touchscreen_no'
FROM laptop GROUP BY Company;

SELECT DISTINCT(cpu_brand) FROM laptop;

# products and their cpu_brand with quantity
SELECT Company,COUNT(*),
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'Intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'AMD',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'Samsung'
FROM laptop GROUP BY Company;

# companies and their numerical analysis
SELECT Company,AVG(Price), MIN(Price),MAX(Price),MIN(Price),COUNT(Price),STD(Price)
FROM laptop GROUP BY Company;


# Setting null values in the data so we can fill them 
UPDATE laptop SET Price = NULL
WHERE `Index` IN (5,10,100,200,500,900,1000,400,1200,1100);

SELECT * FROM laptop WHERE Price IS NULL;

# Filling NULL values with AVG(price) from laptop
UPDATE laptop SET Price = (SELECT AVG(Price) FROM laptop) 
WHERE Price IS NULL;
-- 2nd way to fill NULL values
UPDATE laptop l1 
SET Price = (SELECT AVG(Price) FROM laptop l2 WHERE l2.Company = l1.Company) WHERE Price IS NULL; 

SELECT `Index`,Price FROM laptop WHERE `Index` IN (5,10,100,200,500,900,1000,400,1200,1100);

ALTER TABLE laptop ADD COLUMN PPI INTEGER;

UPDATE laptop 
SET PPI = ROUND(SQRT(screen_Resolution_Width*screen_Resolution_Width + 
screen_Resolution_Height * screen_Resolution_Height)/Inches);

ALTER TABLE laptop ADD COLUMN screen_size VARCHAR(255);
UPDATE laptop 
SET screen_size = 
CASE 
WHEN Inches < 14 THEN 'Small'
WHEN Inches >=14 AND Inches <= 17 THEN 'Medium'
ELSE 'Large'
END; 

SELECT screen_size,AVG(Price) FROM laptop GROUP BY screen_size;

-- ONE hot encoding ---> We can update column when we need it in numerical form as we have make categories in it,
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END  AS 'Intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END AS 'Nvidia',
CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END AS 'arm'
FROM laptop;

SELECT * FROM laptop WHERE gpu_brand = 'arm';