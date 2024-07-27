USE carbon_emi;
SHOW TABLES;

#Create table
CREATE TABLE emi_esti(
Country VARCHAR (50),
Year int (4),
Series varchar(80),
Value FLOAT
);

#imported data
LOAD DATA LOCAL INFILE "C:/Users/dell/Desktop/Emission.csv" INTO TABLE emi_esti
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#Checking my dataset
SELECT * FROM emi_esti;

#Checking if there are any null values in the columns
SELECT * FROM emi_esti
WHERE (Country IS NULL) OR (Year IS NULL) OR (Series IS NULL) OR (Value IS NULL);  
#there are no null values

#deleting records where year id not given
SELECT * FROM emi_esti
WHERE Year = 0;
DELETE FROM emi_esti
WHERE Year = 0;

#checking distinct data in series
SELECT DISTINCT Series FROM emi_esti;
#'Series' column has 2 distinct values

#finding range of column 'Year'
SELECT MIN(Year), MAX(Year) FROM emi_esti;

#finding the range of the column "Value" with different conditions
SELECT MIN(Value), MAX(Value) FROM emi_esti
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)';
SELECT MIN(Value), MAX(Value) FROM emi_esti
WHERE Series = 'Emissions per capita (metric tons of carbon dioxide)';

-- Breaking these two values into two different tables so that I can work with them easier
#Creating a new table called 'emissions' for the series 'Emissions (thousand metric tons of carbon dioxide)'
CREATE TABLE Emissions(
Country VARCHAR (50),
Year int (4),
Series varchar(80),
Value FLOAT
);

INSERT INTO Emissions
SELECT * FROM emi_esti 
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)';

SELECT * FROM Emissions;

#Creating a new table called 'perCapital' for the series 'Emissions per capita (metric tons of carbon dioxide)'
CREATE TABLE perCapital(
Country VARCHAR (50),
Year int (4),
Series varchar(80),
Value FLOAT
);

INSERT INTO perCapital
SELECT * FROM emi_esti
WHERE Series = 'Emissions per capita (metric tons of carbon dioxide)';

SELECT * FROM perCapital;

-- I want to find the data about only India
-- I will analyze only perCapital table
SELECT * FROM perCapital
WHERE Country = 'India';

#finding the min and max value of Carbon Emissions per capital in India
SELECT MIN(Value), MAX(Value) FROM perCapital
WHERE Country = 'India';
#The min value is 0.35 and the max value is 1.614

SELECT Year, Value FROM perCapital
WHERE Country = 'India'
ORDER BY Value ASC
LIMIT 1;                             # Min emission value is in year 1975

SELECT Year, Value FROM perCapital
WHERE Country = 'India'
ORDER BY Value DESC
LIMIT 1;                             # Max emission value is in year 2017

-- change of emissions per capital in 2017 compared to the changes of emissions per capital in 1975
With Value_2017 AS (SELECT Country, Value AS New_Value
FROM perCapital
WHERE Year = 2017),
Value_1975 AS (SELECT Country, Value AS Old_value
FROM perCapital
WHERE Year = 1975)
SELECT DISTINCT perCapital.Country, ROUND((Value_2017.New_Value - Value_1975.Old_Value)/Value_1975.Old_Value,2) AS emi_changes 
FROM Value_1975
INNER JOIN Value_2017 ON Value_1975.Country = Value_2017.Country
INNER JOIN perCapital ON Value_1975.Country = perCapital.Country
ORDER BY emi_changes DESC;
-- Oman is the country that has the highest rate of increasing, which is 16.25 
-- Dem. People's Rep. Korea has the lowest rate of decreasing, which is -0.84


-- Now I will analyze only Emissions table
-- I want to find the data about only India
SELECT * FROM Emissions;

#I want want to know the min and max value of India
SELECT * FROM Emissions
WHERE Country = 'India';

SELECT MIN(Value), MAX(Value) FROM Emissions
WHERE Country = 'India';
#The min value is 217194 and the max value is 2161570

SELECT Year, Value FROM Emissions
WHERE Country = 'India'
ORDER BY Value ASC
LIMIT 1;                        # Min emission value is in year 1975

SELECT Year, Value FROM Emissions
WHERE Country = 'India'
ORDER BY Value DESC
LIMIT 1;                             # Max emission value is in year 2017

-- finally, I want to find out which 5 countries have the highest amount of carbon emissions
SELECT Country, Sum(Value) as Sum_Value FROM Emissions
GROUP BY Country
ORDER BY Sum_Value DESC
LIMIT 5;                                   #China, USA, India, Russia, Japan