# 1. Bars which sell at least one beer liked by a resident of Edison

Select distinct bar FROM Sells, Likes, 
(Select name FROM Drinker WHERE city = 'Edison')dc 
WHERE Likes.drinker = dc.name and Likes.beer = Sells.beer; 

# 2. Beers which are liked by Mike and by Devarsh

Select * FROM Likes;

Select distinct db.beer FROM 
(Select beer FROM Likes WHERE drinker = 'Mike') MB, 
(Select beer FROM Likes WHERE drinker = 'Devarsh') DB WHERE DB.beer = MB.beer;

# 3. Drinkers who do not frequent Caravan bar

Select distinct * FROM Frequents;

Select distinct Frequents.drinker FROM Frequents, (Select distinct drinker FROM Frequents WHERE bar = 'Caravan')CD WHERE CD.drinker != Frequents.drinker;

# 4. Beers which sell most beers under $6 (include ties)

Select distinct beer FROM Sells WHERE beer <= 6;

# 6. Use left join to find Drinkers who do not frequent Caravan bar

Select * FROM Frequents;

Select distinct Frequents.drinker FROM Drinker left join Frequents ON name = drinker where drinker not in (Select drinker from Frequents where bar = 'Caravan');

# 7. Use Case statement to add new attribute to Sells table with two values:  "Expensive" and "Regular". Expensive are beers sold above $8, The remaining beers are "Regular".

Select distinct *,
CASE
	WHEN price > 8 THEN 'Expensive'
    ELSE 'Regular'
    END AS Type
FROM Sells;

# 8. Which precinct(s) had the highest totalvotes at the end of voting?

Select distinct precinct FROM Penna 
WHERE timestamp = (select Max(timestamp) from Penna)
GROUP BY precinct Order BY sum(totalvotes) desc LIMIT 1;

# 9. Extract domain name from www.cs.rutgers.edu/~rmartin

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('www.cs.rutgers.edu/~rmartin', '.', -3), '/', 1) as result;

# 10. How many votes did Biden get by the end of the day of November 6, 2020?

Select * FROM Penna;

Select distinct timestamp, Biden FROM Penna 
WHERE timestamp = (select Max('2020-11-06%') from Penna)
GROUP BY timestamp, Biden ORDER BY sum(Biden) desc LIMIT 1; 

Select distinct timestamp, TP.Biden FROM
(Select timestamp FROM Penna WHERE timestamp = '2020-11-06%')TP 
WHERE TP.timestamp = (Select Max(TP.timestamp) FROM Penna) GROUP BY timestamp, TP.Biden ORDER BY sum(TP.Biden) LIMIT 1;

Error Code: 1054. Unknown column 'TP.Biden' in 'field list'


Error Code: 1052. Column 'timestamp' in where clause is ambiguous



