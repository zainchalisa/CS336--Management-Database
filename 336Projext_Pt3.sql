#a) The sum of votes for Trump and Biden cannot be larger than totalvotes
Select if (NOT EXISTS (Select * FROM Penna WHERE Biden + Trump > totalvotes) , 'True', 'False') as Outcome;

#b) There cannot be any tuples with timestamps later than Nov 11 and earlier than Nov3
Select if (NOT EXISTS (Select * FROM Penna WHERE timestamp <  '2020-11-03%' and timestamp > '2020-11-11%') , 'True', 'False') as Outcome;

#c) Totalvotes for any precinct and at any timestamp T > 2020-11-05 00:00:00, will be smaller than totalvotes  at T’<T but T’>2020-11-05 00:00:00 for that precinct. 
Select if (NOT EXISTS( Select * FROM Penna lesser, Penna great 
WHERE lesser.timestamp like '2020-11-05%' and great.timestamp like '2020-11-05%' 
and lesser.timestamp < great.timestamp 
and lesser.totalvotes > great.totalvotes 
and lesser.precinct = great.precinct), 'True', 'False') as Outcome;

