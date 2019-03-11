SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q2;
CREATE TABLE q2(
	countryName VARCHAR(50) NOT NULL,
	partyName VARCHAR(100) NOT NULL,
	partyFamily VARCHAR(50) NOT NULL,
	stateMarket REAL
);

-- Find cabinets in time range, append country to it.
-- DROP VIEW IF EXISTS recentCabinet;
CREATE VIEW recentCabinet AS
SELECT country_id, id AS cabinet_id
FROM cabinet
WHERE EXTRACT(YEAR FROM start_date) > 1996;

-- Find involvement information in the range.
-- DROP VIEW IF EXISTS recentInfo;
CREATE VIEW recentInfo AS
SELECT c.party_id, c.cabinet_id, r.country_id
FROM cabinet_party c JOIN recentCabinet r
	ON c.cabinet_id = r.cabinet_id;

-- For each party in range, if cabinets from corresponding
-- country minus party involved cabinets is empty, then
-- party is commited party.
-- DROP VIEW IF EXISTS committedParty;
CREATE VIEW committedParty AS
SELECT DISTINCT i.party_id
FROM recentInfo i
WHERE NOT EXISTS (
	SELECT DISTINCT i1.cabinet_id
	FROM recentInfo i1
	WHERE i1.country_id = i.country_id
	EXCEPT
	SELECT DISTINCT i2.cabinet_id
	FROM recentInfo i2
	WHERE i2.country_id = i.country_id AND
		i2.party_id = i.party_id
);

-- Get party name and country name.
-- DROP VIEW IF EXISTS withName;
CREATE VIEW withName AS
SELECT cp.party_id,
	c.name AS countryName,
	p.name AS partyName
FROM committedParty cp, party p, country c
WHERE cp.party_id = p.id AND
	p.country_id = c.id;

-- Get state market.
-- DROP VIEW IF EXISTS answer;
CREATE VIEW answer AS
SELECT n.countryName,
	n.partyName,
	p.state_market AS stateMarket
FROM withName n LEFT JOIN party_position p
	ON n.party_id = p.party_id;

INSERT INTO q2 (
	SELECT *
	FROM answer
);

DROP VIEW IF EXISTS answer;
DROP VIEW IF EXISTS withName;
DROP VIEW IF EXISTS committedParty;
DROP VIEW IF EXISTS recentInfo;
DROP VIEW IF EXISTS recentCabinet;
