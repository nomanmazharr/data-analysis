USE case_study;

# DATA cleaning using sql
SELECT * FROM laptop;

# CREATING backup of our dataset

CREATE TABLE IF NOT EXISTS laptop_backup;
INSERT INTO laptop_backup SELECT * FROM laptop;

# Retreiving backup table
SELECT * FROM laptop_backup;
SELECT COUNT(*) FROM laptop;

#This tells us about columns in data and datatyopes
DESCRIBE laptop;

# Gives us storage/space taken by a table in kilobytes
SELECT DATA_LENGTH/1024 FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'case_study' AND TABLE_NAME = 'laptop';


# After size we need to drop Null values from the table as
# To check if there are any NULL values in the data
SELECT `index`,COUNT(*) FROM laptop WHERE company IS NOT NULL;
# This is just to show that in this way we can del multiple null values if we give those columns who has null values 
DELETE FROM LAPTOP WHERE `index` IN (
SELECT `index` FROM laptop WHERE `index`= '1302' );


# Changing inches till one decimal place and two digits before decimal, it adjust data with its own choice if format does not match
ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1) ;
SELECT Inches FROM laptop;

# This will update resutl for corresponding row in outer table
UPDATE laptop l1 SET Ram = (
SELECT REPLACE (Ram,'GB','') FROM laptop l2 WHERE l1.index = l2.index);
ALTER TABLE laptop MODIFY RAM INTEGER;
DESCRIBE laptop;

# updating weight by dropping units
UPDATE laptop t1 SET Weight = 
(SELECT REPLACE(Weight,'kg','') FROM laptop t2 WHERE t1.index = t2.index ) ;
ALTER TABLE laptop MODIFY COLUMN Weight INTEGER;

# Removing decimal values from price column
UPDATE laptop l1 SET Price=(
SELECT ROUND(Price) FROM laptop l2 WHERE l1.index = l2.index );
ALTER TABLE laptop MODIFY COLUMN Price INTEGER;


# Storage for the table has been decreased as we have put column into their correct datatype
SELECT DATA_LENGTH/1024 FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'case_study' AND TABLE_NAME ='laptop';


SELECT DISTINCT(Opsys) FROM laptop;
UPDATE laptop SET Opsys = 'N/A' WHERE Opsys = 'No OS'; 

# Adding Columns into data
ALTER TABLE laptop 
ADD COLUMN gpu_brand VARCHAR(255) AFTER gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;


# Updating GPU brand
UPDATE laptop l1 SET gpu_brand = (
SELECT SUBSTRING_INDEX(Gpu,' ',1) FROM laptop l2 WHERE l1.index = l2.index);

# Updating GPU name
UPDATE laptop l1 SET gpu_name = (
SELECT substring_index(Gpu,gpu_brand,-1) FROM laptop l2 WHERE l1.index = l2.index);

# Now drop original gpu column
ALTER TABLE laptop DROP COLUMN Gpu;

# Adding multiple columns for CPU
ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

# Updating all cpu columns that we made
UPDATE laptop l1
SET cpu_brand = (
SELECT SUBSTRING_INDEX(Cpu,' ',1) FROM laptop l2 WHERE l1.index = l2.index);

# Firstly we will take string till 3rd index then we will break it further and take last two index
UPDATE laptop l1 SET cpu_name = (
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(Cpu,' ' ,3), ' ',-2) 
FROM laptop l2 WHERE l1.index = l2.index);

UPDATE laptop l1 SET cpu_speed = (
SELECT SUBSTRING_INDEX(Cpu,' ',-1) FROM laptop l2 WHERE l1.index=l2.index);

# Drop original Cpu column
ALTER TABLE laptop DROP COLUMN Cpu;

# Adding column for screen resolution
ALTER TABLE laptop 
ADD COLUMN screen_Resolution_Width INTEGER AFTER ScreenResolution,
ADD COLUMN screen_Resolution_Height INTEGER AFTER Screen_Resolution_Width;

# updating height and width columns
UPDATE laptop l1 SET screen_Resolution_Width = (
SELECT SUBSTRING_Index(SUBSTRING_Index(ScreenResolution,' ',-1),'x',1) 
FROM laptop l2 WHERE l1.index = l2.index);

UPDATE laptop l1 SET screen_Resolution_Height =(
SELECT SUBSTRING_Index(SUBSTRING_Index(ScreenResolution,' ',-1),'x',-1) 
FROM laptop l2 WHERE l1.index= l2.index);

# adding and updating touchscreen column
ALTER TABLE laptop 
ADD COLUMN touchscreen INTEGER AFTER screen_Resolution_Height;
UPDATE laptop SET touchscreen=ScreenResolution LIKE '%Touch%';

# Dropping original column
ALTER TABLE laptop DROP COLUMN ScreenResolution;


ALTER TABLE laptop 
ADD COLUMN memory_type VARCHAR(255) AFTER memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

SELECT Memory,
CASE  
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%SSD%' Then 'SDD'
WHEN Memory LIKE '%FLASH STORAGE%' THEN 'FLASH STORAGE' 
WHEN Memory LIKE 'SSD' AND Memory LIKE 'HDD' THEN "Hybrid"
WHEN Memory LIKE 'Hybrid' THEN 'Hybrid'
WHEN Memory LIKE 'FLASH STORAGE' AND Memory LIKE 'HDD' THEN 'Hybrid'
ELSE NULL
END AS 'memory_type'
FROM laptop;

UPDATE laptop SET memory_type =
CASE
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKe '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%Flash Storage%' THEN 'FLASH STORAGE'
WHEN MEMORY LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
END;


SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN 
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptop;

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' 
THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT 
primary_storage,
CASE WHEN primary_storage <= 2 THEN 
primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN
 secondary_storage*1024 ELSE secondary_storage END
 FROM laptop;

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 
THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 
THEN secondary_storage*1024 ELSE secondary_storage END;

ALTER TABLE laptop DROP COLUMN Memory;

SELECT memory FROM laptop; 
SELECT * FROM laptop;