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


CREATE VIEW resultParties2 AS
SELECT country.name, resultParties1.winners, party_family.family
FROM resultParties1
-- JOIN country ON country.id = resultParties1.country_id;
JOIN party_family ON party_family.party_id = resultParties1.winners;


CREATE VIEW resultParties3 AS
SELECT
FROM
    (SELECT resultParties2.name, winners, family, election_id
    FROM resultParties2, winningParty
    WHERE resultParties2.winners = winningParty.party_id) temp2
