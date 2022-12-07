#4.1

CREATE TABLE newPenna_pt4 AS SELECT * FROM Penna;
CREATE TABLE Updated_Tuples LIKE Penna;
CREATE TABLE Inserted_Tuples LIKE Penna;
CREATE TABLE Deleted_Tuples LIKE Penna;

DROP TABLE newPenna_pt4;
DROP TABLE Updated_Tuples;
DROP TABLE Inserted_Tuples;
DROP TABLE Deleted_Tuples;


# insert trigger
DELIMITER $$ 
CREATE TRIGGER insertTrigger
BEFORE INSERT ON newPenna_pt4 FOR EACH ROW
BEGIN
Insert into Inserted_Tuples values (NEW.ID, NEW.Timestamp, NEW.State, NEW.locality, NEW.Precinct, NEW.GEO, NEW.totalvotes, NEW.Biden, NEW.Trump, NEW.filestamp);
END

$$ DELIMITER ;

# update trigger
DELIMITER $$ 
CREATE TRIGGER updateTrigger
BEFORE UPDATE ON newPenna_pt4 FOR EACH ROW
BEGIN
INSERT Updated_Tuples values (OLD.ID, OLD.Timestamp, OLD.State, OLD.locality, OLD.Precinct, OLD.GEO, OLD.totalvotes, OLD.Biden, OLD.Trump, OLD.filestamp);
END

$$ DELIMITER ;

# delete trigger
DELIMITER $$ 
CREATE TRIGGER deleteTrigger
BEFORE DELETE ON newPenna_pt4 FOR EACH ROW
BEGIN
INSERT Deleted_Tuples values (OLD.ID, OLD.Timestamp, OLD.State, OLD.locality, OLD.Precinct, OLD.GEO, OLD.totalvotes, OLD.Biden, OLD.Trump, OLD.filestamp);
END
$$ DELIMITER ;

# insert test
INSERT into newPenna_pt4 value ('1', '2020-11-04 03:58:36' ,'NJ', 'Middlesex', 'East Brunswick', 'EB TWP', 24, 12, 12, 'filestamp');
INSERT into newPenna_pt4 value ('2', '2020-11-04 03:58:36' ,'NJ', 'Middlesex', 'North Brunswick', 'NB TWP', 36, 24, 12, 'filestamp');
INSERT into newPenna_pt4 value ('3', '2020-11-04 03:58:36' ,'NJ', 'Middlesex', 'South Brunswick', 'SB TWP', 22, 11, 11, 'filestamp');
INSERT into newPenna_pt4 value ('4', '2020-11-04 03:58:36' ,'NJ', 'Middlesex', 'New Brunswick', 'NB TWP', 52, 40, 12, 'filestamp');
INSERT into newPenna_pt4 value ('5', '2020-11-04 03:58:36' ,'NJ', 'Middlesex', 'East Brunswick', 'EB TWP', 2, 1, 1, 'filestamp');
Select * FROM Inserted_Tuples;

# update test
update newPenna_pt4 set geo = 'EB' WHERE locality = 'Middlesex' and precinct = 'East Bruswick';
update newPenna_pt4 set ID = 45 WHERE precinct = 'South Brunswick';
update newPenna_pt4 set ID = 22 WHERE precinct = 'New Brunswick';
update newPenna_pt4 set totalVotes = 5000 WHERE totalVotes = '36' and geo = 'NB TWP';
update newPenna_pt4 set filestamp = 'the filestamp' WHERE locality = 'Middlesex';
Select * FROM Updated_Tuples;

# delete test
Delete from newPenna_pt4 where state = 'NJ';
Select * FROM Deleted_Tuples;

Select * FROM newPenna_pt4 WHERE precinct = 'East Brunswick';


# 4.2
DROP PROCEDURE IF EXISTS MoveVotes;

CREATE TABLE newPenna AS SELECT * FROM Penna;

DROP TABLE newPenna;

DELIMITER $$
CREATE PROCEDURE MoveVotes(Precinct_Val VARCHAR(255), theTime DATETIME, Candidate_Val VARCHAR(255), Number_of_Moved_Votes INT)
theProd: BEGIN

# Error Handling for Precinct
IF (Precinct_Val not in (Select distinct precinct FROM newPenna)) THEN 
SELECT 'Wrong Precinct Name';
LEAVE theProd;
END IF;

#Error Handling for Timestamp
IF (theTime not in (Select timestamp FROM newPenna)) THEN 
Select 'Unknown Timestamp';
LEAVE theProd;
END IF;

#Error Handling for Candidate
IF (Candidate_Val != 'Biden' and Candidate_Val != 'Trump') THEN 
SELECT 'Wrong Candidate';
LEAVE theProd;
END IF;

# Error handling for Number of Votes Moved
IF (Candidate_Val = 'Biden') THEN
	IF (Number_of_Moved_Votes > (Select Biden FROM newPenna WHERE timestamp = theTime and Precinct = Precinct_Val)) THEN
	SELECT 'Not enough votes';
    LEAVE theProd;
	END IF;
END IF;

IF (Candidate_Val = 'Trump') THEN
	IF (Number_of_Moved_Votes > (Select Trump FROM newPenna WHERE timestamp = theTime and Precinct = Precinct_Val)) THEN
	SELECT 'Not enough votes';
    LEAVE theProd;
	END IF;
END IF;

# the query which removes votes from one candidate and adds it to the other
IF (Candidate_Val = 'Biden') THEN
	UPDATE newPenna SET Biden = Biden - Number_of_Moved_Votes, Trump = Trump + Number_of_Moved_Votes
    WHERE precinct = Precinct_Val and timestamp >= theTime;
END IF;

IF (Candidate_Val = 'Trump') THEN
	UPDATE newPenna SET Trump = Trump - Number_of_Moved_Votes, Biden = Biden + Number_of_Moved_Votes
    WHERE precinct = Precinct_Val and timestamp >= theTime;
END IF;


END $$
DELIMITER ;



Select * FROM newPenna WHERE timestamp >= '2020-11-06 15:38:36' and Precinct = 'Red Hill' ORDER BY timestamp asc;

call MoveVotes('Red Hill', '2020-11-06 15:38:36','Trump',10000000); # invalid number of votes (too many votes trying to be moved)
call MoveVotes('East Brunswick', '2020-11-06 15:38:36','Trump',100); # invalid precinct
call MoveVotes('Red Hill', '2020-11-06 15:38:36','Obama',100); # invalid candidate
call MoveVotes('Red Hill', '2020-11-12 15:38:36','Trump',100); # invalid time (times is not in the table *not checking format based off instructions*)
call MoveVotes('Red Hill', '2020-11-06 15:38:36','Trump',100); # valid query


