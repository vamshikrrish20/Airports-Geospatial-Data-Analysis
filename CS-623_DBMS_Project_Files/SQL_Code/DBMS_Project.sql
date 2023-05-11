/* Creating PostGis extension */
CREATE EXTENSION postgis;

/* Creating AIRPORTS table */
CREATE TABLE airports (
	id INTEGER,
	ident VARCHAR(10),
	type VARCHAR(500),
	name VARCHAR(500),
	latitude_deg NUMERIC,
	longitude_deg NUMERIC,
	elevation_ft INTEGER,
	continent VARCHAR(2),
	iso_country VARCHAR(2),
	iso_region VARCHAR(10),
	municipality VARCHAR(255),
	scheduled_service VARCHAR(3),
	gps_code VARCHAR(10),
	iata_code VARCHAR(10),
	local_code VARCHAR(10),
	home_link VARCHAR(500),
	wikipedia_link VARCHAR(500),
	keywords VARCHAR(500)
);

/* Importing data from airports.csv file to airports table, source weblink: https://ourairports.com/help/data-dictionary.html */
COPY airports FROM 'C:\Users\pruth\OneDrive\Desktop\Pace University\Semester 1\DBMS\Project_2\Data\airports.csv' DELIMITER ',' CSV HEADER;


/* Altering table to add geometry column for geometrics analysis */
ALTER TABLE airports ADD COLUMN geom geometry(Point, 4326);
UPDATE airports SET geom = ST_SetSRID(ST_MakePoint(longitude_deg, latitude_deg), 4326);

/* Showing all columns data */
SELECT * FROM airports;

/* Retrieve Locations of specific features:

The type of the airport. Allowed values are "closed_airport", "heliport", "large_airport", 
"medium_airport", "seaplane_base", and "small_airport".

The type to continent using the code for the continent where the airport is (primarily) located. 
Allowed values are "AF" (Africa), "AN" (Antarctica), "AS" (Asia), "EU" (Europe), 
"NA" (North America), "OC" (Oceania), or "SA" (South America).

*/
SELECT name, latitude_deg, longitude_deg, geom
FROM airports 
WHERE type = 'large_airport' AND continent = 'EU' LIMIT 10;

/* Retriving medium_airports from AS(Asia) */
SELECT name, latitude_deg, longitude_deg, geom
FROM airports 
WHERE type = 'medium_airport' AND continent = 'AS' LIMIT 10;

/* 2 Calculate Distance between points 

Finding distance between two airports and also ploting the line joining them 
A.name and B.name can be changed to find diatance b/w any two airports

*/
SELECT ST_AsText(a.geom) AS point_a, ST_AsText(b.geom) AS point_b, ST_MakeLine(a.geom, b.geom) 
AS line_ab, ST_Distance(a.geom::geography, b.geom::geography)/1000 AS distance_km
FROM airports a, airports b
WHERE a.name = 'Total Rf Heliport' and b.name = 'Aero B Ranch Airport';

/* 
3 Calculate Areas of Interest
*/

SELECT iso_region, type, COUNT(*) as count
FROM airports
WHERE iso_region = 'US-CA' -- replace with desired region code
GROUP BY iso_region, type
ORDER BY count DESC;

SELECT iso_region, type, COUNT(*) as count
FROM airports
WHERE iso_region = 'US-IN' -- replace with desired region code
GROUP BY iso_region, type
ORDER BY count ASC;

/* 
4 Analyze the queries
*/

-- TASK 01
EXPLAIN ANALYZE SELECT name, latitude_deg, longitude_deg, geom
FROM airports 
WHERE type = 'large_airport' AND continent = 'EU' LIMIT 10;

-- TASK 02
EXPLAIN ANALYZE SELECT ST_AsText(a.geom) AS point_a, ST_AsText(b.geom) AS point_b, ST_MakeLine(a.geom, b.geom) 
AS line_ab, ST_Distance(a.geom::geography, b.geom::geography)/1000 AS distance_km
FROM airports a, airports b
WHERE a.name = 'Total Rf Heliport' and b.name = 'Aero B Ranch Airport';

-- TASK 03
EXPLAIN ANALYZE SELECT iso_region, type, COUNT(*) as count
FROM airports
WHERE iso_region = 'US-CA' -- replace with desired region code
GROUP BY iso_region, type
ORDER BY count DESC;

/* 
5 Sorting and Limit Executions

To sort the results of a query, you can use the ORDER BY clause followed by the column name(s) to sort by.
For example, to sort the airports table by latitude in descending order, you would use the following query.

*/

SELECT * FROM airports ORDER BY latitude_deg DESC LIMIT 10;

SELECT * FROM airports ORDER BY elevation_ft ASC LIMIT 10;

/* 

6 Optimize the queries to speed up execution time

*/

-- TASK 01
CREATE INDEX airports_type_continent_idx ON airports (type, continent);

-- TASK 02
CREATE INDEX airports_name_idx ON airports (name);

--TASK 03
CREATE INDEX airports_iso_region_idx ON airports (iso_region);

--TASK 04
CREATE INDEX airports_latitude_deg_idx ON airports (latitude_deg);

/* 

7 N-Optimization of queries

*/

CREATE INDEX idx_airports_iso_region ON airports (iso_region); -- Using Index

-- Using subqueries instead of joins
SELECT iso_region, COUNT(*) as count
FROM airports
WHERE iso_region = 'US-CA'
GROUP BY iso_region

-- Avoid using 'SELECT *' instead of selecting all columns from a table
SELECT name, latitude_deg, longitude_deg
FROM airports
WHERE type = 'large_airport' AND continent = 'EU'

-- Use LIMIT to reduce the number of rows returned
SELECT * FROM airports LIMIT 10;