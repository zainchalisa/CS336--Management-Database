CREATE PROCEDURE API1 (IN Candidate_Val TEXT, IN theTime TEXT, IN Precinct_Val TEXT)
BEGIN
Select Candidate_Val
FROM Penna
WHERE Timestamp = theTime and precinct = Precinct_Val;
END

