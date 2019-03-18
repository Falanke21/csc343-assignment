SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q3 CASCADE;


CREATE TABLE q3(
    -- name of the country
    countryName VARCHAR(50) references country(name),
    -- name of the party
    partyName VARCHAR(100) NOT NULL,
    -- name of the family of a party
    partyFamily VARCHAR(50),
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
DROP VIEW IF EXISTS winnersAndElections CASCADE;
DROP VIEW IF EXISTS winnersAndMostRecentYear CASCADE;
DROP VIEW IF EXISTS winnersAndElectionsInfo CASCADE;
DROP VIEW IF EXISTS resultParties2 CASCADE;
DROP VIEW IF EXISTS resultParties3 CASCADE;
DROP VIEW IF EXISTS resultParties4 CASCADE;
DROP VIEW IF EXISTS resultParties5 CASCADE;

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

-- FIXING

-- winners and all its associated elections
CREATE VIEW winnersAndElections AS
SELECT winners, election_id
FROM resultParties1 JOIN winningParty
ON resultParties1.winners = winningParty.party_id;

-- winners and its most recent time of won election
CREATE VIEW winnersAndMostRecentYear AS
SELECT winners, MAX(election.e_date) AS most_recent_time
FROM winnersAndElections JOIN election
ON winnersAndElections.election_id = election.id
GROUP BY winners;

-- winners and its most recent TIME of won election, and that election_id
CREATE VIEW winnersAndElectionsInfo AS
SELECT winnersAndMostRecentYear.winners, election.id AS election_id,
winnersAndMostRecentYear.most_recent_time
FROM winnersAndMostRecentYear JOIN election
ON winnersAndMostRecentYear.most_recent_time = election.e_date;

-- winners and its most recent YEAR of won election, and that election_id
CREATE VIEW resultParties2 AS
SELECT resultParties1.country_id, resultParties1.winners,
winnersAndElectionsInfo.election_id,
EXTRACT(YEAR from winnersAndElectionsInfo.most_recent_time) AS year
FROM winnersAndElectionsInfo JOIN resultParties1
ON winnersAndElectionsInfo.winners = resultParties1.winners;

-- add info about how many elections won as wonElections
CREATE VIEW resultParties3 AS
SELECT country_id, winners, election_id, year,
partyToCountWins.count AS wonElections
FROM resultParties2 JOIN partyToCountWins
ON resultParties2.winners = partyToCountWins.party_id;

-- add party family info, notice left join since family could be null
CREATE VIEW resultParties4 AS
SELECT country_id, winners, party_family.family, wonElections, election_id, year
FROM resultParties3 LEFT JOIN party_family
ON winners = party_id;

-- replace party_id and country_id as party name and country name
CREATE VIEW resultParties5 AS
SELECT country.name AS countryName, party.name AS partyName,
family AS partyFamily, wonElections,
election_id AS mostRecentlyWonElectionId,
year AS mostRecentlyWonElectionYear
FROM resultParties4, party, country
WHERE resultParties4.winners = party.id
AND resultParties4.country_id = country.id;


-- FIXING

-- -- ORDER BY countryName, wonElections, partyName DESC


insert into q3 (countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear)
SELECT *
FROM resultParties5;

DROP VIEW IF EXISTS winningParty CASCADE;
DROP VIEW IF EXISTS partyToCountWins CASCADE;
DROP VIEW IF EXISTS averages CASCADE;
DROP VIEW IF EXISTS resultParties1 CASCADE;
DROP VIEW IF EXISTS winnersAndElections CASCADE;
DROP VIEW IF EXISTS winnersAndMostRecentYear CASCADE;
DROP VIEW IF EXISTS winnersAndElectionsInfo CASCADE;
DROP VIEW IF EXISTS resultParties2 CASCADE;
DROP VIEW IF EXISTS resultParties3 CASCADE;
DROP VIEW IF EXISTS resultParties4 CASCADE;
DROP VIEW IF EXISTS resultParties5 CASCADE;
