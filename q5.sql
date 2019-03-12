SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q5;
CREATE TABLE q5(
	countryName VARCHAR(50) NOT NULL,
	year INT,
	participationRatio REAL
);

-- Elections from 2001 to 2016
DROP VIEW IF EXISTS in_range;
CREATE VIEW in_range AS
SELECT id AS election_id, country_id,
	EXTRACT(YEAR FROM e_date) AS year,
	CAST(votes_cast AS REAL) / electorate AS r
FROM election
WHERE EXTRACT(YEAR FROM e_date) >= 2001 AND
	EXTRACT(YEAR FROM e_date) <= 2016 AND
	votes_cast IS NOT NULL;

-- Average ratio per year per country
DROP VIEW IF EXISTS avg_ratio;
CREATE VIEW avg_ratio AS
SELECT country_id, year, AVG(r) AS ratio
FROM in_range
GROUP BY country_id, year;

-- Non monotonic countries
DROP VIEW IF EXISTS non_mono;
CREATE VIEW non_mono AS
SELECT a1.country_id
FROM avg_ratio a1, avg_ratio a2
WHERE a1.country_id = a2.country_id AND
	a1.year < a2.year AND a1.ratio > a2.ratio;

-- Monotonic countries
DROP VIEW IF EXISTS non_decrease;
CREATE VIEW non_decrease AS
(
	SELECT DISTINCT country_id
	FROM avg_ratio
) EXCEPT (
	SELECT DISTINCT country_id
	FROM non_mono
);

-- Monotonic country infos
DROP VIEW IF EXISTS non_decrease_ratio;
CREATE VIEW non_decrease_ratio AS
SELECT a.country_id, year, ratio
FROM avg_ratio a, non_decrease n
WHERE a.country_id = n.country_id;

-- Append correct parameters
DROP VIEW IF EXISTS answer;
CREATE VIEW answer AS
SELECT c.name AS countryName, year, ratio AS participationRatio
FROM country c, non_decrease_ratio n
WHERE c.id = n.country_id;

INSERT INTO q5 (
	SELECT *
	FROM answer
);

DROP VIEW IF EXISTS answer;
DROP VIEW IF EXISTS non_decrease_ratio;
DROP VIEW IF EXISTS non_decrease;
DROP VIEW IF EXISTS non_mono;
DROP VIEW IF EXISTS avg_ratio;
DROP VIEW IF EXISTS in_range;
