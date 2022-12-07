# PART 2
# 2.1

CREATE TABLE newPenna2(
	precinct varchar(255),
	timestamp datetime,
    new_votes int, 
    new_biden int, 
    new_trump int
);

DROP TABLE IF EXISTS newPenna2;

Select * from newPenna2;

DELIMITER //
CREATE PROCEDURE newPenna()
theProd: BEGIN

# logic for this is that you select a precinct and then iterate through all the available timestamps for that precinct updating the rows comparing to the last value

    
    DECLARE last_votes int DEFAULT 0;
    DECLARE last_biden int DEFAULT 0;
    DECLARE last_trump INT DEFAULT 0;
    DECLARE last_timestamp datetime;
    DECLARE itVal INT DEFAULT 0;
    DECLARE the_precinct varchar(255);
    
    DECLARE done1 INT DEFAULT 0;
    
    DECLARE precinctCursor CURSOR FOR Select distinct precinct FROM Penna;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = 1;
    
	OPEN precinctCursor;
    
    thePrecinct: LOOP
    FETCH precinctCursor INTO the_precinct;
	
    IF done1 = 1 THEN
            LEAVE thePrecinct;
        END IF;
    
    BLOCK2: BEGIN
    DECLARE curr_timestamp datetime;
	DECLARE curr_precinct varchar(100);
    DECLARE curr_votes INT;
    DECLARE curr_biden INT;
    DECLARE curr_trump INT;
    DECLARE done INT DEFAULT 0;
    
    DECLARE timestampCursor CURSOR FOR Select Timestamp, totalvotes, biden, trump FROM Penna WHERE precinct = the_precinct ORDER BY TIMESTAMP asc;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN timestampCursor;
	theLoop: LOOP
    
        
        FETCH timestampCursor INTO curr_timestamp, curr_votes, curr_biden, curr_trump;
        
        IF done = 1 THEN
            LEAVE theLoop;
        END IF;
        
		INSERT INTO newPenna2 values(the_precinct, curr_timestamp, curr_votes - last_votes, curr_biden - last_biden, curr_trump - last_trump);
        

        IF last_votes < curr_votes THEN
			SET last_votes = curr_votes;
        END IF;
        
        IF last_biden < curr_biden THEN
			SET last_biden = curr_biden;
        END IF;
        
        IF last_trump < curr_trump THEN
			SET last_trump = curr_trump;
        END IF;
        
	END LOOP theLoop;
		SET last_votes = 0;
        SET last_biden = 0;
        SET last_trump = 0;
        
		
    CLOSE timestampCursor;
    END BLOCK2;
    
    END LOOP thePrecinct;
    CLOSE precinctCursor;
    
END //
DELIMITER ;

call newPenna();

DROP PROCEDURE IF EXISTS newPenna;

SELECT * FROM newPenna2 WHERE precinct = 'Adams Township - Dunlo Voting Precinct';

#2.2

CREATE TABLE switchTable (

	Precinct VARCHAR(255),
    Timestamp DATETIME,
    FromCandidate VARCHAR(255),
    ToCandidate VARCHAR(255)
);

DELIMITER $$
CREATE PROCEDURE Switch()
BEGIN

	DECLARE done INT DEFAULT 0;
    DECLARE done1 INT DEFAULT 0;
    
    
    
    DECLARE max_timestamp DATETIME;
	DECLARE min_timestamp DATETIME;
    DECLARE Overall_Winner VARCHAR(255);
    DECLARE Min_Winner VARCHAR(255);
    DECLARE curr_precinct VARCHAR(255);
    
	DECLARE precinctCursor CURSOR FOR Select distinct Precinct FROM Penna;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    open precinctCursor;
    precinctLoop: LOOP
    
    IF done = 1 THEN
            LEAVE precinctLoop;
        END IF;
        
	FETCH precinctCursor INTO curr_precinct;
    SET min_timestamp = (Select min(timestamp) FROM Penna WHERE timestamp >= max_timestamp - INTERVAL 24 HOUR and precinct = curr_precinct);
	SET max_timestamp = (Select max(timestamp) FROM Penna WHERE Precinct = curr_precinct);
	SET Overall_Winner = (Select if(biden > trump, 'Biden', 'Trump') FROM Penna WHERE timestamp = max_timestamp and precinct = curr_precinct);
    SET min_winner = (Select if(biden > trump, 'Biden', 'Trump') FROM Penna WHERE timestamp = min_timestamp and precinct = curr_precinct);

    IF Overall_winner != min_winner THEN
    timestampBlock: BEGIN
    
    DECLARE curr_biden int;
    DECLARE curr_trump int;
    DECLARE curr_timestamp DATETIME;
    DECLARE curr_winner VARCHAR(255);
    
	DECLARE timestampCursor CURSOR FOR Select timestamp, biden, trump FROM Penna WHERE timestamp >= min_timestamp and precinct = curr_precinct;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = 1;
    
    
    OPEN timestampCursor;
    timestampLoop: LOOP
    
    FETCH timestampCursor INTO curr_timestamp, curr_biden, curr_trump;
    
    IF done1 = 1 THEN
            LEAVE timestampLoop;
        END IF;
    
    SET curr_winner = (Select if(curr_biden > curr_trump, 'Biden', 'Trump') FROM Penna WHERE timestamp = curr_timestamp and precinct = curr_precinct);
    
    IF curr_winner != min_winner THEN
		INSERT INTO switchTable value (curr_precinct, curr_timestamp, min_winner, curr_winner);
    END IF;
    
        
	END LOOP timestampLoop;
    CLOSE timestampCursor;
    
    END timestampBlock;
    END IF;
    END LOOP precinctLoop;
    CLOSE precinctCursor;
    
END $$
DELIMITER ;

call Switch();

DROP PROCEDURE IF EXISTS Switch;

Select * FROM switchTable;

(Select max(timestamp) FROM Penna WHERE Precinct = 'Adams Township - Dunlo Voting Precinct');









