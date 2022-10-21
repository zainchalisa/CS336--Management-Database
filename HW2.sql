# Zain Chalisa (zc285)
# 1.Drinkers who like the most beers (highest number of beers)

Select distinct drinker, count(beer) From Likes GROUP BY drinker ORDER BY Count(*) desc;

# 2. Bars which sell most expensive Budweiser and are not frequented by Gunjan

Select distinct s.bar FROM Sells s JOIN Frequents, (Select MAX(price) as LargestPrice FROM Sells)sl 
WHERE s.beer = 'Budweiser' and Frequents.drinker != 'Gunjan' and s.price = LargestPrice;

# 3. Drinkers who frequent only bars which serve all beers they like

Select distinct drinker FROM Likes WHERE drinker NOT IN
	(Select drinker FROM Likes WHERE NOT EXISTS 
    (Select distinct Frequents.bar FROM Sells, Frequents WHERE
		Frequents.drinker = Likes.drinker and Sells.beer = Likes.beer AND Frequents.bar = Sells.bar));
              
# 4. Drinkers who frequent most popular bar (the one with highest count of drinkers)

Select distinct drinker FROM Frequents, (Select bar FROM Frequents GROUP BY bar ORDER BY count(bar) desc LIMIT 1)bc 
WHERE Frequents.bar = bc.bar; 

# 5. Precinct(s) which collected the least number of  total votes by end of day of November 5th 2020

Select distinct precinct, sum(totalvotes) FROM Penna 
WHERE timestamp like '2020-11-05%' 
GROUP BY precinct ORDER BY sum(totalvotes) asc LIMIT 1; 

# 6. Which precincts did Trump win by more than 100 votes in 2020 

Select distinct precinct FROM Penna 
WHERE timestamp = (select Max(timestamp) from Penna)
GROUP BY precinct HAVING sum(Trump) - sum(Biden) > 100;

Select distinct precinct, max(timestamp) FROM Penna WHERE (sum(Trump)-sum(Biden)) > 100 GROUP BY precinct, timestamp ORDER BY max(timestamp);

SELECT precinct, max(Timestamp)
FROM Penna
WHERE trump - biden > 100
GROUP BY precinct
ORDER BY max(Timestamp);

# 7. Has Trump ever led the total vote (for any of the timestamps)?  (Return "Yes he did on <timestamp>" or "No he never did".

Select timestamp, 
CASE  
	WHEN Trump > Biden THEN concat('Yes he did on ' , timestamp) 
    ELSE 'No he never did'
    END AS Result
FROM Penna LIMIT 1;    






