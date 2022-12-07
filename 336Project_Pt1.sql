# API 1
DELIMITER $$
CREATE PROCEDURE API1 (IN Candidate_Val VARCHAR(255), IN theTime VARCHAR(255), IN Precinct_Val VARCHAR(255))
theProd: BEGIN

	IF((str_to_date(theTime, '%Y-%m-%d %H:%i:%s') is null)) THEN
	Select concat(theTime, '  is not correct format');
    Leave theProd;
    END IF;

	IF(Precinct_Val not in (Select distinct precinct FROM Penna)) THEN 
	Select concat(Precinct_Val, ' is not an valid precinct');
    LEAVE theProd;
	END IF;
    
    IF (Candidate_Val != 'Biden' and Candidate_Val != 'Trump') THEN 
	SELECT concat(Candidate_Val, ' is not an validate candidate');
	LEAVE theProd;
	END IF;

	IF (Candidate_Val = 'Biden' and theTime < (Select min(timestamp) FROM Penna)) THEN
		Select concat(Candidate_Val, ' had 0 votes');
	ELSEIF (Candidate_Val = 'Biden' and theTime > (Select max(timestamp) FROM Penna)) THEN
		Select timestamp, Biden
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna) and precinct = Precinct_Val LIMIT 1;
    ELSEIF (Candidate_Val = 'Biden') THEN
		Select timestamp, Biden
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna where timestamp <= concat(theTime, '%')) and precinct = Precinct_Val LIMIT 1;
	END IF;
    
    
    IF (Candidate_Val = 'Trump' and theTime < (Select min(timestamp) FROM Penna)) THEN
		Select concat(Candidate_Val, ' had 0 votes');
	ELSEIF (Candidate_Val = 'Trump' and theTime > (Select max(timestamp) FROM Penna)) THEN
		Select timestamp, Trump
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna) and precinct = Precinct_Val LIMIT 1;
	ELSEIF (Candidate_Val = 'Trump') THEN
		Select Trump
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna where timestamp <= concat(theTime, '%')) and precinct = Precinct_Val LIMIT 1;
	END IF;
    
END $$
DELIMITER ;

SET @over_max = '2020-12-05 20:50:25';
    
call API1 ('Trump', '12-05-2020 20:50:25', 'LOWER PAXTON TWP--1ST PRECINCT'); # incorrect date format
call API1 ('Trump', '2020-11-05 20:50:25', 'East Brunswick'); # incorrect precinct (not in table)
call API1 ('Obama', '2020-11-05 20:50:25', 'LOWER PAXTON TWP--1ST PRECINCT'); # incorrect candidate value
call API1 ('Trump', '2020-12-05 20:50:25', 'LOWER PAXTON TWP--1ST PRECINCT'); # over max timestamp
call API1 ('Trump', '2019-11-05 20:50:25', 'LOWER PAXTON TWP--1ST PRECINCT'); # under min timestamp
call API1 ('Trump', '2020-11-05 20:50:25', 'LOWER PAXTON TWP--1ST PRECINCT'); # regular query

DROP PROCEDURE IF EXISTS API1;

# API2(date) - Given a date, return the candidate who had the most votes at the last 
# timestamp for this date as well as  how many votes he got. For example the last 
# timestamp for 2020-11-06 will be 2020-11-06 23:51:43.

DELIMITER $$
CREATE PROCEDURE API2 (IN The_Time VARCHAR(255))
theProd: BEGIN

	DECLARE max_timestamp varchar(255);
    SET max_timestamp = (Select max(timestamp) FROM Penna WHERE timestamp like concat(The_Time, '%'));
    
	IF((max_timestamp is null)) THEN
	Select concat(The_Time, '  is not correct format');
    Leave theProd;
    END IF;
    
    
	Select max(timestamp),
	CASE
		WHEN sum(Biden) > sum(Trump) THEN concat('The candidate with the most votes was Biden with ', sum(Biden))
		ELSE concat('The candidate with the most votes was Trump with ', sum(Trump))
		END AS Result
	FROM Penna WHERE timestamp = (Select max(timestamp) FROM Penna WHERE timestamp like concat(The_Time, '%'));
    
    END $$
DELIMITER ;

SET @theTime = '2020-11-06';

call API2('11-11-2020'); #invalid date format
call API2('2020-11-11'); # valid date

DROP PROCEDURE IF EXISTS API2;

Select max(timestamp) FROM Penna WHERE timestamp like concat(11-11-2020, '%');

# API3(candidate) - Given a candidate return top 10 precincts that this candidate win. 
# Order precincts by total votes and list TOP 10 in descending order of totalvotes. 

DELIMITER $$
CREATE PROCEDURE API3 (IN Candidate_Val VARCHAR(255))
theProd: BEGIN

	IF (Candidate_Val != 'Biden' and Candidate_Val != 'Trump') THEN 
	SELECT concat(Candidate_Val, ' is not an validate candidate');
	LEAVE theProd;
	END IF;
    
	IF (Candidate_Val = 'Biden') THEN
		Select precinct
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna) and Biden > Trump
		ORDER BY totalvotes desc LIMIT 10;
	ELSEIF (Candidate_Val = 'Trump') THEN
		Select  precinct
		FROM Penna 
		WHERE timestamp = (Select max(timestamp) FROM Penna) and Trump > Biden
		ORDER BY totalvotes desc LIMIT 10;
	END IF;
END $$
DELIMITER ;

call API3 ('Biden'); #valid candidate
call API3 ('Obama'); # invalid candidate

DROP PROCEDURE IF EXISTS API3;

# API4(precinct) - Given a precinct,  Show who won this precinct (Trump or Biden) as well as what percentage of total votes went to the winner.

DELIMITER $$
CREATE PROCEDURE API4 (IN Precinct_Val VARCHAR(255))
theProd:BEGIN

	IF(Precinct_Val not in (Select distinct precinct FROM Penna)) THEN 
	Select concat(Precinct_Val, ' is not an valid precinct');
    LEAVE theProd;
	END IF;
    
	Select precinct,
	CASE
		WHEN Biden > Trump THEN concat('Biden ', Biden/totalvotes *100, '%')
		ELSE concat('Trump ', Trump/totalvotes *100, '%')
		END AS Result
	FROM Penna
    WHERE precinct = Precinct_Val and timestamp = (Select max(Timestamp) FROM Penna);
END $$
DELIMITER ;

call API4('Red Hill'); # valid precinct
call API4('East Brunswick'); # invalid precinct

DROP PROCEDURE IF EXISTS API4;
    
# API5

DELIMITER $$
CREATE PROCEDURE API5 (IN theString VARCHAR(255))
theProd: BEGIN

	IF(NOT EXISTS (Select distinct precinct FROM Penna where precinct like concat('%', theString, '%'))) THEN 
	Select concat(theString, ' is not a substring of any valid precinct');
    LEAVE theProd;
	END IF;
    
	Select
	CASE
		WHEN sum(Biden) > sum(Trump) THEN concat('The Total Votes for Biden ', sum(Biden))
		ELSE concat('The Total Votes for Trump ', sum(Trump))
		END AS Result
	FROM Penna Where timestamp = (Select max(timestamp) FROM Penna) and precinct like concat('%', theString, '%');
END $$
DELIMITER ;

SET @theString = 'Township';

CALL API5('Township'); # valid substring
CALL API5('Hello'); # invalid substring

DROP PROCEDURE IF EXISTS API5;


