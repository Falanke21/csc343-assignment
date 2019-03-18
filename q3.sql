SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q3 CASCADE;


CREATE TABLE q3(
    -- name of the country
    countryName VARCHAR(50) references country(name),
    -- name of the party
    partyName VARCHAR(100) NOT NULL,
    -- name of the family of a party
    partyFamily VARCHAR(50) NOT NULL,
    -- number of elections the party has won
    wonElections INT NOT NULL,
    -- The id of the election that was most recently won by this party
    mostRecentlyWonElectionId INT REFERENCES election(id),
    -- the year of the election that was most recently won by this party
    mostRecentlyWonElectionYear INT NOT NULL
);

-- views
DROP VIEW IF EXISTS winningParty CASCADE;
DROP VIEW IF EXISTS partyToCountWins CASCADE;
DROP VIEW IF EXISTS averages CASCADE;
DROP VIEW IF EXISTS resultParties1 CASCADE;
DROP VIEW IF EXISTS resultParties2 CASCADE;
DROP VIEW IF EXISTS resultParties3 CASCADE;
DROP VIEW IF EXISTS resultParties4 CASCADE;
DROP VIEW IF EXISTS resultParties5 CASCADE;
DROP VIEW IF EXISTS resultParties6 CASCADE;

-- find the winning party of each election
CREATE VIEW winningParty AS
SELECT election_result.election_id, party_id, votes
FROM election_result,
    (SELECT election_id, MAX(votes)
    FROM election_result
    GROUP BY election_id) winningVotes
WHERE election_result.election_id = winningVotes.election_id
AND election_result.votes = winningVotes.max
ORDER BY party_id;

-- party_id and each party's win times
CREATE VIEW partyToCountWins AS
SELECT party_id, COUNT(votes)
FROM winningParty
GROUP BY party_id
ORDER BY party_id;

-- average winning times associated with each country
CREATE VIEW averages AS
SELECT country_id, AVG(count)
FROM partyToCountWins, party
WHERE partyToCountWins.party_id = party.id
GROUP BY country_id
ORDER BY country_id;

-- the parties that we want
CREATE VIEW resultParties1 AS
SELECT averages.country_id, temp.id AS winners
FROM averages,
    (SELECT country_id, party.id, count
    FROM partyToCountWins JOIN party
    ON partyToCountWins.party_id = party.id) temp
WHERE averages.country_id = temp.country_id
AND temp.count - averages.avg > 3;

-- add party family
CREATE VIEW resultParties2 AS
SELECT resultParties1.country_id, resultParties1.winners, party_family.family
FROM resultParties1
LEFT JOIN party_family ON party_family.party_id = resultParties1.winners;

-- add won elections number
CREATE VIEW resultParties3 AS
SELECT resultParties2.country_id, resultParties2.winners, resultParties2.family,
partyToCountWins.count AS win_elec_num
FROM resultParties2 JOIN partyToCountWins
ON resultParties2.winners = partyToCountWins.party_id;

-- add mostRecentlyWonElectionYear
CREATE VIEW resultParties4 AS
SELECT resultParties3.country_id, resultParties3.winners, resultParties3.family,
resultParties3.win_elec_num, max(EXTRACT(YEAR from election.e_date)) as most_recent_year
FROM resultParties3, winningParty, election
WHERE resultParties3.winners = winningParty.party_id
AND election.id = winningParty.election_id
GROUP BY resultParties3.country_id, resultParties3.family,
resultParties3.win_elec_num, election.id, resultParties3.winners;

-- add mostRecentlyWonElectionId
CREATE VIEW resultParties5 AS
SELECT resultParties4.country_id, resultParties4.winners, resultParties4.family,
resultParties4.win_elec_num, election.id AS election_id, resultParties4.most_recent_year
FROM resultParties4, election
WHERE resultParties4.most_recent_year = EXTRACT(YEAR from election.e_date)
AND resultParties4.country_id = election.country_id;

-- add country name and party name
CREATE VIEW resultParties6 AS
SELECT country.name AS countryName, party.name AS partyName,
resultParties5.family AS partyFamily, resultParties5.win_elec_num AS wonElections,
resultParties5.election_id AS mostRecentlyWonElectionId,
resultParties5.most_recent_year AS mostRecentlyWonElectionYear
FROM resultParties5, country, party
WHERE country.id = resultParties5.country_id
AND party.id = resultParties5.winners
ORDER BY countryName, wonElections, partyName DESC;


insert into q3 (countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear)
SELECT *
FROM resultParties6;

DROP VIEW IF EXISTS winningParty CASCADE;
DROP VIEW IF EXISTS partyToCountWins CASCADE;
DROP VIEW IF EXISTS averages CASCADE;
DROP VIEW IF EXISTS resultParties1 CASCADE;
DROP VIEW IF EXISTS resultParties2 CASCADE;
DROP VIEW IF EXISTS resultParties3 CASCADE;
DROP VIEW IF EXISTS resultParties4 CASCADE;
DROP VIEW IF EXISTS resultParties5 CASCADE;
DROP VIEW IF EXISTS resultParties6 CASCADE;
