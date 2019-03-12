SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q6;
CREATE TABLE q6(
	countryName VARCHAR(50) NOT NULL,
	r0_2 INT,
	r2_4 INT,
	r4_6 INT,
	r6_8 INT,
	r8_10 INT
);

DROP VIEW IF EXISTS countries;
CREATE VIEW countries AS
SELECT DISTINCT id
FROM country;

DROP VIEW IF EXISTS range1;
CREATE VIEW range1 AS
SELECT p.country_id, pp.left_right AS position
FROM party_position pp, party p
WHERE pp.party_id = p.id AND
	pp.left_right >= 0.0 AND
	pp.left_right < 2.0;

DROP VIEW IF EXISTS range2;
CREATE VIEW range2 AS
SELECT p.country_id, pp.left_right AS position
FROM party_position pp, party p
WHERE pp.party_id = p.id AND
	pp.left_right >= 2.0 AND
	pp.left_right < 4.0;

DROP VIEW IF EXISTS range3;
CREATE VIEW range3 AS
SELECT p.country_id, pp.left_right AS position
FROM party_position pp, party p
WHERE pp.party_id = p.id AND
	pp.left_right >= 4.0 AND
	pp.left_right < 6.0;

DROP VIEW IF EXISTS range4;
CREATE VIEW range4 AS
SELECT p.country_id, pp.left_right AS position
FROM party_position pp, party p
WHERE pp.party_id = p.id AND
	pp.left_right >= 6.0 AND
	pp.left_right < 8.0;

DROP VIEW IF EXISTS range5;
CREATE VIEW range5 AS
SELECT p.country_id, pp.left_right AS position
FROM party_position pp, party p
WHERE pp.party_id = p.id AND
	pp.left_right >= 8.0 AND
	pp.left_right <= 10.0;

DROP VIEW IF EXISTS withr1;
CREATE VIEW withr1 AS
SELECT c.id,
	COUNT(r.position) AS r0_2
FROM countries c LEFT JOIN range1 r
	ON c.id = r.country_id
GROUP BY c.id;

DROP VIEW IF EXISTS withr2;
CREATE VIEW withr2 AS
SELECT c.id, c.r0_2,
	COUNT(r.position) AS r2_4
FROM withr1 c LEFT JOIN range2 r
	ON c.id = r.country_id
GROUP BY c.id, c.r0_2;

DROP VIEW IF EXISTS withr3;
CREATE VIEW withr3 AS
SELECT c.id, c.r0_2, c.r2_4,
	COUNT(r.position) AS r4_6
FROM withr2 c LEFT JOIN range3 r
	ON c.id = r.country_id
GROUP BY c.id, c.r0_2, c.r2_4;

DROP VIEW IF EXISTS withr4;
CREATE VIEW withr4 AS
SELECT c.id, c.r0_2, c.r2_4, c.r4_6,
	COUNT(r.position) AS r6_8
FROM withr3 c LEFT JOIN range4 r
	ON c.id = r.country_id
GROUP BY c.id, c.r0_2, c.r2_4, c.r4_6;

DROP VIEW IF EXISTS withr5;
CREATE VIEW withr5 AS
SELECT c.id, c.r0_2, c.r2_4, c.r4_6, c.r6_8,
	COUNT(r.position) AS r8_10
FROM withr4 c LEFT JOIN range5 r
	ON c.id = r.country_id
GROUP BY c.id, c.r0_2, c.r2_4, c.r4_6, c.r6_8;

DROP VIEW IF EXISTS answer;
CREATE VIEW answer AS
SELECT c.name AS countryName,
	w.r0_2, w.r2_4, w.r4_6, w.r6_8, w.r8_10
FROM country c, withr5 w
WHERE c.id = w.id;

INSERT INTO q6 (
	SELECT *
	FROM answer
);

DROP VIEW IF EXISTS answer;
DROP VIEW IF EXISTS withr5;
DROP VIEW IF EXISTS withr4;
DROP VIEW IF EXISTS withr3;
DROP VIEW IF EXISTS withr2;
DROP VIEW IF EXISTS withr1;
DROP VIEW IF EXISTS range5;
DROP VIEW IF EXISTS range4;
DROP VIEW IF EXISTS range3;
DROP VIEW IF EXISTS range2;
DROP VIEW IF EXISTS range1;
DROP VIEW IF EXISTS countries;
